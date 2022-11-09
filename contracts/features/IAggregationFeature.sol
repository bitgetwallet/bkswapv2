//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import { 
    BasicParams, 
    AggregationParams, 
    SwapType, 
    OrderInfo 
} from "../interfaces/IBKStructsAndEnums.sol";

interface IAggregationFeature {
    event Swap(
        SwapType indexed swapType,
        address indexed receiver,
        uint feeAmount,
        string featureName
    );

    event OrderInfoEvent(
        bytes transferId,
        uint dstChainId,
        address sender,
        address bridgeReceiver,
        address tokenIn,
        address desireToken,
        uint amount
    );

    struct SwapDetail {
        BasicParams basicParams;
        AggregationParams aggregationParams;
        OrderInfo orderInfo;
    }

    function swap(SwapDetail calldata swapDetail) external;
}