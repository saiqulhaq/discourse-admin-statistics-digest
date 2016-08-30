module AdminStatisticsDigest
end

require_relative '../admin_statistics_digest/active_user_delegator'

class AdminStatisticsDigest::ActiveUser
  attr_accessor :filters

  def self.build(&block)
    active_user = new
    delegator = AdminStatisticsDigest::ActiveUserDelegator.new(active_user)
    delegator.instance_eval(&block)
    active_user
  end

  def initialize
    self.filters = {
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

  private
  def to_sql
    including_staff     = filters[:include_staff].nil? ? false : filters[:include_staff]

    sql = "SELECT t1.\"id\" AS \"user_id\" from \"#{User.table_name}\" AS t1 WHERE t1.\"id\" > 0"

    # if !!signed_up_from
    #   sql += " AND (#{left_table_alias}.\"created_at\" >= '#{signed_up_from}')"
    # end

    # sql += if !!signed_up_between
    #          " AND (#{left_table_alias}.\"created_at\" BETWEEN '#{signed_up_between.first}' AND '#{signed_up_between.last}')"
    #        elsif !!active_range
    #          "AND (#{left_table_alias}.\"created_at\" <= '#{active_range.first}')"
    #        else
    #          ''
    #        end

    unless including_staff
      sql += " AND (t1.\"admin\" = false AND t1.\"moderator\" = false)"
    end

    sql = "SELECT t2.*, count(t3) as \"topics\" FROM \"#{Topic.table_name}\" as t3 RIGHT JOIN (#{sql}) AS t2 ON t3.\"user_id\" = t2.\"user_id\" "
    # sql += " AND (#{right_table_alias}.\"created_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?

    sql += ' GROUP BY t2."user_id" '

    sql = "SELECT t4.*, count(t5) as \"replies\" FROM \"#{Post.table_name}\" as t5 RIGHT JOIN (#{sql}) AS t4 ON t5.\"user_id\" = t4.\"user_id\" "
    sql += " AND (t5.\"topic_id\" IN (SELECT \"id\" from \"#{Topic.table_name}\" WHERE(\"topics\".\"archetype\" = 'regular'))) AND (t5.\"deleted_at\" IS NULL)"
    # sql += " AND (#{right_table_alias}.\"created_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?

    sql += ' GROUP BY t4."user_id", t4.topics '

    sql += " LIMIT #{filters[:limit].to_i}" if filters[:limit].to_i > 0

    "SELECT users.name, users.username, res.* from users AS users RIGHT JOIN (#{sql}) as res ON users.id = res.user_id"
  end


  def group_by(table_name, groups)
    return ' ' unless groups.present?
    sql = ' GROUP BY '
    groups.each do |group|
      sql += " #{table_name}.\"#{group}\" "
      sql += ', ' if group != groups.last
    end
    sql
  end

  def order_by(orders)
    sql = ' ORDER BY '
    orders.each do |order|
      sql += "#{order} DESC"
      sql += ', ' if order != orders.last
    end
    sql
  end

  # def signed_up_from_filter
  #   filters[:signed_up_between].try(:[], :from)
  # end

end
