#! ruby -Ku
require 'net/http'
require "uri"
require 'json'
require 'mysql2'

PGLURL = "http://3ds.pokemon-gl.com/frontendApi/gbu/getSeasonPokemonDetail";

def showArray(hashObj)
hashObj.each{|key, value|
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
end

def showHash(hashObj)
hashObj.each{|key, value|
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
end

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
parsedJson = JSON.parse(response.entity) #=> {"foo"=>"bar"}
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

showHash(rankingPokemonTrend)
#File.write("hoge.txt", parsedJson)

client.query("INSERT INTO ranking_pokemon_trend (pokemon_no) VALUES ('#{pno}')")

sleepTime = Random.new.rand(1..30)
puts("取得完了したので、" + sleepTime.to_s + "秒待機します。次は、" + nextPokemonId)
sleep(sleepTime)

pno = nextPokemonId

end


client.query("SELECT id, pokemon_no, time FROM ranking_pokemon_trend").each do |id, pokemon_no, time|
  p id, pokemon_no, time
end









 
