require_relative '../lib/admin_statistics_digest/parse_to_cron_hash'
module AdminStatisticsDigest

  def self.plugin_name
    'admin-statistics-digest'
  end

  def self.reload_digest_report_schedule
    digest_schedule = AdminStatisticsDigest::EmailTimeout.get
    cron_parser = AdminStatisticsDigest::ParseToCronHash.parse(digest_schedule[:min],
                                                               digest_schedule[:hour],
                                                               digest_schedule[:day])

    if cron_parser.valid?
      Sidekiq.set_schedule('admin_statistics_digest', { cron: cron_parser.cron_hash,
                                                        queue: 'critical',
                                                        class: 'Jobs::AdminStatisticsDigest',
                                                        args: [{ current_site_id: 'default' }] })
      Sidekiq::Scheduler.reload_schedule!
    else
      raise StandardError, cron_parser.message
    end
  end
end
