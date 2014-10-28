package com.gmail.sacchin13.spring_boot_sample.entity;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class RankingPokemonTrend {
	@Id
	@GeneratedValue
	protected Integer id;
	protected Date time;
	protected String pokemon_no;
	
	public RankingPokemonTrend() {
		super();
	}

	public RankingPokemonTrend(int id, Date time, String pokemon_no) {
		this.id = id;
		this.time  = time;
		this.pokemon_no = pokemon_no;
	}

	public String toString() {
		return "{id:" + id + ", time:" + String.valueOf(time.getTime()) + ", pokemon_no:" + pokemon_no + "}";
	}
}