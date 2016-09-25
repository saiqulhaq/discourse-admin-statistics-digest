# name: discourse-admin-statistics-digest
# about: Site summary report for admin
# version: 0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-admin-statistics-digest

require_relative '../discourse-admin-statistics-digest/lib/admin_statistics_digest'
require_relative '../discourse-admin-statistics-digest/app/mailers/report_mailer'

enabled_site_setting :admin_statistics_digest

gem 'rufus-scheduler', '3.1.8'
gem 'sidekiq-scheduler', '2.0.9'

add_admin_route 'admin_statistics_digest.title', 'admin-statistics-digest'

after_initialize do

  module ::AdminStatisticsDigest
    class Engine < ::Rails::Engine
      engine_name ::AdminStatisticsDigest.plugin_name
      isolate_namespace AdminStatisticsDigest
    end
  end

  load File.expand_path('../../discourse-admin-statistics-digest/app/models/active_responder_category.rb', __FILE__)

  require_dependency 'application_controller'
  require 'sidekiq/scheduler'

  class AdminStatisticsDigest::CategoriesController < ApplicationController
    requires_plugin AdminStatisticsDigest.plugin_name

    def index
      render json: AdminStatisticsDigest::ActiveResponderCategory.all.to_json
    end

    def toggle
      if AdminStatisticsDigest::ActiveResponderCategory.toggle_selection(params.require(:id).to_i)
        render json: AdminStatisticsDigest::ActiveResponderCategory.all.to_json
      else
        render json: {}, status: 422
      end
    end
  end

  # call Sidekiq::Scheduler.reload_schedule! after updating the schedule
  class AdminStatisticsDigest::ReportSchedulerController < ApplicationController
    requires_plugin AdminStatisticsDigest.plugin_name

    def set_time_out
      render json: { hello: false }
    end
  end

  AdminStatisticsDigest::Engine.routes.draw do
    get 'categories', to: 'categories#index'
    put 'categories/(:id)/toggle', to: 'categories#toggle'
  end

  Discourse::Application.routes.append do
    mount ::AdminStatisticsDigest::Engine, at: '/admin/plugins/admin-statistics-digest'#, constraints: AdminConstraint.new
  end

end
