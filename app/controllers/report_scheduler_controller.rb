class AdminStatisticsDigest::ReportSchedulerController < ApplicationController
  requires_plugin AdminStatisticsDigest.plugin_name

  def preview
    AdminStatisticsDigest::ReportMailer.digest(30.days.ago.to_date, Date.today).deliver_now
    render json: { success: true }
  end

  def set_time_out
    render json: { hello: false }
  end
end
