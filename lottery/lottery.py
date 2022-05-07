from web3 import Web3
from decouple import config
from web3.middleware import geth_poa_middleware
import time

time_to_sleep = 10
address = "0xfbca2AC4748C795351cE5a96C6DDAADCe3B230E0"
abi = '''[
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "_address",
				"type": "address[]"
			}
		],
		"name": "addPlayers",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "resetLottery",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "startLottery",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "stopLottery",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "declareWinner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "players",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "returnSender",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "state",
		"outputs": [
			{
				"internalType": "enum Lottery.LOTTERY_STATE",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]'''

wallet_address = config('WALLET_PUBLIC_KEY')
wallet_private_key = config('WALLET_PRIVATE_KEY')

infura_url = config('INFURA_URL')

def retrieveAddresses():
    try :
        with open("./resources/address_list.txt") as addresses:
            return addresses.read().split(',')
    except:
        print("File Read error!")

if __name__ == '__main__':
    w3 = Web3(Web3.HTTPProvider(infura_url))
    w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    if not w3.isConnected():
        print("Connection Error")
        exit()

    contract = w3.eth.contract(address=address, abi=abi)

    print("Message Sender Address is: " + contract.functions.returnSender().call({'from': wallet_address}))

    print("Owner is: " + contract.functions.owner().call({'from': wallet_address}) )

    print("Enable Lottery.........")

    txn_dict = contract.functions.startLottery().buildTransaction({
        'chainId': 4,
        'gas': 300000,
        'gasPrice': w3.toWei('40', 'gwei'),
        'nonce': w3.eth.get_transaction_count(wallet_address),
        'from': wallet_address
    })
    signed_txn = w3.eth.account.signTransaction(txn_dict, private_key=wallet_private_key)

    result = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    tx_receipt = None
    time.sleep(time_to_sleep)
    try:
        tx_receipt = w3.eth.getTransactionReceipt(result)
    except:
        count = 0
        while tx_receipt is None and (count < 30):
            time.sleep(10)
            tx_receipt = w3.eth.getTransactionReceipt(result)
            count+=1


    if tx_receipt is None:
       print("Starting Failed!")

    print("Adding Players.........")

    txn_dict = contract.functions.addPlayers(retrieveAddresses()).buildTransaction({
        'chainId': 4,
        'gas': 300000,
        'gasPrice': w3.toWei('40', 'gwei'),
        'nonce': w3.eth.get_transaction_count(wallet_address),
        'from': wallet_address
    })
    signed_txn = w3.eth.account.signTransaction(txn_dict, private_key=wallet_private_key)

    result = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    time.sleep(time_to_sleep)
    tx_receipt = None
    try:
        tx_receipt = w3.eth.getTransactionReceipt(result)
    except:
        count = 0
        while tx_receipt is None and (count < 30):
            time.sleep(10)
            tx_receipt = w3.eth.getTransactionReceipt(result)
            count+=1


    if tx_receipt is None:
       print("Adding Players Failed!")

    
    print("Declaring Winner.........")

    print("Winner is: " + contract.functions.declareWinner().call({'from': wallet_address}))
    

    print("Resetting Lottery.........")

    txn_dict = contract.functions.resetLottery().buildTransaction({
        'chainId': 4,
        'gas': 300000,
        'gasPrice': w3.toWei('40', 'gwei'),
        'nonce': w3.eth.get_transaction_count(wallet_address),
        'from': wallet_address
    })
    signed_txn = w3.eth.account.signTransaction(txn_dict, private_key=wallet_private_key)

    result = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    tx_receipt=None
    time.sleep(time_to_sleep)
    try:
        tx_receipt = w3.eth.getTransactionReceipt(result)
    except:
        count = 0
        while tx_receipt is None and (count < 30):
            time.sleep(10)
            tx_receipt = w3.eth.getTransactionReceipt(result)
            count+=1


    if tx_receipt is None:
       print("Resetting Lottery Failed!")
