pragma solidity >=0.4.22 <0.7.0;

library IntLib {

	function average(uint a, uint b) public pure returns(uint){
     	return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

	function max(uint a, uint b) public pure returns(uint){
     	return a >= b ? a : b;
    }

 	function min(uint a, uint b) public pure returns(uint){
     	return a < b ? a : b;
    }

	function toReal(uint x) public pure returns(uint){
     	return x;
    }
}