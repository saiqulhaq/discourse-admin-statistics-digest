class AdminStatisticsDigest::ReportMailer < ActionMailer::Base

  include Rails.application.routes.url_helpers

  append_view_path Rails.root.join('plugins', 'discourse-admin-statistics-digest', 'app', 'views')
  default from: SiteSetting.notification_email

  def digest(first_date, last_date)

    logo_url = SiteSetting.logo_url
    logo_url = logo_url.include?('http') ? logo_url : Discourse.base_url + logo_url
    report_date = "#{first_date.to_s(:short)} - #{last_date.to_s(:short)} #{last_date.strftime('%Y')}"
    subject = "Discourse Admin Statistic Report #{report_date}"

    limit = 5
    @data = {
      top_new_registered_users: top_new_registered_users(first_date, limit),
      top_non_staff_users: top_non_staff_users(first_date, limit),
      demoted_regulars_this_month: demoted_regulars_this_month(first_date, last_date, limit),
      popular_posts: popular_posts(first_date, last_date, limit),
      popular_topics: popular_topics(first_date, last_date, limit),
      most_liked_posts: most_liked_posts(first_date, last_date, limit),
      most_replied_topics: most_replied_topics(first_date, last_date, limit),
      active_responders: active_responders(first_date, last_date, limit),

      title: subject,
      subject: subject,
      logo_url: logo_url,
      report_date: report_date
    }

    admin_emails = User.where(admin: true).map(&:email).select {|e| e.include?('@') }

    mail(to: admin_emails, subject: subject)
  end

  private
  def top_new_registered_users(signed_up_date, limit)
    report.active_users do |r|
      r.signed_up_since signed_up_date
      r.include_staff false
      r.limit limit
    end
  end

  def top_non_staff_users(signed_up_date, limit)
    report.active_users do |r|
      r.signed_up_before signed_up_date
      r.limit limit
      r.include_staff false
    end
  end

  def demoted_regulars_this_month(first_date, last_date, limit)
    last_month_fd = first_date - 1.month
    last_month_ld = last_date - 1.month
    two_months_ago_fd = first_date - 2.months
    two_months_ago_ld = last_date - 2.months

    active_2_months_ago = report.active_users do |r|
      r.signed_up_before last_month_fd
      r.active_range two_months_ago_fd..two_months_ago_ld
      r.include_staff false
      r.limit limit
    end

    active_1_months_ago = report.active_users do |r|
      r.signed_up_before last_month_fd
      r.active_range two_months_ago_ld..last_month_fd
      r.include_staff false
      r.limit limit
    end

    this_month = report.active_users do |r|
      r.signed_up_between from: last_month_fd, to: last_month_ld
      r.active_range last_month_fd..last_month_ld
      r.include_staff false
      r.limit limit
    end

    [
      active_2_months_ago.map {|s| { user_id: s['user_id'], username: s['username'], name: s['name'] }.with_indifferent_access },
      active_1_months_ago.map {|s| { user_id: s['user_id'], username: s['username'], name: s['name'] }.with_indifferent_access }
    ].flatten.uniq - this_month.map {|s| { user_id: s['user_id'], username: s['username'], name: s['name'] }.with_indifferent_access }
  end

  def popular_posts(first_date, last_date, limit)
    report.popular_posts do |r|
      r.limit limit
      r.popular_by_date first_date, last_date
    end
  end

  def popular_topics(first_date, last_date, limit)
    report.popular_topics do |r|
      r.limit limit
      r.popular_by_date first_date, last_date
    end
  end

  def most_liked_posts(first_date, last_date, limit)
    report.most_liked_posts do |r|
      r.limit limit
      r.active_range first_date..last_date
    end
  end

  def most_replied_topics(first_date, last_date, limit)
    report.most_replied_topics do |r|
      r.limit limit
      r.most_replied_by_date first_date, last_date
    end
  end

  def active_responders(first_date, last_date, limit)
    result = []
    AdminStatisticsDigest::ActiveResponder.monitored_topic_categories.each do |category_id|
      responders = report.active_responders do |r|
        r.limit limit
        r.topic_category_id category_id
        r.active_range first_date..last_date
      end

      result.push({
        category_name: Category.find(category_id).name,
        responders: responders
      }.with_indifferent_access)
    end
    result
  end

  def report
    @report ||= ::AdminStatisticsDigest::Report.new
  end

end
