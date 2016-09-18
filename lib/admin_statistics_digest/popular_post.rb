module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::PopularPost < AdminStatisticsDigest::BaseReport
  provide_filter :popular_by_month
  provide_filter :limit

  def initialize
    super
    ScoreCalculator.new.calculate
  end

  def to_sql
    posts = Post.joins(topic: :category).select(:id, 'topics.id AS topic_id', 'topics.title AS topic_title', 'topics.slug AS topic_slug', 'categories.name AS category_name', :percent_rank).
      where('post_number > 1').order('percent_rank desc')
    posts = posts.where(created_at: filters.popular_by_month) if filters.popular_by_month
    posts = posts.limit(filters.limit) if filters.limit
    posts.to_sql
  end

end
