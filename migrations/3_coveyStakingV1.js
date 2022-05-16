const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const CoveyStaking = artifacts.require('CoveyStaking');
const CoveyToken = artifacts.require('CoveyToken');

module.exports = async function (deployer) {
    const instance = await deployProxy(CoveyStaking, [CoveyToken.address], {
        deployer,
    });
    console.log('Deployed', instance.address);
};
