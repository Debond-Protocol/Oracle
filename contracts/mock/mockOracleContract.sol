
pragma solidity 0.7.6;

import "../interfaces/IOracle.sol";

// SPDX-License-Identifier: apache 2.0
/*
    Copyright 2022 Debond Protocol Foundation <info@SGM.finance>
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

contract FakeOracle is IOracle{

    constructor(address _oracleDeployed) {

    }

    function testEstimateAmountOut(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo
    ) external  pure returns (uint amountOut) {
       
        amountOut = amountIn / 1e12;
   
   
   
    }
}

