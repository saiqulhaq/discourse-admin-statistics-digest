# frozen_string_literal: true

require_relative '../mailers/report_mailer'

module Jobs
  class AdminStatisticsDigest < Base
    sidekiq_options 'retry' => true, 'queue' => 'critical'

    def execute(_opts = {})
      return unless sending_email?
      ::AdminStatisticsDigest::ReportMailer.digest(30.days.ago.to_date, Time.zone.today).deliver_now
    end

    def sending_email?
      !SiteSetting.disable_emails
    end
  end
end
