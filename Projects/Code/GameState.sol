// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract GameState {

    struct Item {
        uint256 id;
        string name;
        uint256 price;
        uint256 attack;
        uint256 defense;
        address owner;
        bool forSale;
    }

    event ItemBought(
        address player,
        uint256 quantity
    );
    event ItemCreated(
        uint256 indexed itemId,
        string name,
        uint256 price,
        uint256 attack,
        uint256 defense
    );

    Item[] public itemsList;

    modifier onlyDeveloper() {
        address Developer = 0x1234567890123456789012345678901234567890; // Replace with the actual developer address
        Developer = msg.sender; // This here just for the sake of testing
        require(msg.sender == Developer, "Not the contract owner");
        _;
    }
    modifier onlyPlayer(uint256 itemId) {
        require(msg.sender == itemsList[itemId].owner, "Not the player");
        _;
    }

    function createItem(
        string memory name,
        uint256 price,
        uint256 attack,
        uint256 defense
    ) public onlyDeveloper returns (uint256 itemId){
        itemId = itemsList.length;
        Item memory newItem = Item({
            id: itemId,
            name: name,
            price: price,
            attack: attack,
            defense: defense,
            owner: address(0),
            forSale: true
        });
        itemsList.push(newItem);
        emit ItemCreated(itemId, name, price, attack, defense);
    }
    function buyItem(uint256 itemId) public payable {
        require(itemId < itemsList.length, "Item does not exist");
        Item storage item = itemsList[itemId];
        require(msg.value >= item.price, "Not enough Ether sent");
        require(item.owner == address(0), "Item already owned");

        if (msg.value > item.price) {
            payable(msg.sender).transfer(msg.value - item.price);
        }
        // Below section I send the money to the developer in this case I set it as the sender
        // just for the sake of testing
        address developer = msg.sender;
        payable(developer).transfer(item.price);
        item.owner = msg.sender;
        item.forSale = false;
        emit ItemBought(msg.sender, itemId);
    }
    function buyItemFromPlayer(uint256 itemId) public payable {
        require(itemId < itemsList.length, "Item does not exist");

        Item storage item = itemsList[itemId];

        address seller = item.owner;
        require(seller != address(0), "Item not owned by anyone");
        require(item.forSale == true, "Item not for sale");
        require(seller != msg.sender, "Cannot buy your own item");
        require(msg.value >= item.price, "Not enough Ether sent");

        /* Here the service fee would be deducted

        This section removed for the sake of the experiment
        (bool platformSuccess, ) = payable(developer).call{value: platformFee}("");
        equire(platformSuccess, "Payment to platform failed");
        
        */
        // Refund excess Ether
        if (msg.value > item.price) {
            payable(msg.sender).transfer(msg.value - item.price);
        }
        // Pay the seller
        payable(msg.sender).transfer(item.price);
        // Transfer ownership
        item.owner = msg.sender;
        item.forSale = false;
        emit ItemBought(msg.sender, itemId);
    }   

    function getItem(uint256 itemId) public view returns (Item memory) {
        require(itemId < itemsList.length, "Item does not exist");
        return itemsList[itemId];
    }
    function setItemPrice(uint256 itemId, uint256 newPrice) public onlyPlayer(itemId) {
        require(itemId < itemsList.length, "Item does not exist");
        Item storage item = itemsList[itemId];
        item.price = newPrice;
    }
    function setItemForSale(uint256 itemId, bool forSale) public onlyPlayer(itemId) {
        require(itemId < itemsList.length, "Item does not exist");
        Item storage item = itemsList[itemId];
        item.forSale = forSale;
    }
    function getItems() public view returns (Item[] memory) {
        return itemsList;
    }
    function getItemCount() public view returns (uint256) {
        return itemsList.length;
    }
}
