pragma solidity >=0.4.22 <0.7.0;

import "./SafeMath.sol";

contract Payment is Secondary {
    using SafeMath for uint256;
    mapping(address => uint256) private _balanceOf;		
    
    function balanceOf(address _address) internal view returns (uint256) {
        return _balanceOf[_address];
	}

    function deposit(uint256 amount) internal 
    {
    	require(msg.value == amount);
    	_balanceOf[msg.sender] = _balanceOf[msg.sender].add(amount);
    }
    
    function withdraw() public 
    {
    	uint balance = _balanceOf[msg.sender];
        _balanceOf[msg.sender] = 0;
        msg.sender.transfer(balance);
    }
    
    function transfer(address from, address to, uint256 amount) internal 
    {
    	_balanceOf[from] = _balanceOf[from].sub(amount);
		_balanceOf[to] = _balanceOf[to].add(amount);
    }
}