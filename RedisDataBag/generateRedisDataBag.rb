require 'erubis'
require 'nokogiri'
require 'json'

def load_properties(properties_filename)
    properties = {}
    File.open(properties_filename, 'r') do |properties_file|
      properties_file.read.each_line do |line|
        line.strip!
        if (line[0] != ?# and line[0] != ?=)
          i = line.index('=')
          if (i)
            properties[line[0..i - 1].strip] = line[i + 1..-1].strip
          else
            properties[line] = ''
          end
        end
      end
    end
    properties
end

redis_props = load_properties('redis.properties')
redis_shards_props = load_properties('redis_shards.properties')
redis_shards_xml = Nokogiri::XML(File.open("redis-shards.xml"))

shards = Array.new

puts "Building shards...."

redis_props.each do |key, value|
    hostname_nodes = redis_shards_xml.css("bean constructor-arg[index='0'][value='${" + key + "}']")
    shard = Hash.new
    shard[:hostname] = value
    shard[:shards] = Array.new
    hostname_nodes.each do |hostname_node|
        alias_hash = Hash.new
        port_node = hostname_node.next_element
        alias_hash[:port] = port_node.attribute("value").to_s

        shard_name_node = port_node.next_element.next_element
        shard_name_key = shard_name_node.attribute("value").to_s[2...-1]
        alias_hash[:name] = redis_shards_props[shard_name_key]

        shard[:shards].push alias_hash
    end
    shards.push shard
end

puts "Finished building shards. Generating Data Bag"

shards_hash = {
    shards: shards
}

template = File.read("dataBag.json.erb")
template = Erubis::Eruby.new(template)
File.open('atp_segment_processor_general_config.json', 'w') { |file| file.write(template.result(shards_hash)) } 

puts "Done"