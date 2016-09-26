# name: discourse-admin-statistics-digest
# about: Site summary report for admin
# version: 0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-admin-statistics-digest


enabled_site_setting :admin_statistics_digest

gem 'rufus-scheduler', '3.1.8'
gem 'sidekiq-scheduler', '2.0.9'

add_admin_route 'admin_statistics_digest.title', 'admin-statistics-digest'

after_initialize do

  load File.expand_path('../../discourse-admin-statistics-digest/lib/admin_statistics_digest.rb', __FILE__)

  module ::AdminStatisticsDigest
    class Engine < ::Rails::Engine
      engine_name ::AdminStatisticsDigest.plugin_name
      isolate_namespace AdminStatisticsDigest
    end
  end

  # libs
  load File.expand_path('../../discourse-admin-statistics-digest/lib/admin_statistics_digest/report.rb', __FILE__)

  # models
  load File.expand_path('../../discourse-admin-statistics-digest/app/models/active_responder_category.rb', __FILE__)

  # mailers
  load File.expand_path('../../discourse-admin-statistics-digest/app/mailers/report_mailer.rb', __FILE__)

  # controllers
  load File.expand_path('../../discourse-admin-statistics-digest/app/controllers/categories_controller.rb', __FILE__)
  load File.expand_path('../../discourse-admin-statistics-digest/app/controllers/report_scheduler_controller.rb', __FILE__)

  AdminStatisticsDigest::Engine.routes.draw do
    root to: 'categories#root'
    get 'categories', to: 'categories#index'
    put 'categories/(:id)/toggle', to: 'categories#toggle'
    get 'report-scheduler/preview', to: 'report_scheduler#preview'
  end

  Discourse::Application.routes.append do
    mount ::AdminStatisticsDigest::Engine, at: '/admin/plugins/admin-statistics-digest', constraints: AdminConstraint.new
  end

end
