module Blinky
  class TimeUtil
	
  	SECONDS_IN_MINUTE		 = 60;
  	MINUTES_IN_HOUR      = 60;
  	HOURS_IN_DAY         = 24;
	
  	SECONDS_IN_HOUR      = SECONDS_IN_MINUTE * MINUTES_IN_HOUR
  	SECONDS_IN_DAY       = SECONDS_IN_HOUR * HOURS_IN_DAY
	
  	DAYS_IN_WEEK            = 7;
  	DAYS_IN_MONTH_MIN       = 28;
  	DAYS_IN_MONTH_MAX       = 31;
  	DAYS_IN_YEAR            = 365;
	
  	def self.relative_time(target, relative=Time.now.utc)
  		diff = relative - target.utc
  		result = ''
		
  		if (diff < SECONDS_IN_MINUTE)
  			result = 'A moment ago';
  		elsif (diff < SECONDS_IN_MINUTE * 1.3)
  			result = '1 minute';
  		elsif (diff < SECONDS_IN_HOUR)
  			result = (diff / SECONDS_IN_MINUTE).floor.to_s+' minutes';
  		elsif (diff < SECONDS_IN_HOUR * 2)
  			result = '1 hour';
  		elsif (diff < SECONDS_IN_HOUR * (HOURS_IN_DAY / 1.02))
  			result = (diff / SECONDS_IN_HOUR * 1.02).floor.to_s+' hours';
  		elsif (diff <= SECONDS_IN_DAY * 0.9)
  			result = 'yesterday';
  		elsif (diff <= SECONDS_IN_DAY * DAYS_IN_WEEK)
  			days = (diff / SECONDS_IN_DAY).floor.to_s;
  			result = days+' days';
  		elsif (diff <= SECONDS_IN_DAY * DAYS_IN_MONTH_MIN)
  			numWeeks = (diff / SECONDS_IN_DAY / DAYS_IN_WEEK).floor.to_s;
  			result = numWeeks+' weeks';
  		elsif (diff <= SECONDS_IN_DAY * DAYS_IN_YEAR)
  			numMonths = (diff / SECONDS_IN_DAY / DAYS_IN_MONTH_MIN).floor.to_s;
  			result = numMonths+' months';
  		elsif (diff > SECONDS_IN_DAY * DAYS_IN_YEAR)
  			numYears = (diff / SECONDS_IN_DAY / DAYS_IN_YEAR).floor.to_s;
  			result = numYears+' years';
  		end
		
  		return result
  	end
  end
end