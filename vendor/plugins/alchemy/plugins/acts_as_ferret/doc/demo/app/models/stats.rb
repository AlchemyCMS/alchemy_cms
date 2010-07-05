class Stats < ActiveRecord::Base
  def self.compute(kind)
    start_date = minimum :created_at
    sql = <<-END
  select min(processing_time), max(processing_time), avg(processing_time), stddev(processing_time), 
         concat_ws(':', hour(timediff(created_at, ?)), lpad(minute(timediff(created_at, ?)), 2, '0')) as time,
         group_concat(processing_time) as data
      from stats 
      where kind=? group by time;
  END
    result = connection.execute sanitize_sql([sql, start_date, start_date, kind.to_s])
    returning [] do |res|
      while row = result.fetch_row
        data = row.last.split(',').map{|t|t.to_i}
        median = data.size.odd? ? data[data.size/2] : ((data[data.size/2-1]+data[data.size/2]) / 2.0)
        res << { :min => row[0].to_f, :max => row[1].to_f, :avg => row[2].to_f, :stddev => row[3].to_f, :time => row[4], :median => median }
      end
    end
  end
end
