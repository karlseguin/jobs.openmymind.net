require_relative('common')
require 'rss/2.0'
require 'time'
require 'net/http'
require 'securerandom'

def extract_ids(guid)
  return nil if guid =~ /careers.stackoverflow.com/
  id = /http:\/\/careers\.joelonsoftware\.com\/jobs\/(\d+)\//.match(guid).captures[0].to_i
  return [2, id]
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
body = response.body
File.write(Time.now.utc.strftime('%Y%m%d_%H%M%S_' + SecureRandom.uuid + '.so'), body)
rss = RSS::Parser.parse(body, false)
rss.items.each do |job|
  id_parts = extract_ids(job.guid.to_s)
  next unless id_parts

  data = {:created_at => job.date.utc.to_i, :description => job.description, :url => job.link, }

  data[:source] = id_parts[0]
  data[:source_id] = id_parts[1]

  title_parts = extract_title_parts(job.title)
  data[:title] = title_parts[0]
  data[:company] = title_parts[1]
  data[:location] = title_parts[2]
  Store.insert(data)
end