import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { deployContract } from "ethereum-waffle";
import { isAddress } from "ethers/lib/utils";
import { artifacts, ethers } from "hardhat";
import { Artifact } from "hardhat/types";
import { QuadraticVotingStrategy } from "../typechain";
import { BigNumber, utils } from "ethers";

describe("QuadraticVotingStrategy", function () {

  let user: SignerWithAddress;
  let QuadraticVotingStrategy: QuadraticVotingStrategy;
  let QuadraticVotingStrategyArtifact: Artifact;


  describe('constructor', () => {

    it('deploys properly', async () => {

      [user] = await ethers.getSigners();

      QuadraticVotingStrategyArtifact = await artifacts.readArtifact('QuadraticVotingStrategy');
      QuadraticVotingStrategy = <QuadraticVotingStrategy>await deployContract(user, QuadraticVotingStrategyArtifact, []);

      // Verify deploy
      expect(isAddress(QuadraticVotingStrategy.address), 'Failed to deploy QuadraticVotingStrategy').to.be.true;
    });
  })


  describe('core functions', () => {

    before(async () => {
      [user] = await ethers.getSigners();

      // Deploy QuadraticVotingStrategy contract
      QuadraticVotingStrategyArtifact = await artifacts.readArtifact('QuadraticVotingStrategy');
      QuadraticVotingStrategy = <QuadraticVotingStrategy>await deployContract(user, QuadraticVotingStrategyArtifact, []);
    });

  })

});
