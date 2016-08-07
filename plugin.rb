# name: discourse-admin-statistics-digest
# about: Site summary report for admin
# version: 0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-admin-statistics-digest
require_relative '../discourse-admin-statistics-digest/lib/admin_statistics_digest'

after_initialize do

  module ::AdminStatisticsDigest
    class Engine < ::Rails::Engine
      engine_name 'admin_statistics_digest'
      isolate_namespace AdminStatisticsDigest
    end
  end

end
