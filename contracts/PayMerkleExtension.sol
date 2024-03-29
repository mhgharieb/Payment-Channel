pragma solidity ^0.4.18;

contract PayMerkleExtended {
    address public channelSender;
    address public channelRecipient;
    uint public startDate;
    uint public channelTimeout;
    bytes32 public root;

    function PayMerkleExtended(address to, uint _timeout, bytes32 _root) public payable {
        require(msg.value>0);
        channelRecipient = to;
        channelSender = msg.sender;
        startDate = now;
        channelTimeout = _timeout;
        root = _root;
    }
    function AddBalance(bytes32 _newRoot) public payable {
      if (root < _newRoot)
          root = keccak256(root, _newRoot);
      else
          root = keccak256(_newRoot, root);
    }
  function CloseChannel(uint256 _amount, uint256 _random, bytes32[] proof) public {
        require(msg.sender==channelRecipient);
        bytes32 computedHash = keccak256(_amount,_random);
        for (uint256 i = 0; i < proof.length; i++) {
          bytes32 proofElement = proof[i];
          if (computedHash < proofElement)
            computedHash = keccak256(computedHash, proofElement);
          else
            computedHash = keccak256(proofElement, computedHash);
          }
        require(computedHash==root);
        channelRecipient.transfer(_amount);
        selfdestruct(channelSender);
    }
    
    function ChannelTimeout() public {
        require(now >= startDate + channelTimeout);
        selfdestruct(channelSender);
    }
}
