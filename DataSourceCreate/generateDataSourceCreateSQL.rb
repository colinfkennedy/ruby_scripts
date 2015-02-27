require 'erubis'

def load_adaptv_data_sources(filename)
    adaptv_names = Hash.new
    adaptv_names[:names] = Array.new
    File.open(filename, 'r') do |adaptv_names_file|
      adaptv_names_file.read.each_line do |line|
        line.strip!
        adaptv_names[:names].push line
      end
    end
    adaptv_names
end

adaptv_names = load_adaptv_data_sources('adaptv_data_source_names.txt')

puts "Building Data Source create SQL...."

template = File.read("createAdaptvDataSources.sql.erb")
template = Erubis::Eruby.new(template)
File.open('createAdaptvDataSources.sql', 'w') { |file| file.write(template.result(adaptv_names)) } 

puts "Done"