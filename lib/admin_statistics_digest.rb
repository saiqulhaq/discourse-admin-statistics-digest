module ::AdminStatisticsDigest

  def plugin_name
    'admin-statistics-digest'.freeze
  end
  module_function :plugin_name
end

Dir[File.dirname(__FILE__) + "/admin_statistics_digest/**/*.rb"].each { |file| require file }
