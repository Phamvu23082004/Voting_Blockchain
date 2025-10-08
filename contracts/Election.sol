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

    ElectionInfo public info;
    Candidate[] public candidates;
    bytes public epk; // public encryption key (sau này từ DKG)

    event ElectionCreated(string electionId, string name);
    event MerkleRootUpdated(bytes32 root);
    event CandidateAdded(uint id, string name);
    event EpkPublished(bytes epk);

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
        info.status = "ended";
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
}
