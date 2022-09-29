/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
    /**
     * Networks define how you connect to your ethereum client and let you set the
     * defaults web3 uses to send transactions. If you don't specify one truffle
     * will spin up a development blockchain for you on port 9545 when you
     * run `develop` or `test`. You can ask a truffle command to use a specific
     * network from the command line, e.g
     *
     * $ truffle test --network <network-name>
     */

    networks: {
        // Useful for testing. The `development` name is special - truffle uses it by default
        // if it's defined here and no other network is specified at the command line.
        // You should run a client (like ganache-cli, geth or parity) in a separate terminal
        // tab if you use this network and you must also set the `host`, `port` and `network_id`
        // options below to some value.
        //
        mainnet: {
            provider: () =>
                new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    'https://mainnet.infura.io/v3/' + process.env.INFURA_KEY
                ),
            network_id: 1,
            confirmations: 1,
            skipDryRun: true,
            gas: 20000000,
            timeoutBlocks: 100000,
            networkCheckTimeout: 20000000,
            gasPrice: 13000000000,
            allowUnlimitedContractSize: true,
        },
        development: {
            host: '127.0.0.1', // Localhost (default: none)
            port: 7545, // Standard Ethereum port (default: none)
            network_id: '*', // Any network (default: none)
        },
        skale: {
            provider: () =>
                new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    process.env.SKALE_ENDPOINT
                ),
            network_id: process.env.SKALE_CHAIN_ID,
            gasPrice: 100000,
            skipDryRun: true,
        },
        skale_test: {
            provider: () =>
                new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    process.env.SKALE_TEST_ENDPOINT
                ),
            network_id: process.env.SKALE_TEST_CHAIN_ID,
            gasPrice: 150000,
            skipDryRun: true,
        },
        mumbai: {
            provider: () =>
                new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    'https://matic-mumbai.chainstacklabs.com'
                ),
            network_id: 80001,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 20000000,
            gasPrice: 10000000000,
        },
        rinkeby: {
            provider: () =>
                new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    'https://rinkeby.infura.io/v3/' + process.env.INFURA_KEY
                ),
            network_id: 4,
            gas: 20000000,
            gasPrice: 10000000000,
        },
        goerli: {
            provider: () =>
                new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    'https://goerli.infura.io/v3/' + process.env.INFURA_KEY
                ),
            network_id: 5,
            confirmations: 1,
            skipDryRun: true,
            gas: 20000000,
            timeoutBlocks: 100000,
            networkCheckTimeout: 20000000,
            gasPrice: 13000000000,
            allowUnlimitedContractSize: true,
        },
        matic: {
            provider: () =>
                new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    'https://polygon-rpc.com/'
                ),
            network_id: 137,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 6000000,
            gasPrice: 40000000000,
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: '0.8.17', // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            // settings: {
            //     // See the solidity docs for advice about optimization and evmVersion
            //     optimizer: {
            //         enabled: true,
            //         runs: 999999,
            //     },
            //     viaIR: true,
            // },
        },
    },

    plugins: ['truffle-plugin-verify', 'truffle-plugin-stdjsonin'],
    api_keys: {
        etherscan: process.env.ETHERSCAN_API_KEY,
        polygonscan: process.env.POLYGONSCAN_API_KEY,
    },

    // Truffle DB is currently disabled by default; to enable it, change enabled:
    // false to enabled: true. The default storage location can also be
    // overridden by specifying the adapter settings, as shown in the commented code below.
    //
    // NOTE: It is not possible to migrate your contracts to truffle DB and you should
    // make a backup of your artifacts to a safe location before enabling this feature.
    //
    // After you backed up your artifacts you can utilize db by running migrate as follows:
    // $ truffle migrate --reset --compile-all
    //
    // db: {
    // enabled: false,
    // host: "127.0.0.1",
    // adapter: {
    //   name: "sqlite",
    //   settings: {
    //     directory: ".db"
    //   }
    // }
    // }
};
