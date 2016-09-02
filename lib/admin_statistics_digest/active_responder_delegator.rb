require 'delegate'

class AdminStatisticsDigest::ActiveResponderDelegator < SimpleDelegator

  def active_range(date)
    filters[:active_range] = date
  end

  def topic_category_id(category_id)
    filters[:topic_category_id] = category_id
  end
end
