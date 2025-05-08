const { ethers } = require("ethers");
const AWS = require("aws-sdk");

// AWS Region setup
AWS.config.update({ region: "eu-north-1" });

// DynamoDB client
const dynamoDb = new AWS.DynamoDB.DocumentClient();

// Ethereum provider (Sepolia via Infura)
const provider = new ethers.JsonRpcProvider("https://sepolia.infura.io/v3/12be543cebb045c3b94f5820ef89dc7b");

// Contract address and ABI
const contractAddress = "0x9d58134Dd3fba0B3dB67264E73195186E28BafA7";
const abi = [
    "event VaultAdded(uint256 vaultId, address owner)"
];

// This section listens for sepolia vaultAdded events 
const contract = new ethers.Contract(contractAddress, abi, provider);
console.log("Searching for events");
contract.on("VaultAdded", async (vaultId, owner) => {
    console.log(`VaultAdded event: Vault ID ${vaultId.toString()}, Owner ${owner}`);

    const params = {
        TableName: "UserVaults",
        Item: {
            vaultId: vaultId.toString(),
            ownerAddress: owner
        }
    };

    // Store the event in DynamoDB or error handling
    try {
        await dynamoDb.put(params).promise();
        console.log("Successfully stored event in DynamoDB:", params.Item);
    } catch (err) {
        console.error("Error with storing data", err);
    }
});
