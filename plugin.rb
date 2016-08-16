# name: discourse-admin-statistics-digest
# about: Site summary report for admin
# version: 0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-admin-statistics-digest

require_relative '../discourse-admin-statistics-digest/lib/admin_statistics_digest'
require_relative './app/mailers/statistics_mailer'

after_initialize do

  module ::AdminStatisticsDigest
    module Jobs

      # A daily job that will enqueue digest emails to be sent to users
      class EnqueueDigestReport < ::Jobs::Scheduled
        every AdminStatisticsDigest::Config.mail_out_interval

        def execute
          message = AdminStatisticsDigest::Mailer::StatisticsMailer.send_digest_report(
            between: (Date.today - AdminStatisticsDigest::Config.mail_out_interval)...Date.today
          )
          Email::Sender.new(message, :admin_statistics_digest).send
          AdminStatisticsDigest::Config.last_report_sent_at = Time.zone.now
        end

      end

    end
  end

end
