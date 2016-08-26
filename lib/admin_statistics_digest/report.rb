class AdminStatisticsDigest::Report
  def initialize(&block)
    @data = []
    instance_eval(&block) if block_given?
  end

  def active_user(&block)
    au = AdminStatisticsDigest::ActiveUser.new(&block)
    @data << au.to_sql
  end

  def active_responder(&block)
    ar = AdminStatisticsDigest::ActiveResponder.new(&block)
    @data << ar.to_sql
  end

  def section(&block)
    @data << AdminStatisticsDigest::Report.new(&block).data
  end

  def count
    @data.count
  end

  def data
    @data
  end
end
