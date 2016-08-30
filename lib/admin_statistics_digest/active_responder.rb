module AdminStatisticsDigest
end

class AdminStatisticsDigest::ActiveResponder
  def initialize(&block)
    if block_given?
      if block.arity == 1
        yield self
      else
        instance_eval &block
      end
    end
  end

  def to_sql
    'SQL Active Responder'
  end
end
