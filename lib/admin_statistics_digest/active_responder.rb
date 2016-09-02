module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/filter_base'
require_relative '../admin_statistics_digest/active_responder_delegator'

class AdminStatisticsDigest::ActiveResponder < AdminStatisticsDigest::FilterBase

  def to_sql
    return '' if filters[:topic_category_id].nil?

    active_range = {
      first: filters[:active_range].first.to_date,
      last: filters[:active_range].last.to_date
    } if !filters[:active_range].nil? && filters[:active_range].is_a?(Range)
    category_id = filters[:topic_category_id]

    <<~SQL
SELECT p.user_id user_id, s.username, s.name, COUNT(p.*) responds FROM posts p LEFT JOIN users s ON p.user_id = s.id
WHERE p.topic_id IN (SELECT t."id" FROM topics t WHERE t.category_id = #{category_id})

#{"AND ((p.\"created_at\", p.\"created_at\") OVERLAPS ('#{active_range[:first].beginning_of_day}', '#{active_range[:last].end_of_day}') OR p.\"created_at\" = '#{active_range[:first]}' OR p.\"created_at\" = '#{active_range[:last]}')" unless active_range.nil?}

AND p."deleted_at" IS NULL

GROUP BY p.user_id, s.username, s.name
ORDER BY responds DESC;
    SQL
  end

end
