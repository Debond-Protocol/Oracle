// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/libraries/Oracle.sol';
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import '@uniswap'

// ref: https://github.com/Uniswap/v3-core/blob/main/contracts/test/OracleTest.sol .

//

contract OracleTest  {
    using Oracle for Oracle.Observation[65535];

    // reference methods from the oracle 
        mapping(address => mapping( address => address)) poolAddresses;
        uint24[4] fees = [10000, 3000, 500, 100];
        uint24 liquidityFeesParam = 100;
        address _poolAddress;



    Oracle.Observation[65535] public observations;

    uint32 public time;
    int24 public tick;
    uint128 public liquidity;
    uint16 public index;
    uint16 public cardinality;
    uint16 public cardinalityNext;

    struct InitializeParams {
        uint32 time;
        int24 tick;
        uint128 liquidity;
    }

    function initialize(InitializeParams calldata params) external {
        require(cardinality == 0, 'already initialized');
        time = params.time;
        tick = params.tick;
        liquidity = params.liquidity;
        (cardinality, cardinalityNext) = observations.initialize(params.time);
    }

    function advanceTime(uint32 by) public {
        time += by;
    }

    struct UpdateParams {
        uint32 advanceTimeBy;
        int24 tick;
        uint128 liquidity;
    }

    // write an observation, then change tick and liquidity
    function update(UpdateParams calldata params) external {
        advanceTime(params.advanceTimeBy);
        (index, cardinality) = observations.write(index, time, tick, liquidity, cardinality, cardinalityNext);
        tick = params.tick;
        liquidity = params.liquidity;
    }

    function batchUpdate(UpdateParams[] calldata params) external {
        // sload everything
        int24 _tick = tick;
        uint128 _liquidity = liquidity;
        uint16 _index = index;
        uint16 _cardinality = cardinality;
        uint16 _cardinalityNext = cardinalityNext;
        uint32 _time = time;

        for (uint256 i = 0; i < params.length; i++) {
            _time += params[i].advanceTimeBy;
            (_index, _cardinality) = observations.write(
                _index,
                _time,
                _tick,
                _liquidity,
                _cardinality,
                _cardinalityNext
            );
            _tick = params[i].tick;
            _liquidity = params[i].liquidity;
        }

        // sstore everything
        tick = _tick;
        liquidity = _liquidity;
        index = _index;
        cardinality = _cardinality;
        time = _time;
    }

    function grow(uint16 _cardinalityNext) external {
        cardinalityNext = observations.grow(cardinalityNext, _cardinalityNext);
    }

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
    {
        return observations.observe(time, secondsAgos, tick, index, liquidity, cardinality);
    }

    function getGasCostOfObserve(uint32[] calldata secondsAgos) external view returns (uint256) {
        (uint32 _time, int24 _tick, uint128 _liquidity, uint16 _index) = (time, tick, liquidity, index);
        uint256 gasBefore = gasleft();
        observations.observe(_time, secondsAgos, _tick, _index, _liquidity, cardinality);
        return gasBefore - gasleft();
    }
    // mock functions for the uniswapV3Factory (only for testing the values)

    // functions of debond oracle governance 
    
        function _sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'feeProxy: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'feeProxy: ZERO_ADDRESS');
    }


     function estimateAmountOut(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo
    ) external   returns (uint amountOut) {

    (address token0, address token1) = _sortTokens(tokenIn, tokenOut);
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = secondsAgo;
    secondsAgos[1] = 0; 
    (int56[] memory tickCumulatives, ) = this.observe(secondsAgos);
     int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        //  convertion type  int56 / uint32 = int24.
         tick = int24(tickCumulativesDelta / secondsAgo);
     
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


        function updateLiquidity(address token1, address token2) external  {
        (address tokenA, address tokenB) = _sortTokens(token1, token2);
        poolAddresses[tokenA][tokenB] = _maxLiquidity(tokenA, tokenB);
    }


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
        poolAddress = IUniswapV3Factory(factory).getPool(token1, token2, fee);  //can be 0
        if (poolAddress != address(0)){
            balance1 = IBalanceGetterERC20(token1).balanceOf(poolAddress);
        }
    }

    function getPool(address token1, address token2, uint24 fee) internal view returns (address) {
        //TODO: just an generic example of external address 
        returns _poolAddress;
    }




}