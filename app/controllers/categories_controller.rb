require_dependency 'application_controller'
require 'sidekiq/scheduler'

class AdminStatisticsDigest::CategoriesController < ApplicationController
  requires_plugin AdminStatisticsDigest.plugin_name

  def index
    render json: AdminStatisticsDigest::ActiveResponderCategory.all.to_json
  end

  def update
    if AdminStatisticsDigest::ActiveResponderCategory.update_categories(params.require(:categories))
      render json: AdminStatisticsDigest::ActiveResponderCategory.all.to_json
    else
      render json: {}, status: 422
    end
  end

  def root
    render json: {}
  end
end
