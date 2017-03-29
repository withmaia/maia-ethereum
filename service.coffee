fs = require 'fs'
somata = require 'somata'
client = new somata.Client

Hue = client.remote.bind client, 'maia:hue'

config = require './config'

{lock_address} = config
eve = require('eve-node')({eth_addresses: [config.oracle_address]})

contract_schema = {
    'DoorLock': fs.readFileSync("./contracts/door-lock.sol").toString()
}

{abis, contracts, decodeEvent, callFunction} = eve.buildGenericMethods contract_schema

subscribeContract = (address, fn) ->
    eve.web3.eth.getBlockNumber (err, fromBlock) ->
        filter = eve.web3.eth.filter({fromBlock, toBlock: 'latest', lock_address})
        filter.watch fn

handleEvent = (err, filter_result) ->

    # Parsing parameters from event thrown from contract
    {from, kind} = decodeEvent 'DoorLock', filter_result
    console.log "#{from} did a #{kind}"

    if kind == 'strange-knocker'
        # Turn the light red...
        Hue 'setRGB', 1, 255, 20, 20, (err, resp) ->
    else
        # Kick off any critical entry-dependent financial transactions you require
        # LockService 'unlock', ...
        Hue 'setState', 1, {on: true, hue: 120, sat: 120, bri: 255}, (err, resp) ->

subscribeContract lock_address, handleEvent

service = new somata.Service 'maia:ethereum', {

    unlockDoor: (commander, cb) ->
        console.log "#{commander} asked to unlock the door."
        callFunction 'DoorLock', 'unlockDoor', (err, txid) ->
            console.log # ...
}