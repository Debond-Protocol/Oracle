//SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol"; 
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "./IOracle.sol";

contract Oracle is IOracle {
    
    address immutable factory;
   
    constructor(
        address _factory
    ) {
        factory = _factory;
    }
    
    function getPool(address _token0, address _token1, uint24 _fee) internal view returns(address poolAddress) {
         poolAddress = IUniswapV3Factory(factory).getPool(
            _token0,
            _token1,
            _fee
        );
        require(poolAddress != address(0), "pool doesn't exist");
    }
     

    function estimateAmountOut(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint24 fee,
        uint32 secondsAgo
    ) external view returns (uint amountOut) {

        // (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo);

        // Code copied from OracleLibrary.sol, consult()
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        //uint32[] memory secondsAgos2  = abi.encode(secondsAgos);

        // int56 since tick * time = int24 * uint32
        // 56 = 24 + 32
        address pool = getPool(tokenIn, tokenOut, fee);
        require(pool != address(0), "Oracle : address is null");
        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(
            secondsAgos
        );
               

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        //require(tickCumulativesDelta > 0, "tick is null");

        // int56 / uint32 = int24
        int24 tick = int24(tickCumulativesDelta / secondsAgo);
        // Always round to negative infinity
        /*
        int doesn't round down when it is negative
        int56 a = -3
        -3 / 10 = -3.3333... so round down to -4
        but we get
        a / 10 = -3
        so if tickCumulativeDelta < 0 and division has remainder, then round
        down
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
    //for changing fee param
    function getPoolWithoutCheck(address token1, address token2, uint24 fee) public view returns (address poolAddress) {
        poolAddress = IUniswapV3Factory(factory).getPool(token1, token2, fee);  //can be 0
    }
}