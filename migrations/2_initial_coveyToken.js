const CoveyToken = artifacts.require('CoveyToken');

module.exports = async function (deployer, network, accounts) {
    const instance = await deployer.deploy(CoveyToken);
};
