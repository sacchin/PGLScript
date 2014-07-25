#! ruby -Ku
require 'net/http'
require "uri"
require 'json'
require 'mysql2'

PGLURL = "http://3ds.pokemon-gl.com/frontendApi/gbu/getSeasonPokemonDetail";


INSERT_WAZA_INFO = "INSERT INTO waza_info (ranking_pokemon_trend_id, ranking, type_id, sequence_number, usage_rate, name) VALUES"
INSERT_ITEM_INFO = "INSERT INTO item_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_TOKUSEI_INFO = "INSERT INTO tokusei_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_SEIAKU_INFO = "INSERT INTO seikaku_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"

#File.write("hoge.txt", parsedJson)



def postPGL(pockemonNo)
uri = URI.parse(PGLURL)

response = Net::HTTP.start(uri.host, uri.port){|http|
  request = Net::HTTP::Post.new(uri.path)
  request["referer"] = "http://3ds.pokemon-gl.com/battle/"
request.set_form_data({
'languageId'=>'1', 
'seasonId'=>'4',
'battleType'=>'0',
'timezone'=>'JST',
'pokemonId'=>pockemonNo,
'displayNumberWaza'=>'10',
'displayNumberTokusei'=>'3',
'displayNumberSeikaku'=>'10',
'displayNumberItem'=>'10',
'displayNumberLevel'=>'10',
'displayNumberPokemonIn'=>'10',
'timeStamp'=>'1405469738'
}, '&')
  response = http.request(request)
}
case response
when Net::HTTPSuccess, Net::HTTPRedirection
parsedJson = JSON.parse(response.entity)
else
  response.value
end
end

client = Mysql2::Client.new(:host => "localhost", :username => "sacchin", :password => "su0u1r0", :database => "pokemon")
pno = '303-0'
for i in [1, 2, 3]
puts(pno + "のデータを取得します。")
parsedJson = postPGL(pno)

nextPokemonId = parsedJson['nextPokemonId']
rankingPokemonTrend = parsedJson['rankingPokemonTrend']



client.query("INSERT INTO ranking_pokemon_trend (pokemon_no) VALUES ('#{pno}')")
result = client.query("SELECT id, pokemon_no, time FROM ranking_pokemon_trend WHERE pokemon_no = #{pno} ORDER BY time desc")
result.each do |row|
parent_id = row['id']
break
end


waza_info = rankingPokemonTrend['waza_info']
waza_info.each{|item| 
client.query(INSERT_WAZA_INFO + " ('#{parent_id}, #{item["ranking"]}, #{item["typeId"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, #{item["name"]}')")
}

item_info = rankingPokemonTrend['item_info']
item_info.each{|item| 
client.query(INSERT_ITEM_INFO + " ('#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, #{item["name"]}')")
}

tokusei_info = rankingPokemonTrend['tokusei_info']
tokusei_info.each{|item| 
client.query(INSERT_TOKUSEI_INFO + " ('#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, #{item["name"]}')")
}

seikaku_info = rankingPokemonTrend['seikaku_info']
seikaku_info.each{|item| 
client.query(INSERT_SEIKAKU_INFO + " ('#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, #{item["name"]}')")
}



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



rankingPokemonTrend.each{|key, value|
  if(value.kind_of?(Hash)) then
	showHash(value)
  elsif (value.kind_of?(Array)) then
  puts("array - ", value)
	value.each{|item| puts("item - ", item)}
  else 
puts  value.class.name
	puts(key + " - ", value)
  end
}



sleepTime = Random.new.rand(1..30)
puts("取得完了したので、" + sleepTime.to_s + "秒待機します。次は、" + nextPokemonId)
sleep(sleepTime)

pno = nextPokemonId

end






 
