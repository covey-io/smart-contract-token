const CoveyStaking = artifacts.require('CoveyStaking');
const CoveyToken = artifacts.require('CoveyToken');

contract('CoveyStaking', async (accounts) => {
    it('deploys successfully', async () => {
        const coveyStaking = await CoveyStaking.deployed();
        assert(coveyStaking.address);
    });

    it('receives CVY tokens', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();
        let err = null;

        try {
            await coveyToken.send(
                coveyStaking.address,
                '10000000000000000000',
                []
            );
        } catch (e) {
            err = e;
        }

        assert.equal(err, null);

        const coveyStakingBalance = await coveyToken.balanceOf(
            coveyStaking.address
        );

        assert.isAbove(parseInt(coveyStakingBalance), 9000000000000000000);
    });

    it('can send CVY tokens', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();
        let err = null;

        try {
            await coveyToken.send(
                coveyStaking.address,
                '10000000000000000000',
                []
            );

            await coveyToken.authorizeOperator(accounts[0], {
                from: coveyStaking.address,
            });

            await coveyToken.transferFrom(
                coveyStaking.address,
                accounts[2],
                '6000000000000000000'
            );
        } catch (e) {
            err = e;
        }

        assert.equal(err, null);

        const balance = await coveyToken.balanceOf(accounts[2]);

        assert.isAbove(parseInt(balance), 5000000000000000000);
    });
});
