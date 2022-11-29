// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IBKCommon {
    function setOperator(address[] memory _operators, bool _isOperator) external; 
    
    function pause() external;

    function unpause() external;

    function rescueETH(address recipient) external;
    
    function rescueERC20(address asset, address recipient) external;
}