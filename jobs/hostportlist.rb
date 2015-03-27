require 'rubygems'
require 'net/ping'
require 'socket'
require 'timeout'
require 'process'
require 'fork'

fileline={}
buzzwords=[]
frequency=''
File.open('/home/ngadmin/sweet_dashboard_project/jobs/host.properties', 'r') do |properties_file|
properties_file.read.each_line do |line|
line.strip!
if (line[0] != ?# and line[0] != ?=)
        i=line.index("=")
        if (i)
                fileline[line[0..i - 1].strip] = line[i + 1..-1].strip
                hosts=fileline[line[0..i - 1 ].strip]
                if line.include? "host:port="
                 buzzwords=hosts.split(",")
                end
		if line.include? "frequency="
                 frequency=fileline[line[0..i - 1].strip]
                end
        else
                fileline[line] = ''
        end
        end
        end
end

buzzword_counts = Hash.new({ value: 0 })

SCHEDULER.every frequency do
  random_buzzword = buzzwords.sample
  host=random_buzzword.split(":").first
  ip=random_buzzword.split(":").last
  isavailable=''
  if Net::Ping::External.new(host).ping
        begin
          Timeout::timeout(1) do
            begin
              s=TCPSocket.new(host, ip)
              s.close()
              isavailable='Available'
            rescue Errno::ECONNREFUSED, Erron::EHOSTUNREACH
              isavailable='In use'
            end
            end
        rescue Timeout::Error
         isavailable='In use'
        end
  else
        isavailable='Host unavailable'
  end
  buzzword_counts[random_buzzword] = { label: random_buzzword, value: (isavailable) }

  send_event('hostportlist', { items: buzzword_counts.values })
end

