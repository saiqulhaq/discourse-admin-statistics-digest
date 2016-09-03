module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/filter_base'
require_relative '../admin_statistics_digest/popular_post_delegator'

class AdminStatisticsDigest::PopularTopic < AdminStatisticsDigest::FilterBase

  def to_sql
    score = :monthly_score

    topics = Topic.where("\"created_at\" between '#{date_range[:first].to_date}' AND '#{date_range[:last].to_date}'").listable_topics.includes(:category)

    topics = topics.joins("LEFT OUTER JOIN top_topics ON top_topics.topic_id = topics.id")
               .order(TopicQuerySQL.order_top_for(score))

    # topics = topics.limit(5)

    # Remove category topics
    category_topic_ids = Category.pluck(:topic_id).compact!
    if category_topic_ids.present?
      topics = topics.where("topics.id NOT IN (?)", category_topic_ids)
    end

    # Remove muted categories
    if SiteSetting.digest_suppress_categories.present?
      muted_category_ids = SiteSetting.digest_suppress_categories.split("|").map(&:to_i)

      if muted_category_ids.present?
        topics = topics.where("topics.category_id NOT IN (?)", muted_category_ids)
      end
    end

    @featured_topics, @new_topics = topics[0..4], topics[5..-1]
  end

end
