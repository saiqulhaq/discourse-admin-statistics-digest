class AdminStatisticsDigest::ReportMailer < ActionMailer::Base

  include Rails.application.routes.url_helpers

  append_view_path Rails.root.join('plugins', 'discourse-admin-statistics-digest', 'app', 'views')
  default from: 'no-reply@test.lindsaar.net'

  def digest
    current_month = Date.today
    limit = 5

    @data = {
      top_new_registered_users: top_new_registered_users(current_month, limit),
      top_non_staff_users: top_non_staff_users(current_month, limit),
      demoted_regulars_this_month: demoted_regulars_this_month(current_month, limit),
      popular_posts: popular_posts(current_month, limit),
      popular_topics: popular_topics(current_month, limit)
      # most_liked_posts: most_liked_posts(current_month, limit),
      # most_replied_topics: popular_topics(current_month, limit)
    }

    @data[:report_date] = current_month.strftime('%b %Y')
    @data[:title] = @data[:subject] = "Discourse Admin Statistic Report #{@data[:report_date]}"

    mail(to: 'fake@email.com', subject: @data[:subject])
  end

  private
  def top_new_registered_users(month, limit)
    report.active_users do |r|
      r.signed_up_since month.beginning_of_month
      r.include_staff false
      r.limit limit
    end
  end

  def top_non_staff_users(month, limit)
    report.active_users do |r|
      r.signed_up_before month.beginning_of_month
      r.limit limit
      r.include_staff false
    end
  end

  def demoted_regulars_this_month(month, limit)
    last_month = month - 1.month
    two_months_ago = month - 2.months

    active_2_months_ago = report.active_users do |r|
      r.signed_up_before last_month.beginning_of_month
      r.active_range two_months_ago.beginning_of_month..two_months_ago.end_of_month
      r.include_staff false
      r.limit limit
    end

    active_1_months_ago = report.active_users do |r|
      r.signed_up_before month.beginning_of_month
      r.active_range last_month.beginning_of_month..last_month.end_of_month
      r.include_staff false
      r.limit limit
    end

    this_month = report.active_users do |r|
      r.signed_up_between from: month.beginning_of_month, to: month.end_of_month
      r.active_range month.beginning_of_month..month.end_of_month
      r.include_staff false
      r.limit limit
    end

    [
      active_2_months_ago.map {|s| { user_id: s['user_id'], username: s['username'], name: s['name'] }.with_indifferent_access },
      active_1_months_ago.map {|s| { user_id: s['user_id'], username: s['username'], name: s['name'] }.with_indifferent_access }
    ].flatten.uniq - this_month.map {|s| { user_id: s['user_id'], username: s['username'], name: s['name'] }.with_indifferent_access }
  end

  def popular_posts(month, limit)
    report.popular_posts do |r|
      r.limit limit
      r.popular_by_month month
    end
  end

  def popular_topics(month, limit)
    report.popular_topics do |r|
      r.limit limit
      r.popular_by_month month
    end
  end

  def most_liked_posts(month, limit)
    report.most_liked_posts do |r|
      r.limit limit
      r.active_range month.beginning_of_month..month.end_of_month
    end
  end

  def most_replied_topics(month, limit)
    report.most_replied_topic do |r|
      r.limit limit
      r.most_replied_by_month month
    end
  end

  def report
    @report ||= AdminStatisticsDigest::Report.new
  end

end
