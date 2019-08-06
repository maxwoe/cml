pragma solidity >=0.4.22 <0.7.0;

// based on https://github.com/dapphub/ds-math/blob/master/src/math.sol

contract FPMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "add-overflow");
    }
    
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-underflow");
    }
    
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function fpmul(uint x, uint y, uint decimals) internal pure returns (uint z) {
        z = add(mul(x, y), 10 ** decimals / 2) / 10 ** decimals;
    }
    
    function fpdiv(uint x, uint y, uint decimals) internal pure returns (uint z) {
        z = add(mul(x, 10 ** decimals), y / 2) / y;
    }

	function fppow(uint x, uint n, uint decimals) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : 10 ** decimals;

        for (n /= 2; n != 0; n /= 2) {
            x = fpmul(x, x, decimals);

            if (n % 2 != 0) {
                z = fpmul(z, x, decimals);
            }
        }
    }
}