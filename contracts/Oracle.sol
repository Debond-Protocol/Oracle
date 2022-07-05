//SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol"; 
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IBalanceGetterERC20.sol";

//import "debond-governance-contracts/utils/GovernanceOwnable.sol";

contract Oracle is IOracle  {
    address immutable factory;
    mapping(address => mapping( address => address)) poolAddresses;
    uint24[4] fees = [10000, 3000, 500, 100];
    uint24 liquidityFeesParam = 100;
    constructor(
        address _factory,
        address governance
    ) /**GovernanceOwnable(governance) **/ {
        factory = _factory;
    }
    /**
    updating the liquidity of the pool address, based on the availablity of the corresponding pool address.    
     */
    function updateLiquidity(address token1, address token2) external  {
        (address tokenA, address tokenB) = _sortTokens(token1, token2);
        poolAddresses[tokenA][tokenB] = _maxLiquidity(tokenA, tokenB);
    }
    /**
    internal function  to determine pool address with the maxLiquidity for the corresponding pair 
    @dev in order to use them for determining the price which is consistent for sufficient liquidity.   
    @param token1 is the address of given ERC20.
    @param token2 is the address of underlying stablecoin.
    @return poolAddress the address of pool with the highest liquidity.
     */

    function _maxLiquidity(address token1, address token2) internal view returns (address poolAddress) {
        uint balance;
        //TODO: the  fees parameter will not be constant, will depend on the given pool. 
        (balance, poolAddress) = _getLiquidity(token1, token2, liquidityFeesParam);

        // determining the minimum fees sufficient for getting the pool address.
        for (uint i; i < 3; i++) {
            (uint temp_balance, address temp_address) = _getLiquidity(token1, token2, fees[i]);
            if (temp_balance > balance) {
                poolAddress = temp_address;
            }
        }
    }


    /**
    @dev getting balance of ERC20 present in the pool (for the swap conversion). 
    @param token1 is the address of given ERC20.
    @param token2 is the address of underlying stablecoin.


     */
    function _getLiquidity(address token1, address token2, uint24 fee) internal view returns (uint balance1, address poolAddress) {
        poolAddress = _getPoolWithoutCheck(token1, token2, fee);
        if (poolAddress != address(0)){
            balance1 = IBalanceGetterERC20(token1).balanceOf(poolAddress);
        }
    }

    function _sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'feeProxy: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'feeProxy: ZERO_ADDRESS');
    }
    
    // function getPool(address _token0, address _token1, uint24 _fee) internal view returns(address poolAddress) {
    //      poolAddress = IUniswapV3Factory(factory).getPool(
    //         _token0,
    //         _token1,
    //         _fee
    //     );
    //     require(poolAddress != address(0), "pool doesn't exist");
    // }
     

    function estimateAmountOut(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo
    ) external override view returns (uint amountOut) {


        (address token0, address token1) = _sortTokens(tokenIn, tokenOut);
        address poolAddress = poolAddresses[token0][token1];
        require(poolAddress != address(0), "CDP : address is null");

        // Code copied from OracleLibrary.sol, consult()
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        //uint32[] memory secondsAgos2  = abi.encode(secondsAgos);

        // int56 since tick * time = int24 * uint32
        // 56 = 24 + 32
        
        //address pool = getPool(tokenIn, tokenOut, fee);
        //require(pool != address(0), "Oracle : address is null");
        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(poolAddress).observe(
            secondsAgos
        );
               

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        //require(tickCumulativesDelta > 0, "tick is null");

        // int56 / uint32 = int24
        int24 tick = int24(tickCumulativesDelta / secondsAgo);
     
        /* if tickCumulativeDelta < 0 and division has remainder
       using floor function for decreasing price: we convert into the previous least integer. 
        */
        if (
            tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)
        ) {
            tick--;
        }

        amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            amountIn,
            tokenIn,
            tokenOut
        );
    }
    /**
    @dev for fetching the pool address for the given pool and fees 
    @dev  used as an check for determining liquidity .  
     */
    function _getPoolWithoutCheck(address token1, address token2, uint24 fee) internal  view returns (address poolAddress) {
        poolAddress = IUniswapV3Factory(factory).getPool(token1, token2, fee);  //can be 0
    }

    /**
    changing factory contract when needed.

     */
    // function setFactoryContract(address _newFactoryContract) external /**onlyGovernace**/ returns(bool){
    //     factory = _newFactoryContract;
    //     return(true);
    // }


}