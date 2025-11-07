// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./HashCommitCheckVerifier.sol"; // file do snarkjs export ra (Groth16Verifier)

contract OnchainHashVerifier is Groth16Verifier{
    event ProofVerified(address indexed sender, bool isValid, bytes32 proofHash);

    // 🧩 Aggregator chỉ cần gọi để nộp proof, không cần lưu lại mapping
    function submitHashProof(   
        uint[2] calldata a,
        uint[2][2] calldata b,
        uint[2] calldata c,
        uint[1] calldata inputSignals
    ) external returns (bool) {
        bool ok = _safeVerifyHashProof(a, b, c, inputSignals);

        require(ok, "Invalid proof");

        // ✅ Tạo hash proof chỉ để ghi log (audit off-chain), không lưu on-chain
        bytes32 proofHash = keccak256(abi.encode(a, b, c, inputSignals));

        emit ProofVerified(msg.sender, ok, proofHash);
        return ok;
    }

    // ✅ Hàm xác minh proof nội bộ an toàn, không revert nếu verifier lỗi
    function _safeVerifyHashProof(
        uint[2] memory pA,
        uint[2][2] memory pB,
        uint[2] memory pC,
        uint[1] memory pubSignals
    ) internal view returns (bool) {
        (bool success, bytes memory result) = address(this).staticcall(
            abi.encodeWithSignature(
                "verifyProof(uint256[2],uint256[2][2],uint256[2],uint256[1])",
                pA, pB, pC, pubSignals
            )
        );

        // Nếu verifier lỗi (input sai, thiếu dữ liệu, gas lỗi) → trả false, không revert
        if (!success || result.length < 32) return false;

        // Giải mã kết quả bool trả về từ Groth16Verifier
        return abi.decode(result, (bool));
    }
}
