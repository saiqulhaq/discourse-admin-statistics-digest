module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/filter_base'
require_relative '../admin_statistics_digest/active_responder_delegator'

class AdminStatisticsDigest::ActiveResponder < AdminStatisticsDigest::FilterBase

  def to_sql
    return '' if filters[:topic_category_id].nil?

    category_id = filters[:topic_category_id]

    <<~SQL
SELECT p.user_id user_id, s.username, s.name, COUNT(p.*) responds FROM #{Post.table_name} p LEFT JOIN users s ON p.user_id = s.id
WHERE p.topic_id IN (SELECT t."id" FROM #{Topic.table_name} t WHERE t.category_id = #{category_id})

#{"AND ((p.\"created_at\", p.\"created_at\") OVERLAPS ('#{date_range[:first].beginning_of_day}', '#{date_range[:last].end_of_day}') OR p.\"created_at\" = '#{date_range[:first]}' OR p.\"created_at\" = '#{date_range[:last]}')" unless date_range.nil?}

AND p."deleted_at" IS NULL

GROUP BY p.user_id, s.username, s.name
ORDER BY responds DESC;
    SQL
  end

end
