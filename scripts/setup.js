var fs = require('fs')
var path = require('path')
var RampService = require('../build/contracts/RampService')

const address = RampService.networks['2']

console.log(address);

console.log('The app has been configured.')
console.log('Run "npm run dev" to start it.')

const tronboxJs = require('../tronbox').networks.development
// const RampServiceConfig = {
//   contractAddress: address,
//   privateKey: tronboxJs.privateKey,
//   fullHost: tronboxJs.fullHost
// }

// fs.writeFileSync(path.resolve(__dirname, '../src/js/RampService-config.js'),`var RampServiceConfig = ${JSON.stringify(RampServiceConfig, null, 2)}`)
