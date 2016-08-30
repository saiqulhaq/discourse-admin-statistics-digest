module AdminStatisticsDigest
end

class AdminStatisticsDigest::Report
  def self.generate(&block)
    self.new(&block)
  end

  def initialize(&block)
    self.rows = []

    if block_given?
      instance_eval(&block)
    end
  end

  def active_user(*options, &block)
    au = AdminStatisticsDigest::ActiveUser.new(*options, &block)
    rows << run_query(au.to_sql)
  end

  def active_responder(*options, &block)
    ar = AdminStatisticsDigest::ActiveResponder.new(*options, &block)
    rows << run_query(ar.to_sql)
  end

  def section(name, &block)
    rows << {
      name: name,
      data: AdminStatisticsDigest::Report.new(&block).data
    }
  end

  def size
    rows.size
  end

  def data
    rows.freeze
  end

  private
  attr_accessor :rows

  def run_query(sql)
    result = []
    begin
      ActiveRecord::Base.connection.transaction do
        ActiveRecord::Base.exec_sql 'SET TRANSACTION READ ONLY'
        ActiveRecord::Base.exec_sql 'SET LOCAL statement_timeout = 10000'
        result = ActiveRecord::Base.exec_sql(sql)
        result.check

        raise ActiveRecord::Rollback
      end
    rescue Exception => ex
      err = ex
    end

    {
      error: err,
      data: result.entries,
    }
  end

end
