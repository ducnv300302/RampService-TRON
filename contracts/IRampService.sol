// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./ISunswapV2router02.sol";

interface IRampService {
    event Sold(address token, uint256 amount, address receiver, string txid);
    event Purchased(address token, uint256 amount, string txid);

    function buy(
        address payable receiver,
        address token,
        uint256 amount,
        uint8 decimals,
        string memory txId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function sell(
        address token,
        uint256 amount,
        uint8 decimals,
        string memory txId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}
