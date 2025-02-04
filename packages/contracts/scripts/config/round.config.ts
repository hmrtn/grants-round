// Update this file any time a new contract has been deployed
type RoundParams = {
  roundImplementationContract: string;
  roundFactoryContract: string;
  bulkVotingStrategyContract: string;
  roundContract ?: string;
};

type DeployParams = Record<string, RoundParams>;

export const roundParams: DeployParams = {
  "goerli": {
    roundFactoryContract: '0x89f01CD69087669f8e49F6FB8aD475F622Ac8791',
    roundImplementationContract: '0x2707e86cBb3Db85b1Ceb78bA9C9580e2F35736fD',
    bulkVotingStrategyContract: '0xF9A74d7c97276f5DF38086F3A0F96fAA385619Ee',
    roundContract: '0x8140b7168d6acBf528FC68Ea94D75E9d2B5aF721'
  },
  "optimism-mainnet": {
    roundFactoryContract: '0x64ab6F2E11dF8B3Be5c8838eDe3951AC928daE9C',
    roundImplementationContract: '0xdf25423c9ec15347197Aa5D3a41c2ebE27587D59',
    bulkVotingStrategyContract: '0x4a850F463D1C4842937c5Bc9540dBc803D744c9F',
    roundContract: '0x2DF6c42dd2d7a13c19Ca5f7858fB7cC05A2933ed'
  },
  "optimism-kovan": {
    roundFactoryContract: '0x0d2d160Eff14f835B30e3f0EA83b50289A7d51aF',
    roundImplementationContract: '0x5C46ae4a950E0e0280006403B9e517462FD16dAc',
    bulkVotingStrategyContract: '0x9d55810da86A9610Ab3223f4CDF0b5d81FfA579c',
    roundContract: '0x3EE29458f2121E2C20421cd188F2CAbd99347d54'
  },
};