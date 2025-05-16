// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameState} from "../src/GameState.sol";

contract GameStateTest is Test {
    GameState public gameState;
    address public alice;
    address public bob;

    function setUp() public {
        gameState = new GameState();
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
    }  

    function testCreateItem() public {
        uint256 itemId = gameState.createItem("Sword", 100, 10, 5);
        GameState.Item memory item = gameState.getItem(itemId);
        assertEq(item.name, "Sword");
        assertEq(item.price, 100);
        assertEq(item.attack, 10);
        assertEq(item.defense, 5);
        assertEq(item.owner, address(0));
        assertTrue(item.forSale);
    }
    function testBuyItem() public {
        uint256 itemId = gameState.createItem("Shield", 200, 5, 10);
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        gameState.buyItem{value: 1 ether}(itemId);
        GameState.Item memory item = gameState.getItem(itemId);
        assertEq(item.owner, alice);
        vm.stopPrank();
    }
    function testBuyItemFromPlayer() public {
        uint256 itemId = gameState.createItem("Axe", 150, 15, 3);
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        gameState.buyItem{value: 1 ether}(itemId);
        gameState.setItemForSale(itemId, true);
        vm.stopPrank();
        vm.deal(bob, 1 ether);
        vm.startPrank(bob);
        gameState.buyItemFromPlayer{value: 1 ether}(itemId);
        GameState.Item memory item = gameState.getItem(itemId);
        assertEq(item.owner, bob);
        assertEq(item.forSale, false);
        vm.stopPrank();
    }
}
