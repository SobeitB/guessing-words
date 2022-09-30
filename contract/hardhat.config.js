require('@nomiclabs/hardhat-waffle');

module.exports = {
  solidity: '0.8.4',
  networks: {
    rinkeby: {
      url: 'https://eth-rinkeby.alchemyapi.io/v2/A4ENE9MTqQOo6UvTjnp6pdhAF31BLvlR',
      accounts: ['658d78026c930acfb900a4d77b127233c46095e22aada1dfc9ab88dee2d7648e'],
    },
  },
};