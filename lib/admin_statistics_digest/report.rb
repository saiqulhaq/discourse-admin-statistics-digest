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
    active_users: AdminStatisticsDigest::ActiveUser,
    active_responders: AdminStatisticsDigest::ActiveResponder,
    most_liked_posts: AdminStatisticsDigest::MostLikedPost,
    most_replied_topics: AdminStatisticsDigest::MostRepliedTopic,
    popular_posts: AdminStatisticsDigest::PopularPost,
    popular_topics: AdminStatisticsDigest::PopularTopic,
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
      result = report.execute
      if result[:error]
        raise result[:error]
      else
        self.send(:rows).push(result[:data])
        result[:data]
      end
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
    return rows.flatten.freeze if rows.length == 1
    rows.freeze
  end

  private
  attr_accessor :rows

end
