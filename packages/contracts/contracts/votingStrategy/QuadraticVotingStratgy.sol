// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IVotingStrategy.sol";

contract QuadraticVotingStrategy is IVotingStrategy, ReentrancyGuard, ERC721 {
    struct Vote {
        uint256 weight;
        uint256 amount;
    }
    struct Set {
        uint256[] ids;
        mapping(uint256 => bool) is_in;
    }

    uint256 public immutable VOTE_CREDITS_PER_BADGE;
    uint256 public immutable CREDIT_COST_PER_VOTE;

    Set tallySet;
    bytes public finalTally;
    bytes[] public votesData;
    uint256 public voterCount;

    mapping(address => uint256) public credits;
    mapping(uint256 => Vote) public votes;

    constructor(uint256 _credits, uint256 _voteCost) ERC721("VOTE", "VOTE") {
        VOTE_CREDITS_PER_BADGE = _credits;
        CREDIT_COST_PER_VOTE = _voteCost;
    }

    function register(address registrant) public {
        _mint(registrant, voterCount++);
        credits[registrant] = VOTE_CREDITS_PER_BADGE * balanceOf(registrant);
    }

    function vote(bytes[] calldata encodedVotes, address voterAddress)
        external
        override
        nonReentrant
    {
        require(balanceOf(voterAddress) > 0, "NOT_REGISTERED");
        require(credits[voterAddress] > 0, "NO_CREDITS");
        for (uint256 i = 0; i < encodedVotes.length; i++) {
            (uint256 id, uint256 amount) = abi.decode(
                encodedVotes[i],
                (uint256, uint256)
            );
            uint256 cost = amount * amount * CREDIT_COST_PER_VOTE;
            require(cost <= credits[voterAddress], "INSUFFICIENT_CREDITS");
            credits[voterAddress] -= cost;
            votesData.push(abi.encode(id, cost, amount));
        }
    }

    function tally() external nonReentrant {
        for (uint256 i = 0; i < votesData.length; i++) {
            (uint256 id, uint256 weight, uint256 amount) = abi.decode(
                votesData[i],
                (uint256, uint256, uint256)
            );
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

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        revert("*~ SOULBOUND ~*");
    }
}
