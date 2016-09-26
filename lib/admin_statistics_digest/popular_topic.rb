module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::PopularTopic < AdminStatisticsDigest::BaseReport
  provide_filter :popular_by_month
  provide_filter :popular_by_date
  provide_filter :limit

  def initialize
    super
    TopTopic.refresh!
    filters.popular_by_month(1.month.ago) if filters.popular_by_month.nil?
  end

  def to_sql
    topics = TopTopic.joins(topic: :category).select(:topic_id, 'topics.title AS title', 'topics.slug AS slug', 'categories.name AS category').
      where(topic_id: Topic.where(created_at: filters.popular_by_month).pluck(:id)).order('monthly_score DESC')
    topics = topics.limit(filters.limit) if filters.limit
    topics.to_sql
  end
end

