//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./BKCommon.sol";
import "./utils/TransferHelper.sol";
import { BasicParams, AggregationParams, SwapType, OrderInfo } from "./interfaces/IBKStructsAndEnums.sol";
import { IBKErrors } from "./interfaces/IBKErrors.sol";

contract BKSwapRouter is BKCommon {

    struct SwapParams {
        address bkSwap;
        address fromTokenAddress;
        uint256 amountInTotal;
        bytes data;
    }
    mapping(address => bool) public isBKSwap;

    event ManageBKSwap(address operator, address bkswap, bool opened);

    function manageBKSwap(address _bkSwap, bool _open) external onlyOwner {
        isBKSwap[_bkSwap] = _open;
        emit ManageBKSwap(msg.sender, _bkSwap, _open);
    }

    function swap(SwapParams calldata swapParams)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        if(!isBKSwap[swapParams.bkSwap]) {
            revert InvalidSwapAddress(swapParams.bkSwap);
        }

        if (!TransferHelper.isETH(swapParams.fromTokenAddress)) {
            TransferHelper.safeTransferFrom(
                swapParams.fromTokenAddress,
                msg.sender,
                swapParams.bkSwap,
                swapParams.amountInTotal
            );
        } else {
            if (msg.value < swapParams.amountInTotal) {
                revert IBKErrors.SwapEthBalanceNotEnough();
            }
        }

        (bool success, bytes memory resultData) = swapParams.bkSwap.call{
            value: msg.value
        }(swapParams.data);

        if (!success) {
            _revertWithData(resultData);
        }
    }
}
