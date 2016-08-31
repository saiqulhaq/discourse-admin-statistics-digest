module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/active_user_delegator'

class AdminStatisticsDigest::ActiveUser
  attr_accessor :filters

  def self.build(&block)
    new.tap {|s| s.__yield_dsl(&block) }
  end

  def rebuild(&block)
    self.tap {|s| s.__yield_dsl(&block) }
  end

  def initialize
    @filters = {
      include_staff: false
    }
  end

  def execute
    result = []
    err = nil
    begin
      ActiveRecord::Base.connection.transaction do
        ActiveRecord::Base.exec_sql 'SET TRANSACTION READ ONLY'
        ActiveRecord::Base.exec_sql 'SET LOCAL statement_timeout = 10000'
        result = ActiveRecord::Base.exec_sql(to_sql)
        result.check

        raise ActiveRecord::Rollback
      end
    rescue Exception => ex
      raise ex if Rails.env.test?
      err = ex
    end

    {
      error: err,
      data: result.entries
    }
  end

  def __yield_dsl(&block)
    delegator = AdminStatisticsDigest::ActiveUserDelegator.new(self)
    delegator.instance_eval(&block)
  end

  private
  def to_sql
    active_range = {
      first: filters[:active_range].first.to_date,
      last: filters[:active_range].last.to_date
    } if !filters[:active_range].nil? && filters[:active_range].is_a?(Range)

    including_staff  = filters[:include_staff].nil? ? false : filters[:include_staff]

    using_signed_up_from_filter = filters[:signed_up_between].is_a?(Hash) && filters[:signed_up_between][:from].present? && filters[:signed_up_between][:to].nil?
    signed_up_from = filters[:signed_up_between][:from].to_date if using_signed_up_from_filter

    <<~SQL
          SELECT ut.*, count(Reply) as "replies", ut."topics" + count(Reply) AS "total" FROM "posts" as Reply RIGHT JOIN (

             SELECT u.*, count(t) as "topics" FROM "topics" as t RIGHT JOIN (

                  SELECT "id" "user_id", "username", "name" from "users" WHERE "id" > 0
                    #{" AND (\"admin\" = false AND \"moderator\" = false)" unless including_staff}
                    #{" AND (\"created_at\" >= '#{signed_up_from}')" if defined?(signed_up_from) && !signed_up_from.nil?}
                  ) as u ON t."user_id" = u."user_id"

             #{"AND (t.\"created_at\" BETWEEN '#{active_range[:first]}' AND '#{active_range[:last]}')" if defined?(active_range) && !active_range.nil?}

          GROUP BY u."user_id", u."username", u."name" )

          AS ut ON ut."user_id" = Reply."user_id"  AND (Reply."topic_id" IN (SELECT "id" from "topics" WHERE("topics"."archetype" = 'regular')))
          AND (Reply."deleted_at" IS NULL)
          #{"AND (Reply.\"created_at\" BETWEEN '#{active_range[:first]}' AND '#{active_range[:last]}')" if defined?(active_range) && !active_range.nil?}

          GROUP BY  ut."user_id", ut."username", ut."name", ut."topics"
          ORDER BY "total" DESC
          #{"LIMIT #{filters[:limit].to_i}" if filters[:limit].to_i > 0 }
    SQL
  end

end
