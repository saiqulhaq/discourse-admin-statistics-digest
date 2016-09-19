module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::ActiveResponder < AdminStatisticsDigest::BaseReport
  class << self
    def monitored_topic_categories
      PluginStore.get(AdminStatisticsDigest.plugin_name, 'active_responder-monitored_categories')
    end

    # @params categories Array of Category#id
    def monitored_topic_categories=(categories)
      PluginStore.set(AdminStatisticsDigest.plugin_name, 'active_responder-monitored_categories', categories)
    end
  end

  provide_filter :limit
  provide_filter :topic_category_id
  provide_filter :active_range

  def to_sql
    return '' if filters.topic_category_id.nil?

    category_id = filters.topic_category_id

    <<~SQL
SELECT s.id AS user_id, s.username, s.name, COUNT(p.*) responds FROM #{Post.table_name} p LEFT JOIN users s ON p.user_id = s.id
WHERE p.topic_id IN (SELECT t."id" FROM #{Topic.table_name} t WHERE t.category_id = #{category_id})

    #{"AND ((p.\"created_at\", p.\"created_at\") OVERLAPS ('#{filters.active_range.first.beginning_of_day}', '#{filters.active_range.last.end_of_day}') OR DATE(p.\"created_at\") = '#{filters.active_range.first}' OR DATE(p.\"created_at\") = '#{filters.active_range.last}')" unless filters.active_range.nil?}

AND p."deleted_at" IS NULL

GROUP BY s.id, s.username, s.name
ORDER BY responds DESC
#{"LIMIT #{limit}" if limit }
    SQL
  end

end
