
const hre = require("hardhat");

async function main() {
  const WordGame = await hre.ethers.getContractFactory("WordGame");
  const wordGame = await WordGame.deploy();

  await wordGame.deployed();

  console.log("wordGame deployed to:", wordGame.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
