#! ruby -Ku
require 'net/http'
require "uri"
require 'json'
require 'mysql2'

PGLURL = "http://3ds.pokemon-gl.com/frontendApi/gbu/getSeasonPokemonDetail";

INSERT_WAZA_INFO = "INSERT INTO waza_info (ranking_pokemon_trend_id, ranking, type_id, sequence_number, usage_rate, name) VALUES"
INSERT_ITEM_INFO = "INSERT INTO item_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_TOKUSEI_INFO = "INSERT INTO tokusei_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_SEIKAKU_INFO = "INSERT INTO seikaku_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_POKEMON_DOWN = "INSERT INTO ranking_pokemon_down (ranking_pokemon_trend_id, ranking, sequence_number, mons_no, count_battle_by_form, battling_change_flag) VALUES"
INSERT_POKEMON_DOWN_WAZA= "INSERT INTO ranking_pokemon_down_waza (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, waza_name) VALUES"
INSERT_POKEMON_SUFFERER = "INSERT INTO ranking_pokemon_sufferer (ranking_pokemon_trend_id, ranking, sequence_number, mons_no, count_battle_by_form, battling_change_flag) VALUES"
INSERT_POKEMON_SUFFERER_WAZA= "INSERT INTO ranking_pokemon_sufferer_waza (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, waza_name) VALUES"

def postPGL(pockemonNo, seasonId)
uri = URI.parse(PGLURL)
timestamp = Time.now.to_i

response = Net::HTTP.start(uri.host, uri.port){|http|
  request = Net::HTTP::Post.new(uri.path)
  request["referer"] = "http://3ds.pokemon-gl.com/battle/"
request.set_form_data({
'languageId'=>'1', 
'seasonId'=>seasonId,
'battleType'=>'0',
'timezone'=>'JST',
'pokemonId'=>pockemonNo,
'displayNumberWaza'=>'10',
'displayNumberTokusei'=>'3',
'displayNumberSeikaku'=>'10',
'displayNumberItem'=>'10',
'displayNumberLevel'=>'10',
'displayNumberPokemonIn'=>'10',
'timeStamp'=>timestamp
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
pno = '1-0'
seasonId = '6'

startTime = Time.now
num = 0
while pno != nil do
puts(Time.now.to_s + ":" + pno + "のデータを取得します。")
parsedJson = postPGL(pno, seasonId)

nextPokemonId = parsedJson['nextPokemonId']
rankingPokemonTrend = parsedJson['rankingPokemonTrend']


if (rankingPokemonTrend == nil || nextPokemonId == nil) then
puts('error!!!')
pno = nil
next
elsif (pno == '719-0') then
puts("#{pno} is last pokemon")
break
end

parent_id = 0
client.query("INSERT INTO ranking_pokemon_trend (pokemon_no) VALUES ('#{pno}')")
result = client.query("SELECT id, pokemon_no, time FROM ranking_pokemon_trend WHERE pokemon_no = #{pno} ORDER BY time desc")
result.each do |row|
parent_id = row['id']
break
end


waza_info = rankingPokemonTrend['wazaInfo']
if waza_info != nil then
waza_info.each{|item| 
client.query(INSERT_WAZA_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["typeId"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
}
else
puts("#{pno}'s waza_info is nil !!")
end

item_info = rankingPokemonTrend['itemInfo']
if item_info != nil then
item_info.each{|item| 
client.query(INSERT_ITEM_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
}
else
puts("#{pno}'s item_info is nil !!")
end

tokusei_info = rankingPokemonTrend['tokuseiInfo']
if tokusei_info != nil then
tokusei_info.each{|item| 
client.query(INSERT_TOKUSEI_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
}
else
puts("#{pno}'s tokusei_info is nil !!")
end

seikaku_info = rankingPokemonTrend['seikakuInfo']
if seikaku_info != nil then
seikaku_info.each{|item| 
client.query(INSERT_SEIKAKU_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
}
else
puts("#{pno}'s seikaku_info is nil !!")
end

ranking_pokemon_down = rankingPokemonTrend['rankingPokemonDown']
if ranking_pokemon_down != nil then
ranking_pokemon_down.each{|item| 
client.query(INSERT_POKEMON_DOWN + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["monsno"]}, '#{item["countBattleByForm"]}', '#{item["battlingChangeFlg"]}')")
}
puts("#{pno}'s ranking_pokemon_down is nil !!")
end

ranking_pokemon_down_waza = rankingPokemonTrend['rankingPokemonDownWaza']
if ranking_pokemon_down_waza != nil then
ranking_pokemon_down_waza.each{|item| 
client.query(INSERT_POKEMON_DOWN_WAZA + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["wazaName"]}')")
}
puts("#{pno}'s ranking_pokemon_down is nil !!")
end

ranking_pokemon_sufferer = rankingPokemonTrend['rankingPokemonSufferer']
if ranking_pokemon_sufferer != nil then
ranking_pokemon_sufferer.each{|item| 
client.query(INSERT_POKEMON_SUFFERER + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["monsno"]}, '#{item["countBattleByForm"]}', '#{item["battlingChangeFlg"]}')")
}
puts("#{pno}'s ranking_pokemon_sufferer is nil !!")
end

ranking_pokemon_sufferer_waza = rankingPokemonTrend['rankingPokemonSuffererWaza']
if ranking_pokemon_sufferer_waza != nil then
ranking_pokemon_sufferer_waza.each{|item| 
client.query(INSERT_POKEMON_SUFFERER_WAZA + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["wazaName"]}')")
}
puts("#{pno}'s ranking_pokemon_down is nil !!")
end

sleepTime = Random.new.rand(1..30)
puts("取得完了したので、" + sleepTime.to_s + "秒待機します。次は、" + nextPokemonId)
sleep(sleepTime)

pno = nextPokemonId

end

days = (Time.now - startTime).divmod(24*60*60)
hours = days[1].divmod(60*60)
mins = hours[1].divmod(60)

puts "it's take #{days[0].to_i}days #{hours[0].to_i}hours #{mins[0].to_i}minutes #{mins[1]}seconds"








 
