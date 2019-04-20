pragma solidity >=0.4.22 <0.7.0;

contract Owned {
	address public _owner;

  	modifier onlyOwner() {
		require(msg.sender == _owner); _;
	}
 
  	constructor () internal {
    	_owner = msg.sender;
    }

  	function changeOwner(address newOwner) public onlyOwner {
		require(newOwner != address(0));
    	_owner = newOwner;
	}
}