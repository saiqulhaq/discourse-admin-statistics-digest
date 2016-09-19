module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::MostRepliedTopic < AdminStatisticsDigest::BaseReport
  provide_filter :most_replied_by_month
  provide_filter :limit

  def to_sql
    if filters.most_replied_by_month
      topics = Post.select('posts.topic_id AS id', 'topics.slug AS slug', 'topics.title AS title', 'categories.name AS category').joins(topic: :category).where(created_at: filters.most_replied_by_month).
        group(:topic_id, 'topics.slug', 'topics.title', 'categories.name')
    else
      topics = Topic.joins(:category).select(:id, :slug, :title, 'categories.name AS category').order('posts_count DESC')
    end
    topics = topics.limit(filters.limit) if filters.limit
    topics.to_sql
  end

end
