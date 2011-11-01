require_relative('common')
require 'simple-rss'
require 'time'
require 'net/http'
require 'cgi'

def extract_ids(guid)
  source = 5
  id = /http:\/\/jobs.hasgeek.com\/view\/(\w+)/.match(guid).captures[0]
  return [source, id]
end


response = Net::HTTP.get_response(URI.parse('http://jobs.hasgeek.com/feed'))
rss = SimpleRSS.parse(response.body)
rss.items.each do |job|
  data = {:title => job[:title], :created_at => job[:published].to_i, :description => CGI.unescapeHTML(job[:content].force_encoding("UTF-8")), :url => job[:link]}
  id_parts = extract_ids(job[:id])
  data[:source] = id_parts[0]
  data[:source_id] = id_parts[1]
  Store.insert(data)
end