package com.gmail.sacchin13.spring_boot_sample.entity;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

import org.json.JSONObject;

@Entity
public class RankingPokemonTrend {
	@Id
	@GeneratedValue
	protected Integer id;
	protected Date time;
	protected String pokemon_no;
	protected Integer ranking;
	
	public RankingPokemonTrend() {
		super();
	}

	public RankingPokemonTrend(int id, Date time, String pokemon_no, int ranking) {
		System.out.println("" + id + " , " + time + ", " + pokemon_no + ", " + ranking);
		this.id = id;
		if(time != null){
			this.time  = time;
		}else{
			this.time = new Date();
		}
		this.pokemon_no = pokemon_no;
		this.ranking = ranking;
	}

	public JSONObject toJSON() {
		JSONObject temp = new JSONObject();
		temp.put("id", id);
		temp.put("time", time);
		temp.put("pokemonNo", pokemon_no);
		temp.put("ranking", ranking);
		return temp;
	}

	public String toString() {
		return toJSON().toString();
	}

	public Integer getId() {
		return id;
	}

	public Date getTime() {
		return time;
	}

	public String getPokemonNo() {
		return pokemon_no;
	}

	public Integer getRanking() {
		return ranking;
	}
	
	
}
