require 'yaml'
require 'erb'
require 'net/http'
require 'uri'
require 'json'
require 'date'

@meetups = YAML.load_file('meetups.yml')
@template = ERB.new(File.read('template.erb'))
@calendar = []


task :default do
    
    @meetups.each do |meetup|
        uri = URI.parse("https://api.meetup.com/" + meetup + "/events")
        response = Net::HTTP.get_response(uri) 
        if response.code == "200"
            events = JSON.parse(response.body)
            events.each do |event|  
                str_date = event["local_date"] + 'T' + event["local_time"] + ':00-03:00'
                start_date = DateTime.parse(str_date)
                end_date = start_date.to_time + (event["duration"] / 1000)
                @calendar << {
                    id: event["id"] ,
                    calendarId: meetup,
                    title: event["name"],
                    category: 'time',
                    start: str_date.to_s,
                    end: end_date.to_datetime.to_s,
                    location: event["venue"]["address_1"] + " " + event["venue"]["city"]
                }

            end
            
        end
    end


    File.write('output/index.html', @template.result())
end