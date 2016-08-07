module AdminStatisticsDigest
  class Report

    # @param [Hash] filters the options to filter query and set active specs.
    #   @option filter [Date or Time] :signed_up_from (optional)
    #   @option filter [Ranged of Date or Time] :signed_up_between (optional)
    #   @option filter [Boolean] :include_staff default false
    # @return [Hash]
    #   error: Exception,
    #   data: PG::Result,
    #   duration: Time in nanoseconds
    def active_users(filters = {})
      specs = AdminStatisticsDigest::Specs::ActiveUser.new

      sql = specs.to_sql(filters)

      # copied from dicourse-data-explorer plugin
      time_start, time_end, err, result = nil
      begin
        ActiveRecord::Base.connection.transaction do
          ActiveRecord::Base.exec_sql 'SET TRANSACTION READ ONLY'
          ActiveRecord::Base.exec_sql 'SET LOCAL statement_timeout = 10000'
          time_start = Time.now
          result = ActiveRecord::Base.exec_sql(sql)
          result.check
          time_end = Time.now

          raise ActiveRecord::Rollback
        end
      rescue Exception => ex
        err = ex
        time_end = Time.now
      end

      {
        error: err,
        data: result,
        duration: time_end - time_start
      }
    end
  end
end

