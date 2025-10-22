// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./HashCommitCheckVerifier.sol"; // nếu file riêng

contract OnchainVerifier is Groth16Verifier {
    event ProofVerified(address indexed sender, bool isValid);

    // Lưu lại proof đã xác minh (tuỳ chọn)
    mapping(bytes32 => bool) public verifiedProofs;

    function submitProof(
        uint[2] calldata a,
        uint[2][2] calldata b,
        uint[2] calldata c,
        uint[1] calldata inputSignals
    ) public returns (bool) {
        bool ok = Groth16Verifier.verifyProof(a, b, c, inputSignals);
        require(ok, " Invalid proof");

        // Ghi dấu hash proof để đảm bảo không verify lại
        bytes32 proofHash = keccak256(abi.encode(a, b, c, inputSignals));
        verifiedProofs[proofHash] = true;

        emit ProofVerified(msg.sender, ok);
        return ok;
    }
}
