// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IVotingStrategy.sol";
import "../utils/MetaPtr.sol";

contract QuadraticVotingStrategy is IVotingStrategy, ReentrancyGuard, ERC721 {
    uint256 public immutable CREDITS_PER_BADGE;
    uint256 public immutable CREDIT_COST;
    uint256 public voterCount;
    uint256 public totalWeight;
    mapping(address => uint256) public credits;
    mapping(uint256 => uint256) public votes;
    MetaPtr public projectsMetaPtr;
    mapping(uint256 => uint256) public scores;

    constructor() ERC721("VOTE", "VOTE") {
        uint256  _credits = 1000;
        CREDITS_PER_BADGE = _credits;
        CREDIT_COST = 1e18 / _credits;
    }

    function register(address registrant) public {
        _mint(registrant, voterCount++);
        credits[registrant] = CREDITS_PER_BADGE * balanceOf(registrant);
    }

    // hack 
    uint256[] public hack; // A list of projects will be from the RoundManager - somehow?
    function vote(bytes[] calldata encodedVotes, address voterAddress)
        external
        override
        nonReentrant
    {
        require(balanceOf(voterAddress) > 0, "NOT_REGISTERED");
        require(credits[voterAddress] > 0, "NO_CREDITS");
        for (uint256 i = 0; i < encodedVotes.length; i++) {
            (uint256 grantId, uint256 amount) = abi.decode(
                encodedVotes[i],
                (uint256, uint256)
            );
            hack.push(grantId);
            uint256 cost = amount * amount;
            require(cost <= credits[voterAddress], "INSUFFICIENT_CREDITS");
            credits[voterAddress] -= cost;
            votes[grantId] += amount;
            totalWeight += cost;
        }
    }

    function tally() external nonReentrant returns(uint256[] memory) {
        uint256[] memory x;
        for (uint256 i = 0; i < hack.length; i++) {
            scores[hack[i]] = votes[hack[i]] / totalWeight;
            x[i] = scores[hack[i]];
        }
        return x; 
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        revert("Badge: SOULBOUND");
    }
}
