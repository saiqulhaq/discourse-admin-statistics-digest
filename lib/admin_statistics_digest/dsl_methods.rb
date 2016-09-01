require 'active_support/concern'

module AdminStatisticsDigest::DslMethods
  extend ActiveSupport::Concern

  included do
    def self.build(&block)
      new.tap {|s| s.__yield_dsl(&block) }
    end
  end

  def rebuild(&block)
    self.tap {|s| s.__yield_dsl(&block) }
  end

  def __yield_dsl(&block)
    delegator_class_name = (self.class.to_s + 'Delegator').constantize
    delegator = delegator_class_name.new(self)
    delegator.instance_eval(&block)
  end

end
