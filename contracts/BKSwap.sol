//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./BKCommon.sol";
import "./interfaces/IBKRegistry.sol";

contract BKSwap is BKCommon {
    address bkRegistry;

    constructor(address _bkRegistry) {
        bkRegistry = _bkRegistry;
    }
    
    function setBKRegistryAddress(address _bkRegistry) external onlyOwner {
        bkRegistry = _bkRegistry;
    }
    
    fallback() external payable whenNotPaused {
        if(msg.sig.length != 4) { revert InvalidMsgSig(); }

        (address proxy, bool isLib) = IBKRegistry(bkRegistry).getFeature(msg.sig);
        
        if (proxy == address(0)) { revert FeatureNotExist(msg.sig); }

        (bool success, bytes memory resultData) = isLib
            ? proxy.delegatecall(msg.data)
            : proxy.call{value: msg.value}(msg.data);

        if (!success) {
            _revertWithData(resultData);
        }

        _returnWithData(resultData);
    }

    /// @dev Revert with arbitrary bytes.
    /// @param data Revert data.
    function _revertWithData(bytes memory data) private pure {
        assembly { revert(add(data, 32), mload(data)) }
    }

    /// @dev Return with arbitrary bytes.
    /// @param data Return data.
    function _returnWithData(bytes memory data) private pure {
        assembly { return(add(data, 32), mload(data)) }
    }
}