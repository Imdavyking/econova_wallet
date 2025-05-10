const { run } = require("hardhat")

const verify = async (contractAddress, args) => {
  console.log("Verifying contract...")
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })
  } catch (e) {
    if (e.message.includes("Already verified")) {
      console.log("Already verified")
    }
    console.error(e)
  }
}

module.exports = verify
