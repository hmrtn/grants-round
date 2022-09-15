// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IVotingStrategy.sol";

contract QuadraticVotingStrategy is IVotingStrategy, ReentrancyGuard, ERC721 {
    /**
     * @notice Vote structure.
     * @param weight Weight of the votes (# votes ^ 2).
     * @param amount Amount of votes spent
     */
    struct Vote {
        uint256 weight;
        uint256 amount;
    }

    /**
     * @notice Set data structure.
     */
    struct Set {
        uint256[] ids;
        mapping(uint256 => bool) is_in;
    }

    /**
     * @notice A scalar multiplier of the initial voice credits per ERC721 token per user.
     */
    uint256 public immutable VOTE_CREDITS_PER_BADGE;

    /**
     * @notice The voice credit cost per vote.
     */
    uint256 public immutable CREDIT_COST_PER_VOTE;

    /**
     * @notice A unique set of the the tally
     */
    Set tallySet;

    /**
     * @notice The tally count.
     */
    bytes public finalTally;

    /**
     * @notice The vote byte data.
     */
    bytes[] public votesData;

    /**
     * @notice The number of voters.
     */
    uint256 public voterCount;

    /**
     * @notice Mapping of voter to their avaliable credit balance.
     */
    mapping(address => uint256) public creditBalance;

    /**
     * @notice Mapping of vote ID to vote data.
     */
    mapping(uint256 => Vote) public votes;

    /**
     * @param _credits The initial voice credits per ERC721 token per user.
     * @param _voteCost The voice credit cost per vote.
     */
    constructor(uint256 _credits, uint256 _voteCost) ERC721("VOTE", "VOTE") {
        // TODO: Add an allow list of registrants
        VOTE_CREDITS_PER_BADGE = _credits;
        CREDIT_COST_PER_VOTE = _voteCost;
    }

    /**
     * @notice Register the voter.
     * @param registrant The address of the voter to register.
     * @dev This function effectively mints a new ERC721 token to the registrant.
     */
    function register(address registrant) public {
        // TODO: Check if registrant is in allow list
        _mint(registrant, voterCount++);
        creditBalance[registrant] =
            VOTE_CREDITS_PER_BADGE *
            balanceOf(registrant);
    }

    /**
     * @notice Vote on a grant.
     * @param encodedVotes The encoded votes.
     * @param voterAddress The address of the voter.
     * @dev The encoded votes are a list of bytes, each of which a tuple of
     * (grantId, voteAmount). Amount is the number of votes to cast, which will
     * deduct the squared amount from the voters credit balance.
     */
    function vote(bytes[] calldata encodedVotes, address voterAddress)
        external
        override
        nonReentrant
    {
        // TODO: Add an allow list of votable IDs and prevent voting on invalid IDs
        // Q: Do we want to store a the users vote history?
        require(balanceOf(voterAddress) > 0, "NOT_REGISTERED");
        require(creditBalance[voterAddress] > 0, "NO_CREDITS");
        for (uint256 i = 0; i < encodedVotes.length; i++) {
            (uint256 id, uint256 amount) = abi.decode(
                encodedVotes[i],
                (uint256, uint256)
            );
            uint256 weight = amount * amount * CREDIT_COST_PER_VOTE;
            require(
                weight <= creditBalance[voterAddress],
                "INSUFFICIENT_CREDITS"
            );
            creditBalance[voterAddress] -= weight;
            // Push the encoded vote to voteData byte array
            votesData.push(abi.encode(id, weight, amount));
        }
    }

    /**
     * @notice Tally the votes.
     * @dev This function will calculate and store the a tally of the votes.
     * This can be called at any time by anyone.
     */
    function tally() external nonReentrant {
        // For every vote, decode the vote data, add the vote weight and amount to IDs vote data
        for (uint256 i = 0; i < votesData.length; i++) {
            (uint256 id, uint256 weight, uint256 amount) = abi.decode(
                votesData[i],
                (uint256, uint256, uint256)
            );
            // If the ID is not in the set, it has not been voted for yet. Add it to the set storage and continue for future votes.
            if (!tallySet.is_in[id]) {
                tallySet.ids.push(id);
                tallySet.is_in[id] = true;
            }
            votes[id].weight += weight;
            votes[id].amount += amount;
        }

        uint256[] memory ids = new uint256[](tallySet.ids.length);
        uint256[] memory weights = new uint256[](tallySet.ids.length);
        uint256[] memory amounts = new uint256[](tallySet.ids.length);

        for (uint256 j = 0; j < tallySet.ids.length; j++) {
            ids[j] = tallySet.ids[j];
            weights[j] = votes[tallySet.ids[j]].weight;
            amounts[j] = votes[tallySet.ids[j]].amount;
        }

        finalTally = abi.encode(ids, weights, amounts);
    }

    /**
     * @dev Make the ERC721 token non-transferable.
     */
    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        revert("~* SOULBOUND *~");
    }
}
