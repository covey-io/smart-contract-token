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
            await coveyToken.transfer(accounts[0], 100, { from: accounts[1] });
        } catch (e) {
            err = e;
        }

        assert.ok(err instanceof Error);
    });
});
