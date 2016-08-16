module AdminStatisticsDigest
  module Specs
    class ActiveResponder
      KEY = 'active_responder'.freeze # plugin store key name
      SPECS_PARAMETERS = %w(reply_to_post_number reads like_score).freeze

      def initialize
        @store = AdminStatisticsDigest::Specs::Config.new(KEY, SPECS_PARAMETERS)
      end

      def specs
        @store
      end

    end
  end
end

