module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const args = [];
  await deploy("SavingsWallet", {
    from: deployer,
    log: true,
    args: args,
  });
};

module.exports.tags = ["all"];
