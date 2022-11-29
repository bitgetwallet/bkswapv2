//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface IBKSwapRouter {
    struct SwapParams {
        address bkSwap;
        address fromTokenAddress;
        uint256 amountInTotal;
        bytes data;
    }

    function swap(SwapParams calldata swapParams) external;
}