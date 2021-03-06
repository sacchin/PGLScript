package com.gmail.sacchin13.spring_boot_sample.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.gmail.sacchin13.spring_boot_sample.entity.WazaInfo;

@Repository
public interface WazaInfoRepository extends JpaRepository<WazaInfo, Integer> {
//	@Query("select new sample.data.jpa.domain.HotelSummary(h.city, h.name, avg(r.rating)) "
//			+ "from Hotel h left outer join h.reviews r where h.city = ?1 group by h")
//	@Query("select new sample.data.jpa.domain.RatingCount(r.rating, count(r)) "
//			+ "from Review r where r.hotel = ?1 group by r.rating order by r.rating DESC")

	@Query("select max(w.ranking_pokemon_trend_id) from WazaInfo w order by id DESC")
	public int findMaxId();

	@Query("SELECT new com.gmail.sacchin13.spring_boot_sample.entity.WazaInfo("
			+ "w.ranking_pokemon_trend_id, w.ranking, w.type_id, w.sequence_number, w.usage_rate, name) "
			+ "FROM WazaInfo w WHERE w.ranking_pokemon_trend_id = :parentId")
    public List<WazaInfo> findByParentId(@Param("parentId") int parentId);
	
	@Query("select new com.gmail.sacchin13.spring_boot_sample.entity.WazaInfo("
			+ "w.ranking_pokemon_trend_id, w.ranking, w.type_id, w.sequence_number, w.usage_rate, name) "
			+ "from WazaInfo w order by id DESC")
	public List<WazaInfo> findLimit();
}