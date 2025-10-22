// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    address public admin;

    struct ElectionInfo {
        string electionId;
        string name;
        string startDate;
        string endDate;
        string status; // "active" hoặc "ended"
        bytes32 merkleRoot;
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct VoteRecord {
        bytes32 nullifier; // Hash(sk)
        bytes32 hashCipher; // mã hóa phiếu bầu
        uint timestamp;    // thời gian vote
    }

    ElectionInfo public info;
    Candidate[] public candidates;
    bytes public epk; // public encryption key (sau này từ DKG)

    mapping(bytes32 => VoteRecord) public votes;   // nullifier -> phiếu cuối cùng
    bytes32[] public nullifiers;                   // danh sách nullifier (ẩn danh)

    event ElectionCreated(string electionId, string name);
    event MerkleRootUpdated(bytes32 root);
    event CandidateAdded(uint id, string name);
    event EpkPublished(bytes epk);
    event VotePublished(bytes32 indexed nullifier, bytes32 indexed hashCipher, uint timestamp);
    constructor() {
        admin = msg.sender;
    }
    

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    function setElectionInfo(
        string memory _id,
        string memory _name,
        string memory _start,
        string memory _end
    ) public onlyAdmin {
        info = ElectionInfo(_id, _name, _start, _end, "active", 0x0);
        emit ElectionCreated(_id, _name);
    }

    function setMerkleRoot(bytes32 _root) external onlyAdmin {
        info.merkleRoot = _root;
        emit MerkleRootUpdated(_root);
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidates.push(Candidate(candidates.length + 1, _name, 0));
        emit CandidateAdded(candidates.length, _name);
    }

    function publishEpk(bytes calldata _epk) external onlyAdmin {
        epk = _epk;
        emit EpkPublished(_epk);
    }

    // Getter cho số lượng ứng cử viên
    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }

    mapping(bytes32 => bool) public isNullifierUsed;

    function submitVote(bytes32 _nullifier, bytes32 _hashCipher) external {
        // 1️⃣ Kiểm tra trạng thái cuộc bầu cử
        require(
            keccak256(abi.encodePacked(info.status)) == keccak256("active"),
            "Election not active"
        );

        // 2️⃣ Chống double-vote
        require(!isNullifierUsed[_nullifier], "Double vote detected");

        // 3️⃣ Ghi nhận phiếu mới (chỉ hash)
        votes[_nullifier] = VoteRecord(_nullifier, _hashCipher, block.timestamp);
        isNullifierUsed[_nullifier] = true;
        nullifiers.push(_nullifier);

        // 4️⃣ Phát event để Aggregator có thể query hashCipher
        emit VotePublished(_nullifier, _hashCipher, block.timestamp);
    }

    function getNullifierCount() public view returns (uint) {
        return nullifiers.length;
    }

    // 🔒 BE publish hashOnChain sau khi hết hạn bỏ phiếu
    bytes32 public hashOnChain;
    event HashOnChainPublished(bytes32 hashOnChain);

    function publishHashOnChain(bytes32 _hashOnChain) external onlyAdmin {
        require(hashOnChain == 0x0, "Already published");
        hashOnChain = _hashOnChain;
        emit HashOnChainPublished(_hashOnChain);
    }

    // 📦 Aggregator nộp kết quả tổng hợp
    bytes public finalCipher;
    bytes32 public tallyProofHash;
    event TallySubmitted(bytes C_total, bytes32 proofHash);

    function submitTally(bytes calldata _C_total, bytes32 _proofHash) external onlyAdmin {
        require(hashOnChain != 0x0, "hashOnChain not set");
        finalCipher = _C_total;
        tallyProofHash = _proofHash;
        emit TallySubmitted(_C_total, _proofHash);
    }
}
