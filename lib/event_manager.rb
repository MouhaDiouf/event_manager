require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'


puts 'Event Manager Initialized!'

# contents = File.read('event_attendees.csv')
# puts contents

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end 

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row| 
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  
  puts "#{name} #{zipcode}"
end 