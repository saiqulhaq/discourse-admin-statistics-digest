module AdminStatisticsDigest
  class Report

    # staff can be included using include_staff: true
    # @param [Hash] filters
    #   :limit
    #   :signed_up_from
    #   :include_staff, default false
    def new_active_users(filters = {})
      filters = { signed_up_from: 1.month.ago, include_staff: false }.merge(filters)
      validate_filter(filters[:signed_up_from], type: :past)
      report = active_users(filters)
      return report[:data].entries if report[:errors].nil? && !report[:data].nil?
      []
    end

    # @param [Hash] filters
    #   :limit
    #   :active_range see AdminStatisticsDigest::Specs::ActiveUser#to_sql,
    #      default value is starting from beginning date until last date of last month
    #   :include_staff, default true, set as false to get top_non_staff_users report
    def top_users(filters = {})
      filters = {
        active_range: 1.month.ago.beginning_of_month.to_date..1.month.ago.end_of_month.to_date,
        include_staff: true,
      }.merge(filters)

      validate_filter(filters[:active_range])

      report = active_users(filters)
      return report[:data].entries if report[:errors].nil? && !report[:data].nil?
      []
    end

    # Comparing User activity for each month, so :active_range minimal value is 2 months range date
    # @param [Hash] filters
    #   :limit
    #   :active_range see AdminStatisticsDigest::Specs::ActiveUser#to_sql,
    #      default value is starting from beginning date of 3 months ago until last date of last month
    #   :include_staff, default false
    def top_users_who_no_more_active(filters = {})
      filters = {
        include_staff: false,
        active_range: 3.months.ago.beginning_of_month.to_date..1.month.ago.end_of_month.to_date
      }.merge(filters)

      validate_filter(filters[:active_range], range_month_min: 2.months)

      top_users_based_on_month = filters[:active_range].group_by(&:year).map do |y|
        {
          year: y.first,
          months: y.last.group_by(&:month).map do |month|
            {
              month: month.first,
              # month_name: Date::MONTHNAMES[month.first],
              data: top_users(filters.merge(active_range: month.last))
            }
          end

        }
      end

      binding.pry

      # report = active_users(filters)
      # return report[:data].entries if report[:errors].nil? && !report[:data].nil?
      []
    end

    private
    # @param [Hash] filters the options to filter query and set active specs.
    #   @option filter [Date] :signed_up_from (optional)
    #   @option filter [Ranged of Date] :signed_up_between (optional)
    #   @option filter [Boolean] :include_staff default false
    # @return [Hash]
    #   error: Exception,
    #   data: PG::Result,
    #   duration: Time in nanoseconds
    def active_users(filters = {})
      specs = AdminStatisticsDigest::Specs::ActiveUser.new

      specs.add(specs.class::TOPICS)
      specs.add(specs.class::REPLIES)

      sql = specs.to_sql(filters)

      # copied from dicourse-data-explorer plugin for safety
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

    def validate_filter(filter, options = {})
      case filter
        when Range
          if options.has_key?(:range_month_min)
            unless filter.last - filter.first <= options[:range_month_min].value
              month = options[:range_month_min].to_i / 3600 / 60 / 10
              raise "Invalid range date, range date minimum is #{month} month#{'s' if month > 1}"
            end
          else
            raise 'Invalid range date' unless filter.first.month < filter.last.month
          end
        else
          if options.has_key?(:past) && options[:past]
            raise 'Filter date should be in the ' unless filter < Date.today
          end
      end
    end

  end
end

