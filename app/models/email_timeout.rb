require_dependency 'plugin_store'

class AdminStatisticsDigest::EmailTimeout
  PS_KEY_NAME = 'email_timeout'.freeze
  DEFAULT_TIMEOUT = { day: 30, hour: 0, min: 0 }.freeze

  class << self

    def get
      timeout = PluginStore.get(AdminStatisticsDigest.plugin_name, PS_KEY_NAME)
      return timeout if timeout

      PluginStore.set(AdminStatisticsDigest.plugin_name, PS_KEY_NAME, DEFAULT_TIMEOUT).tap do |is_true|
        is_true ? DEFAULT_TIMEOUT : ''
      end
    end

    def set(day, hour, min)
      PluginStore.set(AdminStatisticsDigest.plugin_name, PS_KEY_NAME, {
        day: day, hour: hour, min: min
      }).tap {|is_true| AdminStatisticsDigest.reload_digest_report_schedule if is_true }
    end
  end

end
