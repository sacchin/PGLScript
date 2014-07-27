#! ruby -Ku
require 'net/http'
require "uri"
require 'json'
require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "sacchin", :password => "su0u1r0", :database => "pokemon")
result = client.query("SELECT id, pokemon_no, time FROM ranking_pokemon_trend WHERE pokemon_no = #{pno} ORDER BY time desc")
result.each do |row|
p row
break
end

result = client.query("SELECT * FROM waza_info")
result.each do |row|
p row
end

result = client.query("SELECT * FROM tokusei_info")
result.each do |row|
p row
end

result = client.query("SELECT * FROM seikaku_info")
result.each do |row|
p row
end

result = client.query("SELECT * FROM item_info")
result.each do |row|
p row
end


end






 
