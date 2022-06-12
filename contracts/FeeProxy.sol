//SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol"; 
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "./IOracle.sol";

contract FeeProxy is IOracle {
    mapping(address => uint24) fee;
    uint24[4] fees = [10000, 3000, 500, 100]; 

    function updateFee(address poolAddress) public {
        fee(poolAddress) = maxLiquidity(poolAddress); 
    }

    function getLiquidity(address poolAddress, uint24 fee) internal returns (uint24 fee) {

    }

    function maxLiquidity(address poolAddress) internal returns (uint24 fee) {
        uint24 fee = getLiquidity(poolAddress, 100);
        for (uint i; i < 3; i++) {
            temp_fee = getLiquidity(poolAddress, fees[i]);
            if (temp_fee > fee) {
                fee = temp_fee;
            }
        }
    }
}