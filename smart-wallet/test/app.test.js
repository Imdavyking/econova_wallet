const { assert, expect } = require("chai")
const { ethers } = require("hardhat")
const { getNamedAccounts, network } = require("hardhat")
describe("SavingsWallet", function () {
  let tokenAddress, savingsWallet, deployer
  const chainId = network.config.chainId
  let accounts
  beforeEach(async function () {
    accounts = await ethers.getSigners()
    deployer = (await getNamedAccounts()).deployer
    await deployments.fixture(["all"])
    savingsWallet = await ethers.getContract("SavingsWallet", deployer)
    tokenAddress = await ethers.getContract("ERC20Mock", deployer)
  })

  describe("Goal Creation", function () {
    it("Should allow a user to create a savings goal", async function () {
      await savingsWallet
        .connect(accounts[0])
        .createGoal("Vacation", tokenAddress.address)
      const balance = await savingsWallet
        .connect(accounts[0])
        .viewGoalBalance("Vacation")
      expect(balance).to.equal(0)
    })

    it("Should revert if a goal with the same name already exists", async function () {
      await savingsWallet
        .connect(accounts[0])
        .createGoal("Vacation", tokenAddress.address)
      await expect(
        savingsWallet
          .connect(accounts[0])
          .createGoal("Vacation", tokenAddress.address)
      ).to.be.revertedWith("SavingsWallet__GoalAlreadyExists")
    })
  })

  describe("Saving Tokens", function () {
    it("Should allow a user to save tokens to a goal", async function () {
      await savingsWallet
        .connect(accounts[0])
        .createGoal("Vacation", tokenAddress.address)

      // Approve the contract to spend tokens

      await tokenAddress
        .connect(accounts[0])
        .approve(savingsWallet.address, ethers.utils.parseEther("100"))
      await tokenAddress
        .connect(accounts[0])
        .approve(savingsWallet.address, ethers.utils.parseEther("100"))
      // Save tokens to the goal
      await savingsWallet
        .connect(accounts[0])
        .saveTokens("Vacation", ethers.utils.parseEther("100"))

      const balance = await savingsWallet
        .connect(accounts[0])
        .viewGoalBalance("Vacation")
      expect(balance).to.equal(ethers.utils.parseEther("100"))
    })

    it("Should revert if trying to save tokens to a non-existent goal", async function () {
      await expect(
        savingsWallet
          .connect(accounts[0])
          .saveTokens("NonExistentGoal", ethers.utils.parseEther("100"))
      ).to.be.revertedWith("SavingsWallet__GoalDoesNotExist")
    })
  })

  describe("Transferring and Withdrawing Tokens", function () {
    beforeEach(async function () {
      await savingsWallet
        .connect(accounts[0])
        .createGoal("Vacation", tokenAddress.address)
      await tokenAddress
        .connect(accounts[0])
        .approve(savingsWallet.address, ethers.utils.parseEther("100"))
      await savingsWallet
        .connect(accounts[0])
        .saveTokens("Vacation", ethers.utils.parseEther("100"))
    })

    it("Should allow a user to transfer tokens from a goal to another user", async function () {
      await savingsWallet
        .connect(accounts[0])
        .transferTokens(
          "Vacation",
          accounts[2].address,
          ethers.utils.parseEther("50")
        )

      expect(await tokenAddress.balanceOf(accounts[2].address)).to.equal(
        ethers.utils.parseEther("50")
      )
    })

    it("Should revert if trying to transfer more tokens than available", async function () {
      await expect(
        savingsWallet
          .connect(accounts[0])
          .transferTokens(
            "Vacation",
            accounts[2].address,
            ethers.utils.parseEther("999999999999999999999999950")
          )
      ).to.be.revertedWith("SavingsWallet__InsufficientBalance")
    })

    it("Should allow a user to withdraw tokens from a goal", async function () {
      await savingsWallet
        .connect(accounts[0])
        .withdrawTokens("Vacation", ethers.utils.parseEther("50"))

      const balance = await savingsWallet
        .connect(accounts[0])
        .viewGoalBalance("Vacation")
      expect(balance).to.equal(ethers.utils.parseEther("50"))

      expect(await tokenAddress.balanceOf(accounts[0].address)).to.be.equal(
        ethers.utils.parseEther("999999999999999999999950")
      )
    })

    it("Should revert if trying to withdraw more tokens than available", async function () {
      await expect(
        savingsWallet
          .connect(accounts[0])
          .withdrawTokens("Vacation", ethers.utils.parseEther("200"))
      ).to.be.revertedWith("SavingsWallet__InsufficientBalance")
    })
  })
})
