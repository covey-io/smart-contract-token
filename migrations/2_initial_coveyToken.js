const CoveyToken = artifacts.require('CoveyToken');

module.exports = async function (deployer) {
    const instance = await deployer.deploy(
        CoveyToken,
        '10000000000000000000000',
        []
    );
};
