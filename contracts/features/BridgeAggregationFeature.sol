// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "../interfaces/IBKFees.sol";
import "../interfaces/IBKRegistry.sol";
import "../utils/TransferHelper.sol";

import {SignParams, AggregationParams} from "../interfaces/IBKStructsAndEnums.sol";
import {IBKErrors} from "../interfaces/IBKErrors.sol";

library BridgeAggregationFeature {
    string public constant FEATURE_NAME =
        "BitKeep SOR: Bridge Aggregation Feature";
    string public constant FEATURE_VERSION = "1.0";

    address public constant BK_FEES =
        0xE4DA6f981a78b8b9edEfE4D7a955C04bA7e67D8D;
    address public constant BK_REGISTRY =
        0x9aFD2948F573DD8684347924eBcE1847D50621eD;

    bytes4 public constant FUNC_BRIDGE_AGG =
        bytes4(
            keccak256(
                bytes("bridge_agg(BridgeAggregationFeature.BridgeDetail)")
            )
        ); // 0xb0dce4dd

    event BridgeAgg(
        BridgeType indexed bridgeType,
        address fromTokenAddress,
        address toTokenAddress,
        address fromChainId,
        address dstChainId,
        uint256 amountInTotal,
        uint256 amountInForSwap,
        uint256 additionalFee,
        address receiver,
        uint256 minAmountOut,
        uint256 feeAmount,
        string featureName,
        string featureVersion
    );

    enum BridgeType {
        FREE,
        ETH_OTHERS,
        TOKEN_OTHERS
    }

    struct BridgeBasicParams {
        SignParams signParams;
        BridgeType bridgeType;
        bool feeTokenIsWhite;
        address fromTokenAddress;
        address toTokenAddress;
        address fromChainId;
        address dstChainId;
        uint256 amountInTotal;
        uint256 amountInForSwap;
        uint256 additionalFee;
        address receiver;
        uint256 minAmountOut;
    }

    struct BridgeDetail {
        BridgeBasicParams basicParams;
        AggregationParams aggregationParams;
    }

    function bridge_agg(BridgeDetail calldata bridgeDetail) external {
        if (
            !IBKRegistry(BK_REGISTRY).isCallTarget(
                FUNC_BRIDGE_AGG,
                bridgeDetail.aggregationParams.callTarget
            )
        ) {
            revert IBKErrors.IllegalCallTarget();
        }

        if (
            !IBKRegistry(BK_REGISTRY).isApproveTarget(
                FUNC_BRIDGE_AGG,
                bridgeDetail.aggregationParams.approveTarget
            )
        ) {
            revert IBKErrors.IllegalApproveTarget();
        }

        if (bridgeDetail.basicParams.bridgeType > BridgeType.TOKEN_OTHERS) {
            revert IBKErrors.SwapTypeNotAvailable();
        }

        bool fromTokenIsETH = TransferHelper.isETH(
            bridgeDetail.basicParams.fromTokenAddress
        );

        if (fromTokenIsETH) {
            if (
                msg.value <
                bridgeDetail.basicParams.amountInTotal +
                    bridgeDetail.basicParams.additionalFee
            ) {
                revert IBKErrors.SwapEthBalanceNotEnough();
            }
        } else {
            if (msg.value < bridgeDetail.basicParams.additionalFee) {
                revert IBKErrors.SwapEthBalanceNotEnough();
            }
        }

        IBKFees(BK_FEES).checkIsSigner(
            keccak256(
                abi.encodePacked(
                    bridgeDetail.basicParams.signParams.nonceHash,
                    bridgeDetail.basicParams.amountInTotal,
                    bridgeDetail.basicParams.amountInForSwap,
                    bridgeDetail.basicParams.additionalFee
                )
            ),
            bridgeDetail.basicParams.signParams.signature
        );

        if (bridgeDetail.basicParams.bridgeType == BridgeType.FREE) {
            if (fromTokenIsETH) {
                _bridgeEth2Others(bridgeDetail, true, payable(address(0)), 0);
            } else {
                _bridgeToken2Others(bridgeDetail, true, address(0), 0);
            }
        } else {
            (address feeTo, address altcoinFeeTo, uint256 feeRate) = IBKFees(
                BK_FEES
            ).getFeeTo();

            if (bridgeDetail.basicParams.bridgeType == BridgeType.ETH_OTHERS) {
                _bridgeEth2Others(bridgeDetail, false, payable(feeTo), feeRate);
            } else {
                if (bridgeDetail.basicParams.feeTokenIsWhite) {
                    _bridgeToken2Others(bridgeDetail, false, feeTo, feeRate);
                } else {
                    _bridgeToken2Others(
                        bridgeDetail,
                        false,
                        altcoinFeeTo,
                        feeRate
                    );
                }
            }
        }
    }

    function _bridgeEth2Others(
        BridgeDetail calldata bridgeDetail,
        bool _isFree,
        address payable _feeTo,
        uint256 _feeRate
    ) internal {
        uint256 feeAmount;
        if (!_isFree) {
            feeAmount =
                ((bridgeDetail.basicParams.amountInTotal -
                    bridgeDetail.basicParams.additionalFee) * _feeRate) /
                1e4;
            TransferHelper.safeTransferETH(_feeTo, feeAmount);
        }

        if (
            bridgeDetail.basicParams.amountInForSwap !=
            bridgeDetail.basicParams.amountInTotal -
                bridgeDetail.basicParams.additionalFee -
                feeAmount
        ) {
            revert IBKErrors.SwapEthBalanceNotEnough();
        }

        (bool success, ) = bridgeDetail.aggregationParams.callTarget.call{
            value: bridgeDetail.basicParams.amountInForSwap +
                bridgeDetail.basicParams.additionalFee
        }(bridgeDetail.aggregationParams.data);

        _checkCallResult(success);

        _emitEvent(bridgeDetail, feeAmount);
    }

    function _bridgeToken2Others(
        BridgeDetail calldata bridgeDetail,
        bool _isFree,
        address _feeTo,
        uint256 _feeRate
    ) internal {
        IERC20 fromToken = IERC20(bridgeDetail.basicParams.fromTokenAddress);

        uint256 balanceOfThis = fromToken.balanceOf(address(this));
        uint256 balanceBefore = balanceOfThis -
            bridgeDetail.basicParams.amountInTotal;
        if (
            balanceOfThis - balanceBefore <
            bridgeDetail.basicParams.amountInTotal
        ) {
            revert IBKErrors.BurnToMuch();
        }

        TransferHelper.approveMax(
            fromToken,
            bridgeDetail.aggregationParams.approveTarget,
            bridgeDetail.basicParams.amountInTotal
        );

        uint256 feeAmount;
        if (!_isFree) {
            feeAmount =
                (bridgeDetail.basicParams.amountInTotal * _feeRate) /
                1e4;
            TransferHelper.safeTransfer(
                bridgeDetail.basicParams.fromTokenAddress,
                _feeTo,
                feeAmount
            );
        }

        if (
            bridgeDetail.basicParams.amountInForSwap !=
            bridgeDetail.basicParams.amountInTotal - feeAmount
        ) {
            revert IBKErrors.SwapTokenBalanceNotEnough();
        }

        (bool success, ) = bridgeDetail.aggregationParams.callTarget.call{
            value: bridgeDetail.basicParams.additionalFee
        }(bridgeDetail.aggregationParams.data);

        _checkCallResult(success);

        _emitEvent(bridgeDetail, feeAmount);
    }

    function _emitEvent(
        BridgeDetail calldata bridgeDetail,
        uint256 feeAmount
    ) internal {
        emit BridgeAgg(
            bridgeDetail.basicParams.bridgeType,
            bridgeDetail.basicParams.fromTokenAddress,
            bridgeDetail.basicParams.toTokenAddress,
            bridgeDetail.basicParams.fromChainId,
            bridgeDetail.basicParams.dstChainId,
            bridgeDetail.basicParams.amountInTotal,
            bridgeDetail.basicParams.amountInForSwap,
            bridgeDetail.basicParams.additionalFee,
            bridgeDetail.basicParams.receiver,
            bridgeDetail.basicParams.minAmountOut,
            feeAmount,
            FEATURE_NAME,
            FEATURE_VERSION
        );
    }

    function _checkCallResult(bool _success) internal pure {
        if (!_success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
}
