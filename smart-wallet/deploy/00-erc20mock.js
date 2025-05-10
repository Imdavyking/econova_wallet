const { developmentChains } = require("../helper-hardhat-config")

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()
  const args = ["Mock", "MK", 18, "1000000000000000000000000"]

  if (developmentChains.includes(network.name)) {
    await deploy("ERC20Mock", {
      from: deployer,
      log: true,
      args: args,
    })
    log("Mocks Deployed!")
    log("---------------------------------")
  }
}

module.exports.tags = ["all"]
