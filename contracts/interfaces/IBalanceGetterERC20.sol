// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;

interface IBalanceGetterERC20 {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}