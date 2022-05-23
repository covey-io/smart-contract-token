const CoveyStaking = artifacts.require('CoveyStaking');
const CoveyToken = artifacts.require('CoveyToken');

const truffleAssert = require('truffle-assertions');

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

    it('allows users to stake', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();

        let err = null;

        try {
            await coveyToken.send(accounts[5], '10000000000000000000', []);
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[5],
            });
            await coveyStaking.stake('2000000000000000000', {
                from: accounts[5],
            });
        } catch (e) {
            err = e;
        }

        assert.equal(err, null);

        const userBalance = await coveyToken.balanceOf(accounts[5]);

        assert.isAtMost(parseInt(userBalance), 8000000000000000000);

        const coveyStakingBalance = await coveyToken.balanceOf(
            coveyStaking.address
        );

        assert.isAtLeast(parseInt(coveyStakingBalance), 2000000000000000000);
    });

    it('allows users to view staked amounts', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();

        let err = null;

        try {
            await coveyToken.send(accounts[5], '10000000000000000000', []);
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[5],
            });
            await coveyStaking.stake('2000000000000000000', {
                from: accounts[5],
            });
        } catch (e) {
            err = e;
        }

        assert.equal(err, null);

        const stakedAmount = await coveyStaking.getTotalStaked({
            from: accounts[5],
        });
        assert.isAtLeast(parseInt(stakedAmount), 2000000000000000000);
    });

    it('allows users to unstake', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();

        let err = null;

        try {
            await coveyToken.send(accounts[5], '10000000000000000000', []);
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[5],
            });
            await coveyStaking.stake('2000000000000000000', {
                from: accounts[5],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[5],
            });
        } catch (e) {
            err = e;
        }

        assert.equal(err, null);
    });

    it('allows users to view unstaked amounts', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();

        let err = null;

        try {
            await coveyToken.send(accounts[5], '10000000000000000000', []);
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[5],
            });
            await coveyStaking.stake('2000000000000000000', {
                from: accounts[5],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[5],
            });
        } catch (e) {
            err = e;
        }

        const unstakedAmount = await coveyStaking.getTotalUnstaked({
            from: accounts[5],
        });
        assert.isAtLeast(parseInt(unstakedAmount), 1000000000000000000);

        assert.equal(err, null);
    });

    it('allows users to cancel their unstake', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();

        let err = null;

        try {
            await coveyToken.send(accounts[5], '10000000000000000000', []);
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[5],
            });
            await coveyStaking.stake('2000000000000000000', {
                from: accounts[5],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[5],
            });

            await coveyStaking.cancelUnstake({ from: accounts[5] });
        } catch (e) {
            err = e;
        }

        const unstakedAmount = await coveyStaking.getTotalUnstaked({
            from: accounts[5],
        });
        assert.equal(parseInt(unstakedAmount), 0);

        assert.equal(err, null);
    });

    it('dispenses stakes with no bankruptcies', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();

        let err = null;

        try {
            await coveyToken.send(accounts[5], '10000000000000000000', []);
            await coveyToken.send(accounts[6], '10000000000000000000', []);
            await coveyToken.send(accounts[7], '10000000000000000000', []);
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[5],
            });
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[6],
            });
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[7],
            });
            await coveyStaking.stake('2000000000000000000', {
                from: accounts[5],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[5],
            });

            await coveyStaking.stake('2000000000000000000', {
                from: accounts[6],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[6],
            });

            await coveyStaking.stake('2000000000000000000', {
                from: accounts[7],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[7],
            });

            await coveyStaking.dispenseStakes([]);
        } catch (e) {
            err = e;
        }

        const unstakedAmount = await coveyStaking.getTotalUnstaked({
            from: accounts[7],
        });
        assert.equal(parseInt(unstakedAmount), 0);

        const stakedAmount = await coveyStaking.getTotalStaked({
            from: accounts[7],
        });

        assert.equal(parseInt(stakedAmount), 1000000000000000000);

        const accountBalance = await coveyToken.balanceOf(accounts[7]);

        assert.isAtLeast(parseInt(accountBalance), 1000000000000000000);

        assert.equal(err, null);
    });

    it('dispenses stakes with bankruptcies not being dispensed', async () => {
        const coveyToken = await CoveyToken.deployed();
        const coveyStaking = await CoveyStaking.deployed();

        let err = null;

        try {
            await coveyToken.send(accounts[8], '10000000000000000000', []);
            await coveyToken.send(accounts[9], '10000000000000000000', []);

            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[8],
            });
            await coveyToken.authorizeOperator(coveyStaking.address, {
                from: accounts[9],
            });
            await coveyStaking.stake('2000000000000000000', {
                from: accounts[8],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[8],
            });

            await coveyStaking.stake('2000000000000000000', {
                from: accounts[9],
            });

            await coveyStaking.unstake('1000000000000000000', {
                from: accounts[9],
            });

            const tx = await coveyStaking.dispenseStakes([accounts[9]]);
            truffleAssert.eventEmitted(tx, 'Bankrupt', (ev) => {
                return (
                    ev._adr === accounts[9] &&
                    parseInt(ev.amountLost) === 2000000000000000000
                );
            });

            truffleAssert.eventEmitted(tx, 'StakeDispensed', (ev) => {
                return (
                    ev._adr === accounts[8] &&
                    parseInt(ev.amountDispensed) === 1000000000000000000
                );
            });
        } catch (e) {
            err = e;
        }

        assert.equal(err, null);

        const unstakedAmountBankrupt = await coveyStaking.getTotalUnstaked({
            from: accounts[9],
        });
        assert.equal(parseInt(unstakedAmountBankrupt), 0);

        const stakedBankruptAmount = await coveyStaking.getTotalStaked({
            from: accounts[9],
        });

        assert.equal(parseInt(stakedBankruptAmount), 0);

        const accountBankruptBalance = await coveyToken.balanceOf(accounts[9]);

        assert.equal(parseInt(accountBankruptBalance), 8000000000000000000);
    });
});
