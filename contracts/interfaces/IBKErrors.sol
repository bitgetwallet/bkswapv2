//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface IBKErrors {
    error InvalidMsgSig();
    error InsufficientEtherSupplied();
    error FeatureNotExist(bytes4 msgSig);
    error FeatureInActive();
    error InvalidSigner();
    error InvalidNonce(bytes32 signMsg);
    error SwapEthBalanceNotEnough();
    error SwapTokenBalanceNotEnough();
    error SwapTokenApproveNotEnough();
    error SwapInsuffenceOutPut();
    error SwapTypeNotAvailable();
    error BurnToMuch();
    error IllegalCallTarget();
    error IllegalApproveTarget();  
}