pragma solidity >=0.4.22 <0.7.0;

library DateTime {
    uint constant MINUTE_IN_SECONDS = 60;
    uint constant HOUR_IN_SECONDS = 3600;
    uint constant DAY_IN_SECONDS = 86400;
    uint constant WEEK_IN_SECONDS = 604800;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint constant ORIGIN_YEAR = 1970;

    struct _DateTime {
        uint year;
        uint month;
        uint day;
        uint hour;
        uint minute;
        uint second;
        uint weekday;
    }

    function isLeapYear(uint year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint month, uint year) public pure returns (uint) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
                return 30;
        }
        else if (isLeapYear(year)) {
                return 29;
        }
        else {
                return 28;
        }
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
                secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                if (secondsInMonth + secondsAccountedFor > timestamp) {
                        dt.month = i;
                        break;
                }
                secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                        dt.day = i;
                        break;
                }
                secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint) {
        uint secondsAccountedFor = 0;
        uint year;
        uint numLeapYears;

        // Year
        year = ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS;
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
                if (isLeapYear(year - 1)) {
                        secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                }
                else {
                        secondsAccountedFor -= YEAR_IN_SECONDS;
                }
                year -= 1;
        }
        return year;
    }

    function getMonth(uint timestamp) public pure returns (uint) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint) {
        return (timestamp / 60 / 60) % 24;
    }

    function getMinute(uint timestamp) public pure returns (uint) {
        return (timestamp / 60) % 60;
    }

    function getSecond(uint timestamp) public pure returns (uint) {
        return timestamp % 60;
    }

    function getWeekday(uint timestamp) public pure returns (uint) {
        return (timestamp / DAY_IN_SECONDS + 4) % 7;
    }

    function toTimestamp(uint year, uint month, uint day) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint year, uint month, uint day, uint hour) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint year, uint month, uint day, uint hour, uint minute) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {
        uint i;

        // Year
        for (i = ORIGIN_YEAR; i < year; i++) {
                if (isLeapYear(i)) {
                        timestamp += LEAP_YEAR_IN_SECONDS;
                }
                else {
                        timestamp += YEAR_IN_SECONDS;
                }
        }

        // Month
        uint[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
                monthDayCounts[1] = 29;
        }
        else {
                monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i < month; i++) {
                timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }

        // Day
        timestamp += DAY_IN_SECONDS * (day - 1);

        // Hour
        timestamp += HOUR_IN_SECONDS * (hour);

        // Minute
        timestamp += MINUTE_IN_SECONDS * (minute);

        // Second
        timestamp += second;

        return timestamp;
    }

	function equals(uint timestamp1, uint timestamp2) public pure returns(bool){
		if(timestamp1 == timestamp2) {
		    return true;
		} else {
			return false;
		}
	}

    function isBefore(uint timestamp1, uint timestamp2) public pure returns (bool) {
        if (timestamp1 < timestamp2) {
            return true;
        } else {
            return false;
        }
    }

    function isAfter(uint timestamp1, uint timestamp2) public pure returns (bool) {
        return !isBefore(timestamp1, timestamp2);
    }

    function addDuration(uint timestamp1, uint timestamp2) public pure returns(uint) {
		return timestamp1 + timestamp2;
	}

	function substractDuration(uint timestamp1, uint timestamp2) public pure returns(uint) {
		return timestamp1 - timestamp2;
	}

	function durationBetween(uint timestamp1, uint timestamp2) public pure returns(uint) {
		if (timestamp1 > timestamp2) {
			return timestamp1 - timestamp2;
		} else if (timestamp2 > timestamp1) {
			return timestamp2 - timestamp1;
		} else {
			return 0;
		}
	}

	function toMinutes(uint timestamp) public pure returns (uint) {
        return (timestamp / 60);
    }

    function toHours(uint timestamp) public pure returns (uint) {
        return (timestamp / 60 / 60);
    }

    function toDays(uint timestamp) public pure returns (uint) {
        return (timestamp / 60 / 60 / 24);
    }

    function toWeeks(uint timestamp) public pure returns (uint) {
        return (timestamp / 60 / 60 / 24 / 7);
    }

}