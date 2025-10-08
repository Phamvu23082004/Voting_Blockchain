// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct TrusteeShare {
        address trustee;
        bytes publicShare;
    }

    address public CA;
    mapping(address => bytes) public trusteeShares;
    address[] public trusteeList;

    event TrusteeRegistered(address trustee, bytes publicShare);

    constructor() {
        CA = msg.sender;
    }

    modifier onlyCA() {
        require(msg.sender == CA, "Only CA can call");
        _;
    }

    function registerShare(address trustee, bytes calldata publicShare) external onlyCA {
        trusteeShares[trustee] = publicShare;
        trusteeList.push(trustee);
        emit TrusteeRegistered(trustee, publicShare);
    }

    function getTrustees() external view returns (address[] memory) {
        return trusteeList;
    }
}
