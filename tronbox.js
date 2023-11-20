const port = process.env.HOST_PORT || 8080

module.exports = {
  networks: {
    mainnet: {
      // Don't put your private key here:
      privateKey: '090a6cd0c9dd99e24b0df256f2889bd40ef25f3840babc22319eb061b993d883',
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.trongrid.io',
      network_id: '1'
    },
    shasta: {
      privateKey: '090a6cd0c9dd99e24b0df256f2889bd40ef25f3840babc22319eb061b993d883',
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.shasta.trongrid.io',
      network_id: '2'
    },
    nile: {
      privateKey: '090a6cd0c9dd99e24b0df256f2889bd40ef25f3840babc22319eb061b993d883',
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.nileex.io',
      network_id: '3'
    },
    development: {
      // For tronbox/tre docker image
      privateKey: '0000000000000000000000000000000000000000000000000000000000000001',
      userFeePercentage: 0,
      feeLimit: 1000 * 1e6,
      fullHost: 'http://127.0.0.1:' + port,
      network_id: '9'
    },
    compilers: {
      solc: {
        version: '0.8.18'
      }
    }
  }
}
