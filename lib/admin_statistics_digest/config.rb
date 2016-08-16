module AdminStatisticsDigest
  module Config

    SEND_REPORT_INTERVAL = 30.days.freeze

    def self.mail_out_interval
      PluginStore.get(AdminStatisticsDigest.plugin_name, 'mail_out_interval') || SEND_REPORT_INTERVAL
    end

    def self.mail_out_interval=(interval)
      PluginStore.set(AdminStatisticsDigest.plugin_name, 'mail_out_interval', interval.to_i)
    end

    def self.last_report_sent_at=(time)
      PluginStore.set(AdminStatisticsDigest.plugin_name, 'last_report_sent_at', time)
    end

    def self.last_report_sent_at
      PluginStore.get(AdminStatisticsDigest.plugin_name, 'last_report_sent_at')
    end
  end
end
