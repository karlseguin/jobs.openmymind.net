require_relative('common')
require 'json'
require 'time'
require 'net/http'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/slice'

source = 1

uri = URI.parse('https://jobs.github.com/positions.json')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
jobs = JSON.parse(response.body)
jobs.each do |job|
  data = job.slice('company', 'location', 'created_at', 'company_url', 'title', 'url', 'id', 'description').symbolize_keys
  data[:created_at] = Time.parse(data.delete(:created_at)).utc.to_i
  data[:source] = source
  data[:source_id] = data.delete(:id)
  Store.insert(data)
end