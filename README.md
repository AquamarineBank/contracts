# Aquamarine

On various chains, there exists a problem and a simple solution. Let's start with the problem. Since the fall of Multichain, there have sprung up many versions of the same token, 
ie lzUSDC, axlUSDC. 
Although this segregates the bridge risks, it also creates a need for liquidity pools of the same asset, all of which need incentives. To solve this my team has created a very simple solution: Aquamarine.

Aquamarine is a protocol that wraps various stable coin assets into a single fungible asset. 

There are no liquidations or oracle risks and it is permissionless.

Aquamarine consists of 5 simple contracts, built to be sleek and succinct without a lot of extra risk. However, users of Aquamarine do take on the following risks:  
* They trust in the solvency of Circles' USDC  
* They trust in the solvency of Tethers' USDT  
* They trust in the dependability of LayerZero's bridging solution  
* They trust in the dependability of Axelar's bridging solution  
* They trust in the security of Aquamarine's own contracts

That said there are features that allow the community to add further risk, and reduce the risk above.  
Let's go through all 5 of the contracts.  
First, there are 2 tokens, USD and AQUA.  

USD is the token minted fully backed by lzUSDC, lzUSDT, axlUSDC, axlUSDT. It doesn't have any supply cap, tax, or any features, other than mintability. It is ONLY mintable by the BANK which is described below.
AQUA is the governance token of the protocol. It also collects 100% of the fees. There was no presale, or allocations (outside those used by the team for initial liquidity), and its only emissions are as bribes via the BRIBER contract. It has a max cap of 300,000 tokens to ever be minted.
Let's move on to the 3 other contracts: the BANK, BRIBER, BOARDROOM.

## The Bank
This contract holds the backing of all USD in circulation. Anyone can come with any form of accepted collateral, deposit it, and mint USD at a 1 to 1 ratio. 
100 USDC in and 100 USD out. 
The BANK is the only contract with the ability to mint USD. Anyone can come to the BANK with USD and redeem it for any of the assets held inside the BANK at a ratio that is modified by the redemption fee. The redemption fee can be set by the team, based on snapshot votes, between the range of 1% to 0%.
The protocol will launch with the redemption fee set to 1% but will eventually target a fee of 0.1%.  
100 USD in and 99 USDT out   
then  
100 USD in and 99.9 USDT out  
ALL fees are sent to the BOARDROOM.  
There were considerations of a variable fee, based on ratios. However, this idea was decided against for simplicity. Besides, even if there are efforts to mitigate with a balanced collateral spread, there is always a risk of one bad,  and certainly, losers if one bad arises. Let the free market sentiment choose the ratio with their deposits and withdraws.
You can consider the BANK like a swapping liquidity pool with a trading fee only on selling USD into it.

The team also has the ability to do the following:

* setRedeemFee() {max 1%}  
* pause(address token) - pause individual collateral minting  
* unPause(address token) - unpause individual collateral minting  
* setBoardroom() - change the destination of the fees  
* addBacking() - add a collateral type  
* pauseMinting() - pause ALL minting of USD  
* resumeMinting() - unpause minting of USD  
* setPanicMen() - grant/revoke addresses panic powers  

Inside the BANK there is also a function called panic() which allows addresses that are whitelisted (PanicMen) the ability to pause the minting of USD vs. individual collateral types. This feature is to give keepers and community members the ability to respond to events where it makes sense for the minted of USD vs. certain collateral to be stopped.
PanicMen can ONLY pause. Only the team can unpause and add new collateral types.

## The Boardroom
This contract is a simplified gauge staking contract that allows holders of AQUA to stake their AQUA for voting power on snapshot proposals. There are no permissionless governance systems in place. This means the settings in the contracts still need to be changed by the team at the guidance of the voters.
The boardroom also gets the benefit of collecting all of the redemption fees. To join the board, simply deposit any number of AQUA tokens and you will have a voice equal to the size of your deposit.

