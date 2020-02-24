#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'time'
require 'mail'

def time_difference(start_t, end_t)
    start_sec = start_t.hour * 3600 + start_t.min * 60 + start_t.sec
    end_sec = end_t.hour * 3600 + end_t.min * 60 + end_t.sec
    diff = end_sec - start_sec
    return Time.at(diff).gmtime.strftime('%H:%M:%S')
end

message = "<html><body><h1>Sunrise/sunset</h1>"

url = 'http://www.yr.no/place/Norway/Telemark/Sauherad/Gvarv/forecast.xml'
doc = Nokogiri::XML(open(url))
doc.css('sun').each do |entry|
    rise = Time.parse entry['rise']
    set = Time.parse entry['set']
    message << "<b>Opp:</b> #{rise}<br />"
    message << "<b>Ned:</b> #{set}<br />"
    message << "<b>Differanse:</b> #{time_difference(rise,set)}<br />"
    File.open('sun.txt', 'a') { |file| 
        file << rise
        file << "\t"
        file << set
        file << "\t"
        file << time_difference(rise, set)
        file << "\n"
    }
end

message << "</body></html>"

if !message.empty?
    mail = Mail.new do
    from     'eivind.lindbraaten@gmail.com'
    to       'eivind.lindbraaten@gmail.com'
    subject  'Sunrise / Sunset'
    #body      message
    html_part do
        content_type 'text/html; charset=UTF-8'
        body message
    end
    end

    mail.delivery_method :sendmail

    mail.deliver
end
