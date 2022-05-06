const CoveyToken = artifacts.require('CoveyToken');

contract('CoveyToken', async (accounts) => {
    it('deploys successfully', async () => {
        const coveyToken = await CoveyToken.deployed();
        assert(coveyToken.address);
    });

    it('does not allow sending locked tokens', async () => {
        const coveyToken = await CoveyToken.deployed();

        await coveyToken.sendLocked(accounts[1], 100, 300, {
            from: accounts[0],
        });

        let err = null;
        try {
            await coveyToken.transfer(accounts[0], 100000000000000000000, {
                from: accounts[1],
            });
        } catch (e) {
            err = e;
        }

        assert.ok(err instanceof Error);
    });

    it('does not allow sending an excess of tokens when tokens are locked', async () => {
        const coveyToken = await CoveyToken.deployed();

        await coveyToken.sendLocked(accounts[1], 50, 300, {
            from: accounts[0],
        });

        await coveyToken.transfer(accounts[1], '50000000000000000000', {
            from: accounts[0],
        });

        let err = null;
        try {
            await coveyToken.transfer(accounts[0], '60000000000000000000', {
                from: accounts[1],
            });
        } catch (e) {
            err = e;
        }

        assert.ok(err instanceof Error);
    });

    it('allows sending non locked token amounts', async () => {
        const coveyToken = await CoveyToken.deployed();

        await coveyToken.sendLocked(accounts[1], 50, 300, {
            from: accounts[0],
        });

        await coveyToken.transfer(accounts[1], '50000000000000000000', {
            from: accounts[0],
        });

        let err = null;
        try {
            await coveyToken.transfer(accounts[0], '30000000000000000000', {
                from: accounts[1],
            });
        } catch (e) {
            err = e;
        }

        assert.equal(err, null);
    });

    it('does not allow non owners to mint', async () => {
        const coveyToken = await CoveyToken.deployed();

        let err = null;
        try {
            await coveyToken.mint(
                accounts[2],
                '30000000000000000000',
                null,
                null,
                {
                    from: accounts[3],
                }
            );
        } catch (e) {
            console.log(e);
            err = e;
        }

        assert.equal(err, null);
    });
});
