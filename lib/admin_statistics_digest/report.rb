module AdminStatisticsDigest
end

require_relative './active_responder'
require_relative './active_user'
require_relative './most_replied_topic'
require_relative './most_liked_post'
require_relative './popular_post'
require_relative './popular_topic'

class AdminStatisticsDigest::Report

  REPORTS = {
    active_user: AdminStatisticsDigest::ActiveUser,
    active_responder: AdminStatisticsDigest::ActiveResponder,
    most_liked_post: AdminStatisticsDigest::MostLikedPost,
    most_replied_topic: AdminStatisticsDigest::MostRepliedTopic,
    popular_post: AdminStatisticsDigest::PopularPost,
    popular_topic: AdminStatisticsDigest::PopularTopic,
  }.freeze

  def self.generate(&block)
    self.new(&block)
  end

  def initialize(&block)
    self.rows = []

    instance_eval(&block) if block_given?
  end

  REPORTS.each do |method_name, klass_name|

    define_method(method_name.to_sym) do |&block|
      report = klass_name.new
      report.instance_eval(&block)
      self.rows << report.execute
    end

  end

  def section(name, &block)
    rows << {
      name: name,
      data: AdminStatisticsDigest::Report.new(&block).data
    }
  end

  def size
    rows.size
  end

  def data
    rows.freeze
  end

  private
  attr_accessor :rows

end
