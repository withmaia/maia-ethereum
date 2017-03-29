pragma solidity ^0.4.0;

contract DoorLock {

    address public owner;
    uint public num_permitted;
    mapping(address => bool) permitted;

    modifier only_owner() {
        if (msg.sender != owner) throw;
        _;
    }
    event LogKind(address from, string kind);

    modifier only_permitted() {
        if (!permitted[msg.sender]) {
            LogKind(msg.sender, 'strange-knocker');
        } else {
            _;
        }
    }

    event Unlock(address unlocker);

    function DoorLock() {
        owner = msg.sender;
        permitAddress(msg.sender);
    }

    function unlockDoor() only_permitted {
        Unlock(msg.sender);
        LogKind(msg.sender, 'unlocked');
    }

    function permitAddress(address _permitted_a) only_owner {
        permitted[_permitted_a] = true;
    }

    function unpermitAddress(address _unpermitted_a) only_owner {
        permitted[_unpermitted_a] = false;
    }
}
