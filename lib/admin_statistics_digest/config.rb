module AdminStatisticsDigest
  module Config

    SEND_REPORT_INTERVAL = 30.days.freeze
    DS_KEY_NAME = self.class.to_s.freeze

    def self.mail_out_interval
      PluginStore.get(AdminStatisticsDigest.plugin_name, DS_KEY_NAME) || SEND_REPORT_INTERVAL
    end

    def self.mail_out_interval=(interval)
      PluginStore.set(AdminStatisticsDigest.plugin_name, DS_KEY_NAME, interval.to_i)
    end

  end
end
