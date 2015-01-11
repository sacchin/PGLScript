#! ruby -Ku
require 'net/http'
require "uri"
require 'json'
require 'mysql2'

#PGLのURL
PGLURL = "http://3ds.pokemon-gl.com/frontendApi/gbu/getSeasonPokemonDetail";

#各SQL文
INSERT_RANKING_POKEMON = "INSERT INTO ranking_pokemon_trend (pokemon_no) VALUES"
UPDATE_RANKING_POKEMON = "UPDATE ranking_pokemon_trend SET ranking = "
INSERT_WAZA_INFO = "INSERT INTO waza_info (ranking_pokemon_trend_id, ranking, type_id, sequence_number, usage_rate, name) VALUES"
INSERT_ITEM_INFO = "INSERT INTO item_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_TOKUSEI_INFO = "INSERT INTO tokusei_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_SEIKAKU_INFO = "INSERT INTO seikaku_info (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, name) VALUES"
INSERT_POKEMON_DOWN = "INSERT INTO ranking_pokemon_down (ranking_pokemon_trend_id, ranking, sequence_number, pokemon_no, count_battle_by_form, battling_change_flag) VALUES"
INSERT_POKEMON_DOWN_WAZA= "INSERT INTO ranking_pokemon_down_waza (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, waza_name) VALUES"
INSERT_POKEMON_SUFFERER = "INSERT INTO ranking_pokemon_sufferer (ranking_pokemon_trend_id, ranking, sequence_number, pokemon_no, count_battle_by_form, battling_change_flag) VALUES"
INSERT_POKEMON_SUFFERER_WAZA= "INSERT INTO ranking_pokemon_sufferer_waza (ranking_pokemon_trend_id, ranking, sequence_number, usage_rate, waza_name) VALUES"
INSERT_POKEMON_IN = "INSERT INTO ranking_pokemon_in (ranking_pokemon_trend_id, ranking, sequence_number, pokemon_no, count_battle_by_form, battling_change_flag) VALUES"

#ポケモン図鑑NoとシーズンIDから、1体のポケモンのデータを取得する
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

#ここからmain
client = Mysql2::Client.new(:host => "localhost", :username => "sacchin", :password => "su0u1r0", :database => "pokemon")
pno = '1-0'
seasonId = '6'
startTime = Time.now
buff = ""

