# NFT Minter with Hardhat

This project demonstrates an NFT mint use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The project comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply mint a new NFT.

The standard NFT used is the ERC1155 and the metadata must be stored in IPFS

Install dependencies:

```shell
yarn install
```

Compile and run tests:

```shell
yarn hardhat coverage
```

Deploy to Mumbai (Polygon Testnet):

```shell
yarn hardhat run scripts/deploy.ts --network mumbai
```

Deploy to Polygon Mainnet:

```shell
yarn hardhat run scripts/deploy.ts --network polygon
```

Then, copy the deployment address and start using it in your client application!

### Contributing

If you want to contribute to the project, lint code before git pushing / open a pull request.

```shell
yarn eslint '**/*.{js,ts}'
yarn eslint '**/*.{js,ts}' --fix
yarn prettier '**/*.{json,sol,md}' --check
yarn prettier '**/*.{json,sol,md}' --write
yarn solhint 'contracts/**/*.sol'
yarn solhint 'contracts/**/*.sol' --fix
```
