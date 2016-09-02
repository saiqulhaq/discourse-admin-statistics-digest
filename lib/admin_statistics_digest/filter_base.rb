require_relative '../admin_statistics_digest/dsl_methods'

class AdminStatisticsDigest::FilterBase
  include AdminStatisticsDigest::DslMethods
  attr_accessor :filters

  def initialize
    @filters = {}
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
      if Rails.env.test?
        puts to_sql
        raise ex
      end
      err = ex
    end

    {
      error: err,
      data: result.entries
    }
  end

  def to_sql
    raise 'Not implemented'
  end
  private :to_sql

  private
  def active_range
    return {
      first: filters[:active_range].first.to_date,
      last: filters[:active_range].last.to_date
    } if !filters[:active_range].nil? && filters[:active_range].is_a?(Range)
    nil
  end

end
