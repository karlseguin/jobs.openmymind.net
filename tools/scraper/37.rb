require_relative('common')
require 'rss/2.0'
require 'time'
require 'net/http'

def extract_ids(guid)
  source = 6
  id = /http:\/\/jobs.37signals.com\/jobs\/(\d+)/.match(guid).captures[0].to_i
  return [source, id]
end

def extract_description_parts(description)
  location = /<strong>Location:<\/strong> (.*)/.match(description).captures[0]
  [description, location]
end


response = Net::HTTP.get_response(URI.parse('http://jobs.37signals.com/categories/2/jobs.rss'))
rss = RSS::Parser.parse(response.body, false)
rss.items.each do |job|
  data = {:title => job.title, :created_at => job.date.to_i, :url => job.link}
  
  id_parts = extract_ids(job.guid.to_s)
  data[:source] = id_parts[0]
  data[:source_id] = id_parts[1]
  
  description_parts = extract_description_parts(job.description)
  data[:description] = description_parts[0]
  data[:location] = description_parts[1]
  Store.insert(data)
end