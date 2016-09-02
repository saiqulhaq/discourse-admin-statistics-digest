require_relative '../admin_statistics_digest/base_delegator'

class AdminStatisticsDigest::ActiveUserDelegator < AdminStatisticsDigest::BaseDelegator

  # include Admin and Moderator user into query
  def include_staff(default = true)
    filters[:include_staff] = default
  end

  def signed_up_since(date)
    filters[:signed_up_between] = { from: date.to_date, to: nil}
  end

  def signed_up_before(date)
    filters[:signed_up_before] = date.to_date
  end

  def signed_up_between(from:, to:)
    filters[:signed_up_between] = { from: from.to_date, to: to.to_date}
  end

end
