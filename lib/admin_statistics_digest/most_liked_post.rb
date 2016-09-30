module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::MostLikedPost < AdminStatisticsDigest::BaseReport
  provide_filter :active_range
  provide_filter :limit

  def to_sql
    <<~SQL
SELECT "posts"."cooked" AS "content", "posts"."id", "topics"."title" AS "topic_title", "posts"."topic_id", "topics"."slug" AS "topic_slug" FROM "posts"
LEFT JOIN topics ON "topics"."id" = "posts"."topic_id"
LEFT JOIN categories ON "categories"."id" = "topics"."category_id"
WHERE ("posts"."deleted_at" IS NULL)
#{"AND ((\"posts\".\"created_at\", \"posts\".\"created_at\") OVERLAPS ('#{filters.active_range.first.beginning_of_day}', '#{filters.active_range.last.end_of_day}') OR DATE(\"posts\".\"created_at\") = '#{filters.active_range.first}' OR DATE(\"posts\".\"created_at\") =  '#{filters.active_range.last}')" if filters.active_range }
ORDER BY "posts"."like_count" DESC
#{"LIMIT #{filters.limit}" if filters.limit }
    SQL
  end

end
