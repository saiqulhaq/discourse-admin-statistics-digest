module AdminStatisticsDigest
  module Config

    class Main
      DEFAULT_INTERVAL = 30.days.freeze
      KEY_NAME = self.class.to_s.freeze

      def mail_out_interval
        PluginStore.get(AdminStatisticsDigest.plugin_name, KEY_NAME) || DEFAULT_INTERVAL
      end

      def mail_out_interval=(interval)
        PluginStore.set(AdminStatisticsDigest.plugin_name, KEY_NAME, interval.to_i)
      end
    end

    class Specs
      attr_accessor :valid_values

      # @param [String] key
      # @param [Array] valid_values
      def initialize(key, valid_values)
        @key = key
        @data = Set.new
        @valid_values = valid_values
      end

      def add(spec)
        return false unless valid_values.include?(spec)
        return true if PluginStore.set(AdminStatisticsDigest.plugin_name, @key, @data.add(spec).to_a)
        @data.delete(spec)
        false
      end

      def remove(spec)
        return false unless valid_values.include?(spec)
        return true if PluginStore.set(AdminStatisticsDigest.plugin_name, @key, @data.delete(spec).to_a)
        @data.add(spec)
        false
      end

      def reset
        return false unless PluginStore.set(AdminStatisticsDigest.plugin_name, @key, [])
        @data = Set.new
        true
      end

      # @return [Array]
      def data
        PluginStore.get(AdminStatisticsDigest.plugin_name, @key) || @data.to_a
      end

    end
  end

end
