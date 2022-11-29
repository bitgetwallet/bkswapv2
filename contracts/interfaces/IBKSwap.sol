// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IBKSwap {
    function setRegistry(address _bkRegistry) external;

    function bkRegistry() view external returns (address); 
    
    function managerCaller(address _caller, bool _isCaller) external;
    
    function isCaller(address _caller) view external returns(bool);
}
