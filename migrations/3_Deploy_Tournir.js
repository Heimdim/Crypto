const Tournir = artifacts.require("Tournir");
const Token = artifacts.require("Token");

module.exports =  async function (deployer, networks, accounts) {
    const token = await Token.deployed();

    return deployer.deploy(Tournir, accounts[0], token.address, BigInt(10e18));
};
