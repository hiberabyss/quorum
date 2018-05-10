//
// Create a public contract
//

a = eth.accounts[0]
web3.eth.defaultAccount = a;

loadScript("/tmp/hello.js")

var simpleContract = web3.eth.contract(JSON.parse(output.contracts["/nnodes/hello.sol:simplestorage"].abi));
var simple = simpleContract.new(42, {from:web3.eth.accounts[0], data: "0x" + output.contracts["/nnodes/hello.sol:simplestorage"].bin, gas: 300000}, function(e, contract) {
	if (e) {
		console.log("err creating contract", e);
	} else {
		if (!contract.address) {
			console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
		} else {
			console.log("Contract mined! Address: " + contract.address);
			console.log(contract);
		}
	}
});
