require_relative '../admin_statistics_digest/base_delegator'

class AdminStatisticsDigest::ActiveResponderDelegator < AdminStatisticsDigest::BaseDelegator

  def topic_category_id(category_id)
    filters[:topic_category_id] = category_id
  end

end
