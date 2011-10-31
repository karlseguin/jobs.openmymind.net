require_relative('common')
require 'json'
require 'time'
require 'net/http'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/slice'

source = 1

response = Net::HTTP.get_response(URI.parse('http://jobs.github.com/positions.json'))
jobs = JSON.parse(response.body)
jobs.each do |job|
  data = job.slice('company', 'location', 'created_at', 'company_url', 'title', 'url', 'id', 'description').symbolize_keys
  data[:created_at] = Time.parse(data.delete(:created_at)).to_i
  data[:source] = source
  data[:source_id] = data.delete(:id)
  Store.insert(data)
end