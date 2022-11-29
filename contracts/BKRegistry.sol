// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "./BKCommon.sol";

contract BKRegistry is BKCommon {
    struct Feature {
        address proxy;
        bool isLib;
        bool isActive;
    }

    mapping(bytes4 => Feature) private features;
    mapping(bytes4 => mapping(address => bool)) private isCallTargets;
    mapping(bytes4 => mapping(address => bool)) private isApproveTargets;

    event SetFeature(address operator, bytes4 methodId, address proxy, bool isLib, bool isActive);
    event SetCallTarget(address operator, bytes4 methodId, address target, bool isEnable);
    event SetApproveTarget(address operator, bytes4 methodId, address target, bool isEnable);

    constructor(address _owner) {
        _transferOwnership(_owner);
    }

    function setFeature(
        bytes4 _methodId,
        address _proxy,
        bool _isLib,
        bool _isActive
    ) external onlyOwner whenNotPaused {
       
        Feature memory feat = Feature({
            proxy : _proxy,
            isLib : _isLib,
            isActive : _isActive
        });
        features[_methodId] = feat;
        
        emit SetFeature(msg.sender, _methodId, _proxy, _isLib, _isActive);
    }

    function getFeature(bytes4 _methodId)
        external
        view
        returns (address proxy, bool isLib) {
        Feature memory feat = features[_methodId];

        _checkFeatureStatus(feat);

        proxy = feat.proxy;
        isLib = feat.isLib;
    }

    function setCallTarget(
        bytes4 _methodId,
        address [] calldata _targets,
        bool _isEnable
    ) external onlyOwner whenNotPaused {
        Feature memory feat = features[_methodId];

        _checkFeatureStatus(feat);

        for (uint256 i = 0; i < _targets.length; i++) {
            isCallTargets[_methodId][_targets[i]] = _isEnable;
            emit SetCallTarget(msg.sender, _methodId, _targets[i], _isEnable);
        }
    }

    function isCallTarget(bytes4 _methodId, address _target)
        external
        view
        returns (bool) {
        Feature memory feat = features[_methodId];

        _checkFeatureStatus(feat);

        return isCallTargets[_methodId][_target];
    }

    function setApproveTarget(
        bytes4 _methodId,
        address [] calldata _targets,
        bool _isEnable
    ) external onlyOwner whenNotPaused {
        Feature memory feat = features[_methodId];

        _checkFeatureStatus(feat);

        for (uint256 i = 0; i < _targets.length; i++) {
            isApproveTargets[_methodId][_targets[i]] = _isEnable;
            emit SetApproveTarget(msg.sender, _methodId, _targets[i], _isEnable);
        }
    }

    function isApproveTarget(bytes4 _methodId, address _target)
        external
        view
        returns (bool) {
        Feature memory feat = features[_methodId];

        _checkFeatureStatus(feat);

        return isApproveTargets[_methodId][_target];
    }

    function _checkFeatureStatus(Feature memory _feat) internal pure {
        if (_feat.proxy == address(0)) {
            revert FeatureNotExist();
        }

        if (!_feat.isActive) {
            revert FeatureInActive();
        }
    }
}
