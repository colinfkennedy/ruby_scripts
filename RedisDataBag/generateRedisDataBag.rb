require 'erubis'

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

puts "Redis Props"
puts
puts redis_props
puts
puts "Redis Shards Props"

redis_shards_props = load_properties('redis_shards.properties')
puts redis_shards_props

data = {
    shards: [
        {
            hostname: "colin_hostname",
            aliases: [
                {
                    name: "test_alias",
                    port: "test_port"
                }
            ]
        },
    {
            hostname: "colin_hostname_2",
            aliases: [
                {
                    name: "test_alias",
                    port: "test_port"
                },
{
                    name: "test_alias_2",
                    port: "test_port_2"
                }                
            ]
        }        
    ]
}

template = File.read("dataBag.json.erb")
template = Erubis::Eruby.new(template)
# puts template.result(data)