## The Briber
This contract is the only contract with the power to mint AQUA tokens. It can only mint them as bribes on solidly style gauges using the notifyRewardAmount() function. The bribePool() function can only be called by whitelisted addresses. Ie the team, and a keeper
Each week this contract will mint AQUA tokens and use them to bribe the AQUA/USD liquidity pool gauge on Velocimeter. The amount of AQUA tokens minted in this way will start at 2000 tokens on the first bribe and degrade linearly by 1% for each bribe. Emissions in this manner will last about 3.45 years
You can see the current amount by querying bribeAmount() in the BRIBER.
There are cases where partnerships may arise, and other gauges might need bribing. This bribeSpecial() function can only be called by the team and is restricted to an amount no greater than the current bribeAmount(). This function does NOT reduce the bribeAmount() number, but does reduce the runway of total emissions.
bribePool() can only be called once each week. 

The team also has the ability to do the following:    
* setBribe() - changes the bribe contract destination in case this is modified  
* addBriber() - grants power to an address to call bribePool()  
* removeBriber() - revokes power to call bribePool()  
* pauseMinting() - pauses minting of AQUA  
* resumeMinting() - unpauses minting of AQUA  

## The Insurance Fund
To build a fund for safety which will be controlled fully by the boardroom vote, the protocol has received 2000 AQUA at initialization to stake in the boardroom.
The gained USD tokens will be periodically redeemed for the assets that are the most abundant in the bank and held in ratios at the will of the voters.

## In Conclusion
This protocol design was built to be as immutable as possible, as automatic as possible, and as permissionless as possible, while being as low risk as possible.
This protocol doesn't have a lot of fancy yield farming strategies where collaterals are "put to work" elsewhere, in order to keep risk low. 
It is a simple solution to a simple problem that has arisen.

URLS
Telegram: https://t.me/+xk9Mnwt7dkdmNjRl 
Website:
Twitter: NO Official Twitter

## Contracts on Fantom Sonic Testnet
      "contractName": "Aquamarine",
      "contractAddress": "0xdc06b03191d6Cc78623277e70Ad0F6Df34a679ee",

      "contractName": "Briber",
      "contractAddress": "0x0b27154A88EAfD3bE41693c7E0ab7Ab125AFb523",

      "contractName": "Bank",
      "contractAddress": "0x2d0EfbFc6Ea0bD22fD01c62D97868C08452F68c0",

      "contractName": "USD",
      "contractAddress": "0xE6b998b90A8BA2f9d0838cf3713839B6bE459b79",

      "contractName": "Boardroom",
      "contractAddress": "0x66DfE31908124173eA2851924851e92A36705688",

      "contractName": "TestUSD18",
      "contractAddress": "0xfabD513b66FbE38E13fe0c440b3FeFb099152f8f",

      "contractName": "TestUSD6",
      "contractAddress": "0x6F7c8f25B6fEe5904e27c73B2EcE37FB6e7d4B5D",

      "contractName": "BribeMock",
      "contractAddress": "0x9C093304b7c92D0e38d6cA0a63c980417D3544b7",

## Contracts on Fantom Testnet
      "contractName": "Aquamarine",
      "contractAddress": "0xeebf7027C618E79A3f3B3d28c776C2ae2d9243e7",

      "contractName": "Briber",
      "contractAddress": "0xeCbA5500Ade4604F38DD885F926eA9031abEBb13",

      "contractName": "Bank",
      "contractAddress": "0xc951386567CEC366c0D542a5B6d37129643aD186",

      "contractName": "USD",
      "contractAddress": "0x2E4B6204690A8a90c3c2c7483fb1020e6E795549",

      "contractName": "Boardroom",
      "contractAddress": "0x883e3986473ef0A0e4eDDd6A9E528A513d466922",

      "contractName": "TestUSD18",
      "contractAddress": "0xfabD513b66FbE38E13fe0c440b3FeFb099152f8f",

      "contractName": "TestUSD6",
      "contractAddress": "0x6F7c8f25B6fEe5904e27c73B2EcE37FB6e7d4B5D",

      "contractName": "BribeMock",
      "contractAddress": "0x9C093304b7c92D0e38d6cA0a63c980417D3544b7",




