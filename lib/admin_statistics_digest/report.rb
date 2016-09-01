module AdminStatisticsDigest
end

class AdminStatisticsDigest::Report
  def self.generate(&block)
    self.new(&block)
  end

  def initialize(&block)
    self.rows = []

    instance_eval(&block) if block_given?
  end

  def active_user(&block)
    rows << run_query(AdminStatisticsDigest::ActiveUser.build(&block).to_sql)
  end

  def active_responder(&block)
    rows << run_query(AdminStatisticsDigest::ActiveResponder.build(&block).to_sql)
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
    result, err = [], nil
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
