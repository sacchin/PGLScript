package com.gmail.sacchin13.spring_boot_sample.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.gmail.sacchin13.spring_boot_sample.entity.RankingPokemonTrend;

@Repository
public interface RankingPokemonTrendRepository extends JpaRepository<RankingPokemonTrend, Integer> {
	//	@Query("select new sample.data.jpa.domain.HotelSummary(h.city, h.name, avg(r.rating)) "
	//	+ "from Hotel h left outer join h.reviews r where h.city = ?1 group by h")
	//@Query("select new sample.data.jpa.domain.RatingCount(r.rating, count(r)) "
	//	+ "from Review r where r.hotel = ?1 group by r.rating order by r.rating DESC")

	@Query("SELECT new com.gmail.sacchin13.spring_boot_sample.entity.RankingPokemonTrend("
			+ "r.id, r.time, r.pokemon_no) FROM RankingPokemonTrend r WHERE r.pokemon_no = :pokemonNo order by r.time desc")
	public List<RankingPokemonTrend> findLater(@Param("pokemonNo") String pokemonNo);

	@Query("SELECT new com.gmail.sacchin13.spring_boot_sample.entity.RankingPokemonTrend("
			+ "r.id, r.time, r.pokemon_no) FROM RankingPokemonTrend r WHERE r.pokemon_no = :pokemonNo order by r.time asc")
	public List<RankingPokemonTrend> findOlder(@Param("pokemonNo") String pokemonNo);
}
