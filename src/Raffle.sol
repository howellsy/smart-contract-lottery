//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A Raffle contract
 * @author howellsy
 * @notice This contract is for creating a raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2 {
    enum RaffleState {
        OPEN,
        CALCULATING_WINNER
    }

    uint32 private constant NUM_WORDS = 1;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    uint32 private immutable i_callbackGasLimit;
    uint256 private immutable i_entranceFee;
    bytes32 private immutable i_gasLane;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    uint64 private immutable i_subscriptionId;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    uint256 private s_lastTimestamp;
    address payable[] private s_players;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    event EnteredRaffle(address indexed player);
    event RequestSent(uint256 indexed requestId, uint32 numWords);
    event PickedWinner(address indexed winner);

    error Raffle__NotEnoughEthSent(uint256 required, uint256 sent);
    error Raffle__RaffleNotOpen();
    error Raffle__TransferFailed(address to, uint256 amount);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_callbackGasLimit = callbackGasLimit;
        i_entranceFee = entranceFee;
        i_gasLane = gasLane;
        i_interval = interval;
        i_subscriptionId = subscriptionId;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);

        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent(i_entranceFee, msg.value);
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() external {
        if ((block.timestamp - s_lastTimestamp) < i_interval) {
            revert();
        }

        s_raffleState = RaffleState.CALCULATING_WINNER;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS
        );

        emit RequestSent(requestId, NUM_WORDS);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        uint256 balance = address(this).balance;
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;

        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;

        emit PickedWinner(winner);

        (bool success,) = winner.call{value: balance}("");
        if (!success) {
            revert Raffle__TransferFailed(winner, address(this).balance);
        }
    }

    /**
     * Getter functions
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
