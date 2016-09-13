module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::MostLikedPost < AdminStatisticsDigest::BaseReport
  provide_filter :between
  provide_filter :limit

  def to_sql
    <<~SQL
SELECT "posts".* FROM "posts"
WHERE ("posts"."deleted_at" IS NULL)
#{"AND ((\"posts\".\"created_at\", \"posts\".\"created_at\") OVERLAPS ('#{filters.date_range.first.beginning_of_day}', '#{filters.date_range.last.end_of_day}') OR DATE(\"posts\".\"created_at\") = '#{filters.date_range.first}' OR DATE(\"posts\".\"created_at\") =  '#{filters.date_range.last}')" if filters.date_range }
ORDER BY like_count DESC
#{"LIMIT #{filters.limit}" if filters.limit }
    SQL
  end

end
