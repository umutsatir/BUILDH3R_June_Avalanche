// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";
import "./ISHA256.sol";

contract ReceiverOnSubnet is ITeleporterReceiver {
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);
    ISHA256 sha256Contract = ISHA256(0x0300000000000000000000000000000000000001);

    bytes32 public lastHash;

    function receiveTeleporterMessage(bytes32, address, bytes calldata message) external {
        // Only the Teleporter receiver can deliver a message.
        require(msg.sender == address(messenger), "ReceiverOnSubnet: unauthorized TeleporterMessenger");

        computeHash(message_to_hash);
    }
}

contract ReceiverOnSubnet is ITeleporterReceiver {
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);
    ISHA256 sha256Contract = ISHA256(0x0300000000000000000000000000000000000001);

    function receiveTeleporterMessage(bytes32, address originSenderAddress, bytes calldata message) external {
        // Only the Teleporter receiver can deliver a message.
        require(msg.sender == address(messenger), "ReceiverOnSubnet: unauthorized TeleporterMessenger");

        // Send Roundtrip message back to sender
        string calldata message_to_hash = abi.decode(message, (string));
        bytes32 response = computeHash(message_to_hash);

        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                // Blockchain ID of C-Chain
                destinationBlockchainID: 0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6acd0021cac10d5,
                destinationAddress: originSenderAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: abi.encode(response)
            })
        );
    }

    // Function to interact with the deployed precompiled contract
    function computeHash(string memory _value) public returns (bytes32) {
        bytes32 sha256hash = sha256Contract.hashWithSHA256(_value);
        return sha256hash;
    }
}