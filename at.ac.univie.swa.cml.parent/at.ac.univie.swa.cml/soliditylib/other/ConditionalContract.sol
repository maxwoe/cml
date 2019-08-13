pragma solidity >=0.4.22 <0.7.0;

contract ConditionalContract {

	struct CallContext {
   		 address caller;
  	 	 uint time;
   		 bool success;
	}

	mapping(bytes4 => CallContext) _callMonitor;

	modifier checkAllowed(bytes32 _clause) {
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
		require(msg.sender == _account, "Sender not authorized.");
		return true;
	}

	function when(bool _condition) pure internal returns(bool) {
	    require(_condition);
	    return true;
	}

	function onlyAfter(uint _time, uint _duration, bool _within) view internal returns(bool) {
		if (_time == 0) {
			return false;
		}
		if (!_within) {
			require(now > _time + _duration, "Function called too early.");
		} else {
			require(_time + _duration > now && now > _time, "Function not called within expected timeframe.");
		}
		return true;
	}

	function onlyBefore(uint _time, uint _duration, bool _within) view internal returns(bool) {
		if (_time == 0) {
			return true;
		}
		if (!_within) {
			require(now < _time - _duration, "Function called too late.");
		} else {
			require(_time - _duration < now && now < _time, "Function not called within expected timeframe.");
		}
		return true;
	}

	function actionDone(address _party, bytes4 _action, bool _before) view internal returns(bool) {
		if (_before) {
			require(!(_callMonitor[_action].caller == _party && _callMonitor[_action].success));
		} else {
			require(_callMonitor[_action].caller == _party && _callMonitor[_action].success);
		}
		return true;
	}

	function clauseAllowed(bytes32 _clauseId) internal returns(bool);
	function mostRecentActionTimestamp(bytes32 _clauseId) internal returns(uint);

}
