// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import {SignParams, AggregationParams} from "../interfaces/IBKStructsAndEnums.sol";

interface IBridgeAggregationFeature {

    enum BridgeType {
        FREE,   
        ETH_OTHERS,
        TOKEN_OTHERS
    }

    struct BridgeBasicParams {
        SignParams signParams; // 签名信息，bridgeType为free类型需要
        BridgeType bridgeType; // bridge类型
        bool feeTokenIsWhite;   // 收取手续费的token是不是白名单币种，服务端传参
        address fromTokenAddress; // 源链fromToken地址
        address toTokenAddress; // 目标链toToken地址
        uint256 fromChainId; // 源链chainId
        uint256 dstChainId; // 目标链chainId
        uint256 amountInTotal; // amountInTotal = amountInForSwap + additionalFee
        uint256 amountInForSwap; // amountIn扣除手续费，服务端计算
        uint256 additionalFee; // 附加费用，作为交易附带的value传递，如果没有，传0
        address receiver; // 目标链兑换接收者
        uint256 minAmountOut; // toToken在目标链接收到的minAmountOut
    }

    struct BridgeDetail {
        BridgeBasicParams basicParams;
        AggregationParams aggregationParams;
    }

    function bridge_agg(BridgeDetail calldata bridgeDetail) external;
}