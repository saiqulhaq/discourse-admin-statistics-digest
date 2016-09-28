class AdminStatisticsDigest::ReportSchedulerController < ApplicationController
  requires_plugin AdminStatisticsDigest.plugin_name

  def preview
    AdminStatisticsDigest::ReportMailer.digest(30.days.ago.to_date, Date.today).deliver_now
    render json: { success: true }
  end

  def get_timeout
    render json: AdminStatisticsDigest::EmailTimeout.get
  end

  def set_timeout
    succeed = AdminStatisticsDigest::EmailTimeout.set(params.require(:day).to_i, params.require(:hour).to_i, params.require(:min).to_i)
    render json: { success: succeed }
  end
end
