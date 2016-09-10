module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::ActiveResponder < AdminStatisticsDigest::BaseReport
  provide_filter :limit
  provide_filter :topic_category_id
  provide_filter :between

  def to_sql
    return '' if filters.topic_category_id.nil?

    category_id = filters.topic_category_id

    <<~SQL
SELECT p.user_id user_id, s.username, s.name, COUNT(p.*) responds FROM #{Post.table_name} p LEFT JOIN users s ON p.user_id = s.id
WHERE p.topic_id IN (SELECT t."id" FROM #{Topic.table_name} t WHERE t.category_id = #{category_id})

#{"AND ((p.\"created_at\", p.\"created_at\") OVERLAPS ('#{filters.date_range.first.beginning_of_day}', '#{filters.date_range.last.end_of_day}') OR DATE(p.\"created_at\") = '#{filters.date_range.first}' OR DATE(p.\"created_at\") = '#{filters.date_range.last}')" unless filters.date_range.nil?}

AND p."deleted_at" IS NULL

GROUP BY p.user_id, s.username, s.name
ORDER BY responds DESC
#{"LIMIT #{limit}" if limit }
    SQL
  end

end
