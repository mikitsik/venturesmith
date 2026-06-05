// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VentureSmithRegistry {
    enum Status {
        Requested,
        Completed,
        Failed
    }

    struct ScoutRun {
        address founder;
        bytes32 profileHash;
        string goal;
        string metadataURI;
        Status status;
        uint16 score;
        bytes32 resultHash;
        uint256 createdAt;
        uint256 completedAt;
    }

    address public owner;
    address public agentExecutor;
    uint256 public nextRunId = 1;

    mapping(uint256 => ScoutRun) private scoutRuns;

    event ScoutRunCreated(
        uint256 indexed runId,
        address indexed founder,
        bytes32 indexed profileHash,
        string goal,
        string metadataURI
    );

    event ScoutRunCompleted(
        uint256 indexed runId,
        address indexed founder,
        uint16 score,
        bytes32 indexed resultHash
    );

    event ScoutRunFailed(
        uint256 indexed runId,
        address indexed founder,
        bytes32 indexed resultHash
    );

    event AgentExecutorUpdated(address indexed oldExecutor, address indexed newExecutor);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAgentExecutor() {
        require(msg.sender == agentExecutor, "Not agent executor");
        _;
    }

    constructor(address initialAgentExecutor) {
        owner = msg.sender;
        agentExecutor = initialAgentExecutor;
    }

    function setAgentExecutor(address newAgentExecutor) external onlyOwner {
        require(newAgentExecutor != address(0), "Zero executor");

        address oldExecutor = agentExecutor;
        agentExecutor = newAgentExecutor;

        emit AgentExecutorUpdated(oldExecutor, newAgentExecutor);
    }

    function createScoutRun(
        bytes32 profileHash,
        string calldata goal,
        string calldata metadataURI
    ) external returns (uint256 runId) {
        require(bytes(goal).length > 0, "Empty goal");

        runId = nextRunId;
        nextRunId += 1;

        scoutRuns[runId] = ScoutRun({
            founder: msg.sender,
            profileHash: profileHash,
            goal: goal,
            metadataURI: metadataURI,
            status: Status.Requested,
            score: 0,
            resultHash: bytes32(0),
            createdAt: block.timestamp,
            completedAt: 0
        });

        emit ScoutRunCreated(runId, msg.sender, profileHash, goal, metadataURI);
    }

    function submitScoutResult(
        uint256 runId,
        uint16 score,
        bytes32 resultHash
    ) external onlyAgentExecutor {
        ScoutRun storage run = scoutRuns[runId];

        require(run.founder != address(0), "Run not found");
        require(run.status == Status.Requested, "Run not active");
        require(score <= 100, "Invalid score");
        require(resultHash != bytes32(0), "Empty result hash");

        run.status = Status.Completed;
        run.score = score;
        run.resultHash = resultHash;
        run.completedAt = block.timestamp;

        emit ScoutRunCompleted(runId, run.founder, score, resultHash);
    }

    function markScoutRunFailed(
        uint256 runId,
        bytes32 resultHash
    ) external onlyAgentExecutor {
        ScoutRun storage run = scoutRuns[runId];

        require(run.founder != address(0), "Run not found");
        require(run.status == Status.Requested, "Run not active");

        run.status = Status.Failed;
        run.resultHash = resultHash;
        run.completedAt = block.timestamp;

        emit ScoutRunFailed(runId, run.founder, resultHash);
    }

    function getScoutRun(uint256 runId) external view returns (ScoutRun memory) {
        require(scoutRuns[runId].founder != address(0), "Run not found");
        return scoutRuns[runId];
    }
}
