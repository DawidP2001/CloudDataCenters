const { ethers } = require("ethers");
const AWS = require("aws-sdk");

// AWS Region setup
AWS.config.update({ region: "eu-north-1" });

// DynamoDB client
const dynamoDb = new AWS.DynamoDB.DocumentClient();

// Ethereum provider (Sepolia via Infura)
const provider = new ethers.JsonRpcProvider("https://sepolia.infura.io/v3/12be543cebb045c3b94f5820ef89dc7b");

// Contract address and ABI
const contractAddress = "0x80a712A480292f5EFd3aBb387B6fC56d9B8fdf29";
const abi = [
    "event ItemCreated(uint256 indexed itemId, string name, uint256 price, uint256 attack, uint256 defense)"
];

// Setup contract
const contract = new ethers.Contract(contractAddress, abi, provider);
console.log("Listening for ItemCreated events...");

// Event listener
contract.on("ItemCreated", async (itemId, name, price, attack, defense) => {
    console.log(`ItemCreated event: ID=${itemId}, Name=${name}, Price=${price}, Attack=${attack}, Defense=${defense}`);

    const params = {
        TableName: "itemEvents",
        Item: {
            itemId: itemId.toString(),
            name: name,
            price: price.toString(),
            attack: attack.toString(),
            defense: defense.toString(),
            timestamp: new Date().toISOString()
        }
    };

    try {
        await dynamoDb.put(params).promise();
        console.log("Stored item event in DynamoDB.");
    } catch (err) {
        console.error("Error storing event in DynamoDB:", err);
    }
});