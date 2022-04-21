const CoveyStaking = artifacts.require('CoveyStaking');

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(
        CoveyStaking,
        '0xbf9110ab09694fD748DDC68c27A95e83B8d4dc8a'
    );
};
