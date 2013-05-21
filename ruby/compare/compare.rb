# encoding: UTF-8
require 'digest/md5'
require 'FileUtils'

config = []
File.open("config.txt", "r") do |file|
	index = 1
	while line = file.gets
		config[index] = line
		index += 1
	end
end

Source = config[1].strip
Des = config[2].strip
Dif = "./dif"


def traverse_dir(file_path)
    if File.directory? file_path
    	Dir.foreach(file_path) do |file|
    	    if file != "." and file != ".."
    	    	traverse_dir(file_path + "/" + file) {|x| yield x}
    	    end	
    	end
    else
    	yield file_path
    end
end

def compare(sourcefile, desfile)
	sourceMd5 = Digest::MD5.hexdigest(File.read(sourcefile))

    begin
    	desfileMd5 = Digest::MD5.hexdigest(File.read(desfile))
    rescue Exception => e
    	copy(sourcefile)
    end

    #puts sourceMd5 != desfileMd5

	if sourceMd5.to_s != desfileMd5.to_s
		puts sourcefile
		copy(sourcefile)
	end	
end

def copy(sourcefile)
	key = sourcefile.sub(Source,"")
	filename = File.basename(key)
	dir = Dif + key.sub(filename, "")
	if !File.directory? dir
		FileUtils.mkdir_p  dir
	end
	
	FileUtils.copy(Source + key, dir)
end

begin
	FileUtils.rm_r(Dif)
rescue Exception => e
	
end


traverse_dir(Source) do |f|
	key = f.sub(Source,"")
	#puts key
	desfile = Des + key
	while  desfile.index("/")
		desfile = desfile.sub("/", "\\\\")
	end
	#puts desfile
	if f.index(".svn") == nil
	    compare(f, desfile)
    end
end

if __FILE__ == $0

end