require 'rubygems'
require 'benchmark'
require 'gruff'

# Simple smoke test for the DRb server
# usage: 
#
# # start the DRb server
# script/ferret_server -e test start
#
# # run the script
# AAF_REMOTE=true script/runner -e test test/smoke/drb_smoke_test.rb

module DrbSmokeTest

  RECORDS_PER_PROCESS = 100000
  NUM_PROCESSES       = 10 # should be an even number
  NUM_DOCS = 50
  NUM_TERMS = 600
  START_TIME = Time.now

  class Words
    DICTIONARY = '/usr/share/dict/words'
    def initialize
      @words = []
      File.open(DICTIONARY) do |file|
        file.each_line do |word|
          @words << word.strip unless word =~ /'/
        end
      end
    end

    def to_s
      "#{@words.size} words"
    end

    def random_word
      @words[rand(@words.size)]
    end
  end

  puts "compiling sample documents..."
  WORDS = Words.new
  puts WORDS
  DOCUMENTS = []

  NUM_DOCS.times do
    doc = ''
    NUM_TERMS.times { doc << WORDS.random_word << ' ' }
    DOCUMENTS << doc
  end

  def self.random_document
    DOCUMENTS[rand(DOCUMENTS.size)]
  end

  puts "built #{NUM_DOCS} documents with an avg. size of #{DOCUMENTS.join.size / NUM_DOCS} Bytes."

  class Monitor
    class << self
      def count_connections
        res = Content.connection.execute("show status where variable_name = 'Threads_connected'")
        if res
          res.fetch_row.last
        else
          "error getting connection count"
        end
      end
      def writers_running?
        Dir['*.finished'].size < (NUM_PROCESSES/2)
      end
      def running?
        Dir['*.finished'].size < NUM_PROCESSES
      end
    end
  end

  class WorkerBase
    def initialize(id)
      @id = id
    end

    # time since startup in msec
    def get_time
      ((Time.now - START_TIME)*1000).to_i
    end

    def log(data)
      data << get_time
      @logfile << data.join(',') << "\n"
    end

    def log_finished
      File.open("#{@id}.finished", 'w') do |f|
        f << "finished at #{Time.now}\n"
      end
    end

    def clear_logs
      FileUtils.rm_f "#{@id}.*"
    end

    def run
      File.open("#{self.class.prefix}_#{@id}.log",'w') do |f|
        clear_logs
        sleep 1 # allow other processes to get ready
        @logfile = f
        do_run
        log_finished
        puts "#{@id} finished"
      end
    end

  end

  class Writer < WorkerBase
    def self.prefix; 'writer' end
    def do_run
      log_interval = RECORDS_PER_PROCESS / 100
      RECORDS_PER_PROCESS.times do |i|
        log create_record(i)
        if i % log_interval == 0
          # log progress
          puts "#{@id}: #{i} records indexed"
        end
      end
    end

    def create_record(i)
      time = Benchmark.realtime do
        Content.create! :title => "record #{@id} / #{i}", :description => DrbSmokeTest::random_document
      end
      [ time ]
    end
  end

  class Searcher < WorkerBase
    def self.prefix; 'searcher' end
    def do_run
      while Monitor::writers_running?
        # search with concurrent writes
        log do_search
      end
      t = Time.now
      while (Time.now - t) < 2.minutes
        # the writers have finished, now hammer the server with searches for another 5 minutes
        log do_search
      end
    end

    # run a search and log it's results.
    # Search is done with a query consisting of the term 'findme' 
    # (which is guaranteed to yield 20 results) and a random term from 
    # the word list, ORed together
    def do_search
      result = nil
      query = "findme OR #{WORDS.random_word}"
      time = Benchmark.realtime do
        result = Content.find_id_by_contents query
      end
      # time, no of hits
      [ time, result.first, query ]
    end
  end

  def self.run
    @start = Time.now

    NUM_PROCESSES.times do |i|
      unless fork
        @id = i
        break
      end
    end

    if @id
      @id.even? ? Writer.new(@id).run : Searcher.new(@id).run
    else

      # create some records to search for
      20.times do |i|
        Content.create! :title => "to find #{i}", :description => ("findme #{i} " << random_document)
      end

      while Monitor::running?
        puts "open connections: #{Monitor::count_connections}; time elapsed: #{Time.now - @start} seconds"
        sleep 10 
      end
      puts "doing the math now..."
      DrbSmokeTest::Stats.new(DrbSmokeTest::Writer::prefix).run
      DrbSmokeTest::Stats.new(DrbSmokeTest::Searcher::prefix).run
    end
  end

  module Statistics
    def odd?(value)
      value % 2 == 1
    end

    def median(population)
      if odd?(population.size)
        population[population.size/2]
      else
        mean [ population[population.size/2-1], population[population.size/2] ]
      end
    end

    def mean(population)
      sum = population.inject(0) { |sum, v| sum + v }
      sum / population.size.to_f
    end

    # variance and standard_deviation methods from 
    # http://warrenseen.com/blog/2006/03/13/how-to-calculate-standard-deviation/
    def variance(population)
      n = 0
      mean = 0.0
      s = 0.0
      population.each { |x|
        n = n + 1
        delta = x - mean
        mean = mean + (delta / n)
        s = s + delta * (x - mean)
      }
      # if you want to calculate std deviation
      # of a sample change this to "s / (n-1)"
      return s / n
    end

    # calculate the standard deviation of a population
    # accepts: an array, the population
    # returns: the standard deviation
    def standard_deviation(population)
      Math.sqrt(variance(population))
    rescue
      puts "pop: #{population.inspect}"
    end
  end

  class Stats
    include Statistics

    def initialize(prefix)
      @prefix = prefix
      @stats = []
    end

    def collect_stats
      Dir["#{@prefix}_*.log"].each do |logfile|
        puts logfile
        File.open(logfile) do |f|
          while line = f.gets
            row = line.split(',')
            row[row.size-1] = row.last.to_i
            @stats << row
          end
        end
      end
      puts "#{@stats.size} lines read, now sorting..."
      @stats.sort! { |row1, row2| row1.last <=> row2.last }
    end

    def with_segments(segment_count)
      t0 = @stats.first.last.to_i
      t1 = @stats.last.last.to_i
      timespan = t1 - t0
      puts "test run took: #{timespan/1000} seconds"
      # we want to draw 1000 points, determine which timespan one point covers
      segment_length = timespan / segment_count
      t = 0
      i = 0
      while t <= t1
        t += segment_length
        segment_stats = []
        while @stats.any? && @stats.first.last.to_i < t
          segment_stats << @stats.shift
        end
        yield segment_stats unless segment_stats.empty?
      end
    end

    def run
      collect_stats
      segments = []
      with_segments(500) do |segment_stats|
        segments << process_segment(segment_stats)
      end

      chart("#{@prefix} mean", "#{@prefix.downcase}_mean") do |g|
        g.data :mean, segments.map{ |row| row[0] }
        g.data :stddev, segments.map{ |row| row[1] }
      end
      chart("#{@prefix} median", "#{@prefix.downcase}_median") do |g|
        g.data :median, segments.map{ |row| row[2] }
      end
    end

    def process_segment(segment)
      times = segment.map{|row|row.first.to_i * 1000}
      [mean(times), standard_deviation(times), median(times), segment.size]
    end

    def chart(title, fname)
      g = Gruff::Line.new do |g|
        g.title = title
        g.theme = {
          :background_colors => ["#e6e6e6", "#e6e6e6"],
          :colors => ["#ff43a7", '#666666', 'black', 'white', 'grey'],
          :marker_color => "white"
        }
      end
      yield g
      g.write "#{fname}.png"
    end
  end

end


DrbSmokeTest::run

