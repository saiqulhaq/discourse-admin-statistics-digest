require_relative '../admin_statistics_digest/filter'

class AdminStatisticsDigest::BaseReport

  def initialize
    @_filters = Filter.new
  end

  # used for DSL
  def filters(&block)
    @_filters.instance_eval(&block) if block_given?
    @_filters
  end

  def available_filters
    @available_filters ||= begin
      methods = @_filters.public_methods.sort - Object.new.public_methods
      methods.select {|m| self.respond_to? m.to_sym }
    end
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

  def self.provide_filter(filter)
    raise NoMethodError, "#{filter} filter is unavailable" unless Filter.public_method_defined?(filter)
    instance_eval do
      delegate filter, to: :_filters
    end
  end

  private
  attr_accessor :_filters
end
