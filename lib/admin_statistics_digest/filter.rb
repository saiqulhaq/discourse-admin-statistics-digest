require 'ostruct'

class Filter
  attr_accessor :filter

  def initialize
    @filter = OpenStruct.new
  end

  def empty?
    filter.to_h.empty?
  end

  # @param [Range] date_range, Range of Date
  def between(date_range)
    raise 'Invalid date range' if !date_range.is_a?(Range) || date_range.first > date_range.last
    filter[:date_range] = date_range
  end

  def date_range
    return nil if filter[:date_range].nil?
    OpenStruct.new(first: filter[:date_range].first.to_date, last: filter[:date_range].last.to_date).freeze
  end

  # @param [Integer] l
  def limit(l = nil)
    filter[:limit] = l if l
    filter[:limit]
  end

  def topic_category_id(id = nil)
    filter[:topic_category_id] = id if id
    filter[:topic_category_id]
  end

  # include Admin and Moderator user into query
  # @param [Boolean] val
  def include_staff(val = nil)
    filter[:include_staff] = val if val
    filter[:include_staff]
  end

  def signed_up_since(date = nil)
    filter[:signed_up_between] = { from: date.to_date, to: nil } if date
    filter[:signed_up_between]
  end

  def signed_up_before(date = nil)
    filter[:signed_up_before] = date.to_date if date
    filter[:signed_up_before]
  end

  def signed_up_between(from: nil, to: nil)
    filter[:signed_up_between] = { from: from.to_date, to: to.to_date} if from && to
    filter[:signed_up_between]
  end

  def popular_by_month(month = nil)
    filter[:popular_at] = month.beginning_of_month..month.end_of_month if month
    filter[:popular_at]
  end

  def method_missing(method_sym, *arguments, &block)
    if filter.respond_to?(method_sym)
      begin
        filter.send(method_sym, *arguments, &block)
      rescue ArgumentError
        filter.send(method_sym)
      end
    else
      raise NoMethodError, "#{method_sym.to_s} method is undefined"
    end
  end

end
