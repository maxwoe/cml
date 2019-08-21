pragma solidity >=0.4.22 <0.7.0;

contract ConditionalContract {

	struct CallContext {
   		 address caller;
  	 	 uint time;
   		 bool success;
	}

	mapping(bytes4 => CallContext) _callMonitor;

	modifier checkAllowed(bytes32 _clause) {
	 	require(contractObeyed());
	    require(clauseAllowed(_clause), "Clause not allowed to start.");
        _;
        setCallContext();
	}

	modifier postCall() {
		_;
		setCallContext();
	}
	
	function setCallContext() internal {
		_callMonitor[msg.sig].success = true;
		_callMonitor[msg.sig].time = now;
		_callMonitor[msg.sig].caller = msg.sender;
	}

	function onlyBy(address _account) view internal returns(bool) {
		if (msg.sender == _account)
		    return true;
		return false;
	}

	function onlyAfter(uint _time, uint _duration, bool _within) view internal returns(bool) {
		if (_time == 0) {
			return false;
		}
		if (!_within) {
			if (now > _time + _duration) // else function called too early
			    return true;
		} else {
			if (_time + _duration > now && now > _time) // else function not called within expected timeframe
			    return true;
		}
		return false;
	}

	function onlyBefore(uint _time, uint _duration, bool _within) view internal returns(bool) {
		if (_time == 0) {
			return true;
		}
		if (!_within) {
			if (now < _time - _duration) // else function called too late
			    return true;
		} else {
			if (_time - _duration < now && now < _time) // else function not called within expected timeframe
			    return true;
		}
		return false;
	}
		
	function callSuccess(bytes4 _selector) internal view returns (bool) {
        return _callMonitor[_selector].success;
    }
    
    function callTime(bytes4 _selector) internal view returns (uint) {
        return _callMonitor[_selector].time;
    }
    
    function callCaller(bytes4 _selector) internal view returns (address) {
        return _callMonitor[_selector].caller;
    }
	
	function clauseAllowed(bytes32 _clauseId) internal returns(bool);
	function clauseFulfilledTime(bytes32 _clauseId) internal returns(uint);
	function contractObeyed() internal returns(bool);
}
