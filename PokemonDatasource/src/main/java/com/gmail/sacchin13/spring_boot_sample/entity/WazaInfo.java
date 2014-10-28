package com.gmail.sacchin13.spring_boot_sample.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class WazaInfo {

    @Id
    @GeneratedValue
    protected Integer id;
    protected int ranking_pokemon_trend_id;
    protected int ranking;
    protected int type_id;
    protected int sequence_number;
    protected float usage_rate;
    protected String name;
    
    public WazaInfo() {
      super();
    }

    public WazaInfo(int ranking_pokemon_trend_id, int ranking, int type_id, int sequence_number, float usage_rate, String name) {
      super();
      this.name = name;
      this.ranking_pokemon_trend_id  = ranking_pokemon_trend_id;
      this.ranking = ranking;
      this.type_id = type_id;
      this.sequence_number = sequence_number;
      this.usage_rate = usage_rate;
      this.name = name;      
    }

    // for debug
    public String toString() {
      return "{id:" + id + ", ranking_pokemon_trend_id:" + ranking_pokemon_trend_id + ", ranking:" + ranking +
    		  ", sequence_number:" + sequence_number + ", usage_rate:" + usage_rate + "}";
    }

}
