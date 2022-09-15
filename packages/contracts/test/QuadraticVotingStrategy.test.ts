import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { deployContract } from "ethereum-waffle";
import { isAddress } from "ethers/lib/utils";
import { artifacts, ethers } from "hardhat";
import { Artifact } from "hardhat/types";
import { QuadraticVotingStrategy } from "../typechain";
import { BigNumber, utils } from "ethers";

describe("QuadraticVotingStrategy", function () {
  let user0: SignerWithAddress;
  let user1: SignerWithAddress;
  let QuadraticVotingStrategy: QuadraticVotingStrategy;
  let QuadraticVotingStrategyArtifact: Artifact;

  describe("constructor", () => {
    it("deploys properly", async () => {
      [user0, user1] = await ethers.getSigners();

      QuadraticVotingStrategyArtifact = await artifacts.readArtifact(
        "QuadraticVotingStrategy"
      );
      QuadraticVotingStrategy = <QuadraticVotingStrategy>(
        await deployContract(user0, QuadraticVotingStrategyArtifact, [1000, 1])
      );

      // Verify deploy
      // eslint-disable-next-line no-unused-expressions
      expect(
        isAddress(QuadraticVotingStrategy.address),
        "Failed to deploy QuadraticVotingStrategy"
      ).to.be.true;
    });
  });

  describe("core functions", () => {
    before(async () => {
      [user0, user1] = await ethers.getSigners();

      // Deploy QuadraticVotingStrategy contract
      QuadraticVotingStrategyArtifact = await artifacts.readArtifact(
        "QuadraticVotingStrategy"
      );
      QuadraticVotingStrategy = <QuadraticVotingStrategy>(
        await deployContract(user0, QuadraticVotingStrategyArtifact, [1000, 1])
      );
    });

    it("allows a user0 to register", async () => {
      const user0Address = await user0.getAddress();
      await QuadraticVotingStrategy.register(user0Address);
      const balance = await QuadraticVotingStrategy.balanceOf(user0Address);
      expect(balance).to.be.equal(1);
    });

    it("allows a user0 to vote", async () => {
      const user0Address = await user0.getAddress();
      const encoder = new utils.AbiCoder();
      const encodeVotes = (id: number, amount: number): string => {
        return encoder.encode(["tuple(uint256, uint256)"], [[id, amount]]);
      };
      // [id, amount]
      const encodedVotes = [
        [3, 22],
        [1, 19],
        [9, 9],
      ].map((vote: number[]) => encodeVotes(vote[0], vote[1]));
      await QuadraticVotingStrategy.vote(encodedVotes, user0Address);
      const credits = await QuadraticVotingStrategy.creditBalance(user0Address);
      // expect balance to be 1000 - 9^2 - 17^2 - 25^2
      expect(credits).to.equal(1000 - 9 ** 2 - 19 ** 2 - 22 ** 2);
    });

    it("allows a user1 to vote", async () => {
      const user1Address = await user1.getAddress();
      await QuadraticVotingStrategy.register(user1Address); // register
      const encoder = new utils.AbiCoder();
      const encodeVotes = (id: number, amount: number): string => {
        return encoder.encode(["tuple(uint256, uint256)"], [[id, amount]]);
      };
      // [id, amount]
      const encodedVotes = [
        [3, 9],
        [1, 4],
        [9, 17],
      ].map((vote: number[]) => encodeVotes(vote[0], vote[1]));
      await QuadraticVotingStrategy.vote(encodedVotes, user1Address);
      const credits = await QuadraticVotingStrategy.creditBalance(user1Address);
      // expect balance to be 1000 - 9^2 - 4^2 - 17^2
      expect(credits).to.equal(1000 - 9 ** 2 - 4 ** 2 - 17 ** 2);
    });

    it("should tally votes", async () => {
      const encoder = new utils.AbiCoder();
      await QuadraticVotingStrategy.tally();
      const finalTally = await QuadraticVotingStrategy.finalTally();
      const [ids, weights, amounts] = encoder.decode(
        ["uint256[]", "uint256[]", "uint256[]"],
        finalTally
      );
      expect(
        ids.map((i: BigNumber) => {
          return i.toString();
        })
      ).to.deep.equal(["3", "1", "9"]);
      expect(
        weights.map((w: BigNumber) => {
          return w.toString();
        })
      ).to.deep.equal(["565", "377", "370"]);
      expect(
        amounts.map((a: BigNumber) => {
          return a.toString();
        })
      ).to.deep.equal(["31", "23", "26"]);
    });
  });
});
