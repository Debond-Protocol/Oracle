//SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol"; 
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IOracle.sol";

contract FeeProxy is IOracle {

    using SafeERC20 for IERC20;

    address immutable factory; 

    constructor( address _factory) {
        factory = _factory;
    }
    
    struct poolParam {
        address poolAddress;
        uint24 fee;
    }
    mapping( address=> mapping( address => poolStruct) ) param;

    uint24[4] fees = [10000, 3000, 500, 100]; 

    function updateFee(address token1, token2) public {
        param(token1, token2) = maxLiquidity(token1, token2); 
    }

    function getLiquidity(address token1, address token2, uint24 fee) internal returns (uint balance1, address poolAddress) {
        poolAddress = IUniswapV3Factory(factory).getPool(_token0, _token1, _fee);
        uint balance1 = IERC20(token1).balance(poolAddress);
    }

    function maxLiquidity(address token1, address token2) internal returns (uint24 fee, address poolAddress) {
        (uint balance, address poolAddresse) = getLiquidity(token1, token2, 100);
        uint24 fee = 100;
        for (uint i; i < 3; i++) {
            uint24 temp_fee = fees[i];
            (temp_balance, temp_address) = getLiquidity(poolAddress, temp_fee);
            if (temp_balance > balance) {
                (fee, poolAddress) = (temp_fee, temp_address);
            }
        }
    }
}