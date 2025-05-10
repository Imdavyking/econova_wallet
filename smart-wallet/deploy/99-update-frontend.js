const { ethers, network } = require("hardhat")
const fs = require("fs")
const { json } = require("hardhat/internal/core/params/argumentTypes")
const FRONT_END_ADDRESSES_FILE = "../json/saving-wallet-contractAddress.json"
const ABI_LOCATION = "../json/saving-wallet-abi.json"
module.exports = async function () {
  if (process.env.UPDATE_FRONTEND) {
    console.log("Updating frontend")
    updateContractAddresses()
    updateAbi()
  }
}

async function updateAbi() {
  try {
    const raffle = await ethers.getContract("SavingsWallet")
    fs.writeFileSync(
      ABI_LOCATION,
      raffle.interface.format(ethers.utils.FormatTypes.json)
    )
  } catch (error) {
    console.log(error)
  }
}

async function updateContractAddresses() {
  const raffle = await ethers.getContract("SavingsWallet")
  const chainId = network.config.chainId.toString()
  const contractAddresses = JSON.parse(
    fs.readFileSync(FRONT_END_ADDRESSES_FILE),
    "utf8"
  )

  if (chainId in contractAddresses) {
    if (!contractAddresses[chainId].includes(raffle.address)) {
      contractAddresses[chainId].push(raffle.address)
    }
  } else {
    contractAddresses[chainId] = [raffle.address]
  }

  fs.writeFileSync(FRONT_END_ADDRESSES_FILE, JSON.stringify(contractAddresses))
}

module.exports.tags = ["all", "frontend"]