num = 0
#すべてのポケモンのデータを取得
while pno != nil do
	puts(Time.now.to_s + ":" + pno + "のデータを取得します。")
	buff << (Time.now.to_s + ":" + pno + "のデータを取得します。¥n")

	parsedJson = postPGL(pno, seasonId)

	nextPokemonId = parsedJson['nextPokemonId']
	rankingPokemonTrend = parsedJson['rankingPokemonTrend']

	if (rankingPokemonTrend == nil || nextPokemonId == nil) then
		puts('error!!!')
		buff << 'error!!!¥n'

		pno = nil
		next
	elsif (pno == '719-0') then
		puts("#{pno} is last pokemon")
		buff << "#{pno} is last pokemon¥n"
		break
	end

	parent_id = 0
	client.query(INSERT_RANKING_POKEMON + "('#{pno}')")
	result = client.query("SELECT id, pokemon_no, time FROM ranking_pokemon_trend WHERE pokemon_no = #{pno} ORDER BY time desc")
	result.each do |row|
		parent_id = row['id']
		break
	end

	rankingPokemonInfo = parsedJson['rankingPokemonInfo']
	ranking = rankingPokemonInfo['ranking']
	client.query(UPDATE_RANKING_POKEMON + " #{ranking} WHERE id = #{parent_id}")

	waza_info = rankingPokemonTrend['wazaInfo']
	if (waza_info != nil && waza_info != '') then
		waza_info.each{|item| 
			client.query(INSERT_WAZA_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["typeId"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
		}
	else
		buff << "#{pno}'s waza_info is nil !!¥n"
	end

	item_info = rankingPokemonTrend['itemInfo']
	if (item_info != nil  && item_info != '')then
		item_info.each{|item| 
			client.query(INSERT_ITEM_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
		}
	else
		buff << "#{pno}'s item_info is nil !!¥n"
	end

	tokusei_info = rankingPokemonTrend['tokuseiInfo']
	if (tokusei_info != nil && tokusei_info != '') then
		tokusei_info.each{|item| 
			client.query(INSERT_TOKUSEI_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
		}
	else
		buff << "#{pno}'s tokusei_info is nil !!¥n"
	end

	seikaku_info = rankingPokemonTrend['seikakuInfo']
	if (seikaku_info != nil && seikaku_info != '') then
		seikaku_info.each{|item| 
			client.query(INSERT_SEIKAKU_INFO + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["name"]}')")
	}
	else
		buff << "#{pno}'s seikaku_info is nil !!¥n"
	end

	ranking_pokemon_down = parsedJson['rankingPokemonDown']
	if (ranking_pokemon_down != nil && ranking_pokemon_down != '') then
		ranking_pokemon_down.each{|item| 
			client.query(INSERT_POKEMON_DOWN + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["pokemonId"]}, '#{item["countBattleByForm"]}', '#{item["battlingChangeFlg"]}')")
		}
	else
		buff << "#{pno}'s ranking_pokemon_down is nil !!¥n"
	end

	ranking_pokemon_down_waza = parsedJson['rankingPokemonDownWaza']
	if (ranking_pokemon_down_waza != nil && ranking_pokemon_down_waza != '') then
		ranking_pokemon_down_waza.each{|item| 
			client.query(INSERT_POKEMON_DOWN_WAZA + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["wazaName"]}')")
		}
	else
		buff << "#{pno}'s ranking_pokemon_down_waza is nil !!¥n"
	end

	ranking_pokemon_sufferer = parsedJson['rankingPokemonSufferer']
	if (ranking_pokemon_sufferer != nil && ranking_pokemon_sufferer != '') then
		ranking_pokemon_sufferer.each{|item| 
			client.query(INSERT_POKEMON_SUFFERER + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["pokemonId"]}, '#{item["countBattleByForm"]}', '#{item["battlingChangeFlg"]}')")
		}
	else
		buff << "#{pno}'s ranking_pokemon_sufferer is nil !!"
	end

	ranking_pokemon_sufferer_waza = parsedJson['rankingPokemonSuffererWaza']
	if (ranking_pokemon_sufferer_waza != nil && ranking_pokemon_sufferer_waza != '') then
		ranking_pokemon_sufferer_waza.each{|item| 
			client.query(INSERT_POKEMON_SUFFERER_WAZA + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["usageRate"]}, '#{item["wazaName"]}')")
	}
	else
		buff << "#{pno}'s ranking_pokemon_sufferer_waza is nil !!"
	end

	ranking_pokemon_in = parsedJson['rankingPokemonIn']
	if (ranking_pokemon_in != nil && ranking_pokemon_in != '') then
		ranking_pokemon_in.each{|item| 
			client.query(INSERT_POKEMON_IN + " (#{parent_id}, #{item["ranking"]}, #{item["sequenceNumber"]}, #{item["pokemonId"]}, '#{item["countBattleByForm"]}', '#{item["battlingChangeFlg"]}')")
		}
	else
		buff << "#{pno}'s ranking_pokemon_in is nil !!"
	end

	sleepTime = Random.new.rand(1..30)
	puts("取得完了したので、" + sleepTime.to_s + "秒待機します。次は、" + nextPokemonId)
	sleep(sleepTime)
	pno = nextPokemonId
end

days = (Time.now - startTime).divmod(24*60*60)
hours = days[1].divmod(60*60)
mins = hours[1].divmod(60)

buff << "it's take #{days[0].to_i}days #{hours[0].to_i}hours #{mins[0].to_i}minutes #{mins[1]}seconds"
File.write("/home/ubuntu/log/" + Time.now.to_s + "_log.txt", buff)
