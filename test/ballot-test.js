const { expect } = require("chai")

let token
let dao
let owner, voter1, voter2, voter3, voters
let contractAsSigner0, contractAsSigner1, contractAsSigner2

beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    const BallotContract = await ethers.getContractFactory("Ballot");
    const TokenContract = await ethers.getContractFactory("Edu_Token");

    [owner, voter1, voter2, voter3, ...voters] = await ethers.getSigners();
    token = await TokenContract.deploy()
    await token.transfer(voter1.address, "5000000000000000000")
    await token.transfer(voter2.address, "10000000000000000000")

    dao = await BallotContract.deploy(
        [
            "Test string 1",
            "2eme proposal",
            "3eme proposal"
        ], 3600, token.address
    );


    contractAsSigner0 = dao.connect(owner);
    contractAsSigner1 = dao.connect(voter1);
    contractAsSigner2 = dao.connect(voter2);
})

describe("Test Deploy DAO", function () {
    it("Should return the winner name proposal", async function () {
        expect(await dao.winnerName()).to.equal("Test string 1");
    })

    it("Should return a new proposal", async function () {
        const addProposalTx = await contractAsSigner0.addProposal("4eme proposal")
        await addProposalTx.wait()
        const proposal = await dao.proposals(3)
        expect(proposal.name).to.equal("4eme proposal");
    })

    it("Should vote", async function () {
        // const giveRightToVoteTx = await dao.connect(owner).giveRightToVote(voter2.address);
        // giveRightToVoteTx.wait();
        const voteTx = await contractAsSigner1.vote(1);
        voteTx.wait();

        expect(await dao.winnerName()).to.equal("2eme proposal");

        const proposal = await dao.proposals(1)
        expect(proposal.voteCount).to.equal("5000000000000000000");
    })

    xit("Should reject vote after timeout", async function () {
        const giveRightToVoteTx = await dao.connect(owner).giveRightToVote(voter2.address);
        giveRightToVoteTx.wait();

        await network.provider.send("evm_increaseTime", [3601])
        await network.provider.send("evm_mine") // this one will have 10s more

        await expect(contractAsSigner1.vote(1)).to.be.reverted;
    })

})