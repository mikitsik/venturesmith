const hre = require("hardhat");

const CALLBACK_ADDRESS = process.env.CALLBACK_ADDRESS;

const receiverAbi = [
  "function lastData() view returns (bytes)"
];

const agentAbi = [
  "function fetchString(string url,string selector) returns (string result)"
];

async function main() {
  if (!CALLBACK_ADDRESS) {
    throw new Error("CALLBACK_ADDRESS is missing");
  }

  const [signer] = await hre.ethers.getSigners();

  const receiver = new hre.ethers.Contract(
    CALLBACK_ADDRESS,
    receiverAbi,
    signer
  );

  const rawData = await receiver.lastData();

  console.log("Callback address:", CALLBACK_ADDRESS);
  console.log("Raw callback data:", rawData);

  const decoded = decodeCallbackData(rawData);

  console.log("Request ID:", decoded.requestId.toString());
  console.log("Status:", decoded.status.toString());
  console.log("Responses:", decoded.responses.length);

  const agentInterface = new hre.ethers.Interface(agentAbi);

  decoded.responses.forEach((response, index) => {
    console.log(`\nResponse #${index + 1}`);
    console.log("Validator:", response.validator);
    console.log("Status:", response.status.toString());
    console.log("Result bytes:", response.result);

    const [result] = agentInterface.decodeFunctionResult(
      "fetchString",
      response.result
    );

    console.log("Decoded result:", result);
  });
}

function decodeCallbackData(rawData) {
  const abiCoder = hre.ethers.AbiCoder.defaultAbiCoder();

  // First 4 bytes are callback selector 0x00000000.
  const encodedArgs = `0x${rawData.slice(10)}`;

  const responseType =
    "tuple(address validator,bytes result,uint8 status,uint256 receipt,uint256 timestamp,uint256 executionCost)";

  const requestType =
    `tuple(uint256 id,address requester,address callbackAddress,bytes4 callbackSelector,address[] subcommittee,${responseType}[] responses,uint256 responseCount,uint256 failureCount,uint256 threshold,uint256 createdAt,uint256 deadline,uint8 status,uint8 consensusType,uint256 remainingBudget,uint256 perAgentBudget)`;

  const [requestId, responses, status, request] = abiCoder.decode(
    [
      "uint256",
      `${responseType}[]`,
      "uint8",
      requestType
    ],
    encodedArgs
  );

  return {
    requestId,
    responses,
    status,
    request
  };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
