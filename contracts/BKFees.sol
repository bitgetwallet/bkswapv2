//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./BKCommon.sol";

contract BKFees is BKCommon {
   
    using ECDSA for bytes32;

    address payable private feeTo;
    address payable private altcoinsFeeTo;
    uint private feeRate;
    address private signer;
    mapping (bytes32 => bool) private executed;

    event SetFeeTo(
        address operator, 
        address payable feeTo, 
        address payable altcoinsFeeTo,
        uint feeRate
    );
    event SetSigner(address operator, address newSigner);

    constructor (
        address _signer,
        address payable _feeTo,
        address payable _altcoinsFeeTo,
        uint _feeRate
    ) {
        if (_signer == address(0) || _feeTo == address(0) || _altcoinsFeeTo == address(0)) {
            revert InvalidZeroAddress();
        }

        if (_feeRate < 10 || _feeRate > 50) {
            revert InvalidFeeRate(_feeRate);
        }

        signer = _signer;
        feeTo = _feeTo;
        altcoinsFeeTo = _altcoinsFeeTo;
        feeRate = _feeRate;
        
        emit SetFeeTo(msg.sender, _feeTo, _altcoinsFeeTo, _feeRate);
    }

    function setFeeTo (
        address payable _feeTo,
        address payable _altcoinsFeeTo,
        uint _feeRate
    )  external onlyOwner whenNotPaused {

        if ( _feeTo == address(0) || _altcoinsFeeTo == address(0)) {
            revert InvalidZeroAddress();
        }

        if (_feeRate < 10 || _feeRate > 50) {
            revert InvalidFeeRate(_feeRate);
        }
       
        feeTo = _feeTo;
        altcoinsFeeTo = _altcoinsFeeTo;
        feeRate = _feeRate;

        emit SetFeeTo(msg.sender, _feeTo, _altcoinsFeeTo, _feeRate);
    }

    function getFeeTo () external view returns(
        address payable _feeTo,
        address payable _altcoinsFeeTo,
        uint _feeRate
    ){
        _feeTo = feeTo;
        _altcoinsFeeTo = altcoinsFeeTo;
        _feeRate = feeRate;
    }

    function setSigner(address _signer) external onlyOwner whenNotPaused {
        if ( _signer == address(0)) {
            revert InvalidZeroAddress();
        }
        signer = _signer;

        emit SetSigner(msg.sender, _signer);
    }
    
    function getSigner() external view returns(address){
        return signer;
    }
  
    function checkIsSigner(bytes32 _nonceHash, bytes calldata _signature) external {

        bytes32 msgHash = keccak256(abi.encodePacked(_nonceHash, block.chainid, address(this)));
        
        bytes32 finalMsgHash = msgHash.toEthSignedMessageHash();
        
        if (executed[finalMsgHash]) {
            revert IBKErrors.InvalidNonce(finalMsgHash); 
        } else {
            executed[finalMsgHash] = true;
        } 
        
        address signer_ = finalMsgHash.recover(_signature);

        if(signer_ != signer){
            revert IBKErrors.InvalidSigner(); 
        }
    }
}
