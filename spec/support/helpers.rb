module Helpers

  def exec_sql(sql)
    ActiveRecord::Base.exec_sql(sql)
  end

  def freeze_time(now=Time.now)
    datetime = DateTime.parse(now.to_s)
    time = Time.parse(now.to_s)

    DateTime.stubs(:now).returns(datetime)
    Time.stubs(:now).returns(time)
  end
end
