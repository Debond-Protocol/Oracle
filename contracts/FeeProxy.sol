//SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IOracle.sol";
import "./IFeeProxy.sol";


contract FeeProxy is IFeeProxy {

    using SafeERC20 for IERC20;

    address immutable factory; 

    constructor( address _factory) {
        factory = _factory;
    }
    
    struct poolParam {
        address poolAddress;
        uint24 fee;
    }
    mapping( address=> mapping( address => poolParam) ) param;

    uint24[4] fees = [10000, 3000, 500, 100]; 

    function _getLiquidity(address token1, address token2, uint24 fee) internal returns (uint balance1, address poolAddress) {
        poolAddress = IUniswapV3Factory(factory).getPool(token1, token2, fee);
        balance1;
        if (poolAddress != address(0)){
            balance1 = IERC20(token1).balance(poolAddress);
        }
    }

    function _maxLiquidity(address token1, address token2) internal returns (uint24 fee, address poolAddress) {
        fee = 100;
        (uint balance, address poolAddresse) = _getLiquidity(token1, token2, fee);
    
        for (uint i; i < 3; i++) {
            uint24 temp_fee = fees[i];
            (uint temp_balance, address temp_address) = _getLiquidity(token1, token2, temp_fee);
            if (temp_balance > balance) {
                (fee, poolAddress) = (temp_fee, temp_address);
            }
        }
    }

    function update(address token1, address token2) public {
        (address tokenA, address tokenB) = _sortTokens(token1, token2);
        (param[tokenA][tokenB].poolAddress, param[tokenA][tokenB].fee) = _maxLiquidity(tokenA, tokenB);
    }


    function _sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'feeProxy: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'feeProxy: ZERO_ADDRESS');
    }
}