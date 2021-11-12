require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

puts 'Event Manager Initialized!'

# contents = File.read('event_attendees.csv')
# puts contents

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end 

def clean_phonenumber(phone)
  if phone.length < 10 || phone.length > 11
    return nil 
  elsif phone.length == 11 && phone[0].to_i == 1
    phone.slice!(1)
  elsif phone.length == 10 
    return phone 
  else 
    return nil 
  end 
end 

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue 
   puts 'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

end 

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end

end 

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
hours = Hash.new
wdays = Hash.new  

contents.each do |row| 
  id = row[0]
  name = row[:first_name]
  phone = clean_phonenumber(row[:homephone])
  regdate = row[:regdate]
  time = Time.strptime(regdate, "%Y/%d/%m %k:%M")
  hour = time.hour
  date = Date.parse(time.to_s)
  day = date.wday
  if(!hours[hour].nil?)
    hours[hour] += 1
  else 
    hours[hour] = 1
  end 

  if wdays[day].nil?
    wdays[day] = 1
  else 
    wdays[day]+= 1
  end 

  #zipcode = clean_zipcode(row[:zipcode])
  #legislators = legislators_by_zipcode(zipcode)
  #form_letter = erb_template.result(binding)
 #save_thank_you_letter(id, form_letter)

end 

best_times_sorted = hours.sort_by{|time,count| count}
best_times = [best_times_sorted.last[0], best_times_sorted[-2][0] ]
best_day_sorted = wdays.sort_by{|day, count| count }.last[0]
best_day = Date::DAYNAMES[best_day_sorted]
p "best day is #{best_day} "