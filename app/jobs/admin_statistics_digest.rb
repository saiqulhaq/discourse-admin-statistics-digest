require_relative '../mailers/report_mailer'

module Jobs
  class AdminStatisticsDigest < Base
    sidekiq_options 'retry' => true, 'queue' => 'critical'

    def execute(opts = nil)
      ::AdminStatisticsDigest::ReportMailer.digest(30.days.ago.to_date, Date.today).deliver_now
    end
  end
end
