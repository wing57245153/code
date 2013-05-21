# encoding: UTF-8

require 'net/http'
Encoding.default_external = "UTF-8"

$server = nil
File.open("config.ini", "r") do |file|
	$server = file.gets
	$server = $server.strip
end

#name = ARGV[0]
print "输入用户名进行查询日志:"
name = gets
begin
	path = '/log/' + name.strip + '/debug_log.txt'
rescue Exception => e
	path = '/log/' + 'woko' + '/debug_log.txt'
end

Net::HTTP.version_1_2
Net::HTTP.start($server, 80) {|http|
    response = http.get(path)
    #puts response.body

    file = File.new("debug_log.txt", 'w')
    file.puts response.body
    file.close
}

File.open("debug_log.txt", "r") do |file|
	while line = file.gets
		puts line
	end
end