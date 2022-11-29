// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IBKSwapRouter {
    struct SwapParams {
        address fromTokenAddress;
        uint256 amountInTotal;
        bytes data;
    }

    function swap(SwapParams calldata swapParams) external;
}