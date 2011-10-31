require './common'
require 'rss/2.0'
require 'time'
require 'net/http'

def extract_ids(guid)
  source = guid =~ /careers.joelonsoftware.com/ ? 3 : 2
  id = /http:\/\/careers\.\w+\.com\/jobs\/(\d+)\//.match(guid).captures[0].to_i
  return [source, id]
end

def extract_title_parts(title)
  parts = []
  r1 = title.rindex(' at' )
  r2 = title.index(' (', r1)
  r3 = title.index(')', r2)
  parts[0] = title[0, r1]
  parts[1] = title[r1+4..r2]
  parts[2] = title[r2+2..r3-1].split(';')
  parts
end


response = Net::HTTP.get_response(URI.parse('http://careers.stackoverflow.com/jobs/feed'))
rss = RSS::Parser.parse(response.body, false)
rss.items.each do |job|
  data = {:created_at => job.date.to_i, :description => job.description, :url => job.link, }
  
  id_parts = extract_ids(job.guid.to_s)
  data[:source] = id_parts[0]
  data[:source_id] = id_parts[1]
  
  title_parts = extract_title_parts(job.title)
  data[:title] = title_parts[0]
  data[:company] = title_parts[1]
  data[:location] = title_parts[2]
  Store.insert(data)
end