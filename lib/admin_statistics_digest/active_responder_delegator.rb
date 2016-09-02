require 'delegate'

class AdminStatisticsDigest::ActiveResponderDelegator < SimpleDelegator

  def date_range(date_range)
    filters[:date_range] = date_range
  end

  def topic_category_id(category_id)
    filters[:topic_category_id] = category_id
  end
end
