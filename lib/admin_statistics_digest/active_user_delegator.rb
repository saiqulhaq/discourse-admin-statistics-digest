require 'delegate'

class AdminStatisticsDigest::ActiveUserDelegator < SimpleDelegator

  # include Admin and Moderator user into query
  def include_staff(default = true)
    filters[:include_staff] = default
  end

  def limit(default)
    filters[:limit] = default
  end

  def active_range(range)
    filters[:active_range] = range
  end

  def signed_up_from(date)
    filters[:signed_up_between] = { from: date, to: nil}
  end

  def signed_up_between(from:, to:)
    filters[:signed_up_between] = { from: from, to: to}
  end
end
