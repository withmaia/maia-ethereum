# Maia Ethereum

Proof of concept to run Internet of Things deployments operating in tandem with smart contracts.

Uses eve-node, which presents a simple surface to interact with parts of contracts from thin clients.

## Setup

##### clone the repo

    $ git clone https://github.com/withmaia/maia-ethereum

##### install modules

    $ cd withmaia
    $ npm install

##### (deploy DoorLock contract)

    With your favorite client.

##### Configure maia with an address she can use and the address of the DoorLock contract

    module.exports = 
        oracle_address: '0x0'
        lock_address: '0x0'


##### (add maia's address as a trusted opener of the door)

By calling `permitAddress(oracle_address)` from the address that created your contract

    function permitAddress(address _permitted_a) only_owner {
        permitted[_permitted_a] = true;
    }

Calls to unlock the door will be permissioned with the `only_permitted` modifier. The "_;" step in the modifier runs the modified function as coded.

    function unlockDoor() only_permitted {
        Unlock(msg.sender);
        LogKind(msg.sender, 'unlocked');
    }

    modifier only_permitted() {
        if (!permitted[msg.sender]) {
            LogKind(msg.sender, 'strange-knocker');
        } else {
            _;
        }
    }

##### run the service

    /maia-ethereum$ coffee service.coffee


## Methods

##### `unlockDoor: (commander, cb) ->`

Exposed on the service so maia users can ask her to open the door for them. Should implement or occur downstream from some authentication step so not just anybody can make maia open the lock.

##### `handleEvent = (err, filter_result) ->`

The service subscribes to [events](https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI#events) on the lock contract, which will fire whenever somebody tries to open it. The service translates these events from the raw bytecode into json to be used for keyying commands to the local system.

