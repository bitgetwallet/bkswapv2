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
    function manageBKSwap(address _bkSwap, bool _open) external;
    function isBKSwap(address _bkSwap) view external returns(bool);
}