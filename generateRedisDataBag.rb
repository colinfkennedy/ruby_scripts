require 'erb'
require 'ostruct'

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

data = OpenStruct.new(
    shards: [
        {
            hostname: "colin_hostname",
            aliases: [
                {
                    alias_name: "test_alias",
                    port: "test_port"
                }
            ]
        },
    {
            hostname: "colin_hostname_2",
            aliases: [
                {
                    alias_name: "test_alias",
                    port: "test_port"
                },
{
                    alias_name: "test_alias_2",
                    port: "test_port_2"
                }                
            ]
        }        
    ]
)

template = ERB.new File.new("dataBag.json.erb").read, nil, "%"
puts template.result(data.instance_eval { binding })