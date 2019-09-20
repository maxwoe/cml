/*
based on https://github.com/dapphub/ds-math/blob/master/src/math.sol

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as publied by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity >=0.4.22 <0.7.0;

library FPMath {
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