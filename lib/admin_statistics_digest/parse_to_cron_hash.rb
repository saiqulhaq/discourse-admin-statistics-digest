module AdminStatisticsDigest
  class ParseToCronHash

    ParserResult = Struct.new(:valid?, :cron_hash, :message)

    class InvalidFormat < StandardError; end

    def parse(min, hour, day)
      message = nil
      begin
        parse_min(min)
        parse_hour(hour)
        parse_day(day)
        valid = true
      rescue InvalidFormat => e
        message = e.message
        valid = false
      end
      ParserResult.new(valid, to_cron_hash, message).freeze
    end

    private
    attr_accessor :min, :hour, :day # in hash format

    def to_cron_hash
      "#{min} #{hour} #{day} * *"
    end

    def parse_min(min)
      raise InvalidFormat, 'Invalid minute' unless (0..59).include?(min)
      self.min = min
    end

    def parse_hour(hour)
      raise InvalidFormat, 'Invalid hour' unless (0..23).include?(hour)
      self.hour = hour
    end

    def parse_day(day)
      raise InvalidFormat, 'Invalid day' unless (1..30).include?(day)
      self.day = day
    end

    class << self
      def parse(min, hour, day)
        self.new.parse(min, hour, day)
      end
    end
  end
end
