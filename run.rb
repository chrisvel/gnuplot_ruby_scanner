#! /bin/env ruby

require 'securerandom'
require 'open3'
require 'gnuplot'

class Scanner
  def initialize(network, passes, pool)
    @network = network
    @passes = passes
    @thread_pool = pool
    @victims = []
  end

  def scan_for_victims
    command = "/bin/sh nmap-stage-1.sh #{@network}"
    _output, status = Open3.capture2(command)
    raise StandardError unless status.success?
  rescue StandardError
    puts "Shit happened"
  end

  def create_list_of_hosts
    File.read('data/live_hosts')
      .split("\n")
      .select{|host| host.match(/^Host/)}
      .map{|host| host.match(/^Host: (\d+\.\d+\.\d+\.\d+).*/)[1]}
  end

  def scan_for_ports(ip_addr)
    command = "/bin/sh nmap-stage-2.sh #{ip_addr}"
    _output, status = Open3.capture2(command)
    raise StandardError unless status.success?
  rescue StandardError
    puts "Shit happened"
  end

  def process(thread_pool, victims)

    # puts "Creating Queue"
    work_queue = Queue.new

    # puts "Looping and adding Queue items"
    how_many_victims = victims.count
    iterations = [*0..how_many_victims]
    #loop do
    #  break unless iterations
      iterations.each do |iter|
        work_queue.push(
          iter: iter,
          uuid: SecureRandom.uuid,
          ip_addr: victims[iter],
          time: Time.now)
      end
    #end

    total_items = work_queue.length
    # puts "Total Victims/Queue items: #{total_items}"

    done = 0

    lock = Mutex.new
    workers = (0..thread_pool).map do
      Thread.new do
        begin
          while x = work_queue.pop(true)
            # Here goes the main job
            # print "Thread.new: #{x[:iter]} #{x[:ip_addr]}\n"
            scan_for_ports(x[:ip_addr])
            lock.synchronize do
              done += 1
            end
            # print "Started Thread #{done}/#{total_items} \n"
          end
        rescue ThreadError => e
        end
      end
    end
    workers.map(&:join)
  end

  def get_scan_data
    data = []
    for i in 2..@thread_pool do
      puts "Starting scanning with POOL #{i}"
      scan_for_victims
      victims = create_list_of_hosts
      a = Time.now
        process(i, victims)
      data << Time.now - a
    end
    data
  end

  def gen_plot
    data = []
    for i in 1..@passes do
      puts "[x] Starting pass #{i}"
      data[i] = get_scan_data
    end

    data_filtered = data.reject{|bb| bb.nil?}

    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.title  "Time/Threads in Pool"
        plot.xlabel "pool"
        plot.ylabel "time"

        x = [*2..@thread_pool]

        data_filtered.each_with_index do |dato, index|
          plot.data << Gnuplot::DataSet.new( [x, dato] ) do |ds|
            ds.with = "linespoints"
            ds.smooth = "csplines"
            ds.title = "Pass ##{index}"
          end
        end

        # puts data_filtered.inspect

        avg = data_filtered.transpose.map{|arr| arr.inject(:+) / arr.size}

        plot.data << Gnuplot::DataSet.new( [x,avg] ) do |ds|
          ds.with = "linespoints"
          ds.smooth = "csplines"
          ds.title = "Average"
        end
      end
    end
  end

end

sc = Scanner.new('192.168.144.0/24', 2, 8)
sc.gen_plot
