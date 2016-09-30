require 'delegate'
class AdminStatisticsDigest::BaseDelegator < SimpleDelegator

  def date_range(date_range)
    filters[:date_range] = date_range
  end

  def limit(default)
    filters[:limit] = default
  end

end
