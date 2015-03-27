require 'rubygems'
require 'net/ping'

fileline={}
#hostiplist=[]
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
                if line.include? "hosts="
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
#buzzwords = ['NGD11362', 'localhost', 'randomhost', 'NGLAP153']
#properties = JavaProperties.load("host.properties")
#host=properties[:hosts]
#buzzwords = [host]
buzzword_counts = Hash.new({ value: 0 })

SCHEDULER.every frequency do
  random_buzzword = buzzwords.sample
  if Net::Ping::External.new(random_buzzword).ping
	ispingable='Available'
  else
	ispingable='Not reachable'
  end
  buzzword_counts[random_buzzword] = { label: random_buzzword, value: (ispingable) }

  send_event('hostlist', { items: buzzword_counts.values })
end

