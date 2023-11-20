// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


library SignedMath {
   
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

   
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

   
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

   
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}