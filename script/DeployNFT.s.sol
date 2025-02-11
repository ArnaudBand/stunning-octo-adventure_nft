// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "../lib/forge-std/src/Script.sol";
import {NFT} from "../src/NFT.sol";

contract DeployNFT is Script {
    NFT public nft;

    function run() public returns (NFT) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        address recipient = vm.envAddress("RECIPIENT_ADDRESS");
        string memory uri = vm.envString("TOKEN_URI");

        vm.startBroadcast(deployerPrivateKey);
        nft = NFT(contractAddress);
        nft.mint(recipient, uri);
        vm.stopBroadcast();
        return nft;
    }
}
