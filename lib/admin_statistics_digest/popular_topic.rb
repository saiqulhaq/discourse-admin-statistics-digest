module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::PopularTopic < AdminStatisticsDigest::BaseReport
  provide_filter :popular_by_month

  def initialize
    super
    TopTopic.refresh!
  end

  def to_sql
    filters.popular_by_month(1.month.ago) if filters.popular_by_month.nil?
    TopTopic.select(:topic_id).where(topic_id: Topic.where(created_at: filters.popular_by_month).pluck(:id)).order('monthly_score DESC').to_sql
  end
end

