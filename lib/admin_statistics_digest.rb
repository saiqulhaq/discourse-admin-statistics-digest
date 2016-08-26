module AdminStatisticsDigest
  autoload :Report, 'admin_statistics_digest/report'
  autoload :ActiveUser, 'admin_statistics_digest/active_user'
  autoload :ActiveResponder, 'admin_statistics_digest/active_responder'

  def self.generate(&block)
    report = AdminStatisticsDigest::Report.new
    report.instance_eval(&block) if block_given?
    report
  end
end
