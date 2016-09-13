module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::MostRepliedTopic < AdminStatisticsDigest::BaseReport
  provide_filter :most_replied_by_month
  provide_filter :limit

  def to_sql
    if filters.most_replied_by_month
      topics = Post.select('topic_id AS id').where(created_at: filters.most_replied_by_month).
        group(:topic_id)
    else
      topics = Topic.select('id').order('posts_count DESC')
    end
    topics = topics.limit(filters.limit) if filters.limit
    topics.to_sql
  end

end
