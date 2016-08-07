module AdminStatisticsDigest
  module Specs
    class Store
      attr_accessor :valid_values

      # @param [String] key
      # @param [Array] valid_values
      def initialize(key, valid_values)
        @key = key
        @data = Set.new
        @valid_values = valid_values
      end

      def add(spec)
        return data unless valid_values.include?(spec)
        PluginStore.set(AdminStatisticsDigest.plugin_name, @key, @data.add(spec).to_a)
      end

      def remove(spec)
        return data unless valid_values.include?(spec)
        PluginStore.set(AdminStatisticsDigest.plugin_name, @key, @data.delete(spec).to_a)
      end

      # @return [Array]
      def data
        PluginStore.get(AdminStatisticsDigest.plugin_name, @key) || @data.to_a
      end

    end
  end
end

