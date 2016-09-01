module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/filter_base'
require_relative '../admin_statistics_digest/active_user_delegator'

class AdminStatisticsDigest::ActiveUser < AdminStatisticsDigest::FilterBase

  def initialize
    @filters = {
      include_staff: false
    }
  end

  def to_sql
    active_range = {
      first: filters[:active_range].first.to_date,
      last: filters[:active_range].last.to_date
    } if !filters[:active_range].nil? && filters[:active_range].is_a?(Range)

    including_staff  = filters[:include_staff].nil? ? false : filters[:include_staff]

    using_signed_up_since_filter = filters[:signed_up_between].is_a?(Hash) && filters[:signed_up_between][:from].present? && filters[:signed_up_between][:to].nil?
    signed_up_since = filters[:signed_up_between][:from] if using_signed_up_since_filter

    signed_up_between = filters[:signed_up_between] if filters[:signed_up_between].is_a?(Hash) && filters[:signed_up_between][:from].present? && filters[:signed_up_between][:to].present?

    signed_up_before = filters[:signed_up_before] if filters[:signed_up_before].present?

    <<~SQL
          SELECT ut.*, count(Reply) as "replies", ut."topics" + count(Reply) AS "total" FROM "posts" as Reply RIGHT JOIN (

             SELECT u.*, count(t) as "topics" FROM "topics" as t RIGHT JOIN (

                  SELECT "id" "user_id", "username", "name", EXTRACT(EPOCH FROM "created_at") "signed_up_at" from "users" WHERE "id" > 0
                    #{" AND (\"admin\" = false AND \"moderator\" = false)" unless including_staff}

                    #{" AND (\"created_at\" >= '#{signed_up_since}')" if defined?(signed_up_since) && signed_up_since.is_a?(Date)}

                    #{" AND (\"created_at\" < '#{signed_up_before}')" if defined?(signed_up_before) && signed_up_before.is_a?(Date)}

                    #{" AND ((\"created_at\", \"created_at\") OVERLAPS ('#{signed_up_between[:from].beginning_of_day}', '#{signed_up_between[:to].end_of_day}') OR \"created_at\" = '#{signed_up_between[:from]}' OR \"created_at\" = '#{signed_up_between[:to]}')" if defined?(signed_up_between) && !signed_up_between.nil?}

                    ORDER BY "created_at" DESC
             ) as u ON t."user_id" = u."user_id"

             #{"AND ((t.\"created_at\", t.\"created_at\") OVERLAPS ('#{active_range[:first].beginning_of_day}', '#{active_range[:last].end_of_day}') OR t.\"created_at\" = '#{active_range[:first]}' OR t.\"created_at\" = '#{active_range[:last]}')" if defined?(active_range) && !active_range.nil?}

             GROUP BY u."user_id", u."username", u."name", u."signed_up_at"
          )

          AS ut ON ut."user_id" = Reply."user_id"  AND (Reply."topic_id" IN (SELECT "id" from "topics" WHERE("topics"."archetype" = 'regular')))
          AND (Reply."deleted_at" IS NULL)
          #{"AND ((Reply.\"created_at\", Reply.\"created_at\") OVERLAPS ('#{active_range[:first].beginning_of_day}', '#{active_range[:last].end_of_day}') OR Reply.\"created_at\" = '#{active_range[:first]}' OR Reply.\"created_at\" =  '#{active_range[:last]}')" if defined?(active_range) && !active_range.nil?}

          GROUP BY ut."user_id", ut."username", ut."name", ut."signed_up_at", ut."topics"
          ORDER BY ut."topics" + COUNT(Reply) DESC, ut."signed_up_at" ASC
          #{"LIMIT #{filters[:limit].to_i}" if filters[:limit].to_i > 0 }
    SQL
  end

end
