pragma solidity >=0.4.22 <0.7.0;

library RealLib {

 	function max(uint a, uint b) public pure returns(uint){
		return a >= b ? a : b;
 	}

  	function min(uint a, uint b) public pure returns(uint){
		return a < b ? a : b;
	}

	function sqrt(uint x) pure public returns(uint y){
 		if (x == 0) return 0;
 		uint z = (x + 1) / 2;
 		y = x;
 		uint help = 1;
 		while (z < y){
 			help = help*10;
 			y = z;
			z = ((x / z) + z) / 2;
		}
		return y;
	}

	function ceil(uint x, uint decimals) pure public returns(uint){
		return ((x + fixedPoint(decimals) - 1) / fixedPoint(decimals)) * fixedPoint(decimals);
	}

	function floor(uint x, uint decimals) pure public returns(uint){
		return (x / (fixedPoint(decimals))) * fixedPoint(decimals);
	}

	function toInteger(uint x, uint decimals) pure public returns(uint){
		return (x / fixedPoint(decimals)) * fixedPoint(decimals);
    }

    function fixedPoint(uint decimals) pure internal returns(uint){
    	return 10**decimals;
    }
}