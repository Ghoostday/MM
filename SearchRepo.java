package com.innology.moonmasons.repo;

import java.util.Date;
import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import com.innology.moonmasons.model.Search;

public interface SearchRepo extends CrudRepository<Search, Long> {
	
//	REQUIRES Spring Data JPA 1.8.0, not really needed 
//	@Query("SELECT s from Search s WHERE s.owner.username = ?#{principal.username}")
//	List<Search> findAll();
//
//	@Query("SELECT s from Search s WHERE s.id = :id AND s.owner.username = ?#{principal.username}")
//	Search findOne(@Param("id") Long id);

	@Query("SELECT s from Search s WHERE s.latitude = :latitude AND s.longitude = :longitude")
	List<Search> findByLatitudeLongitude(@Param("latitude") double latitude, @Param("longitude") double longitude);
	
	@Query("SELECT s from Search s WHERE s.latitude > :latitude1 AND s.latitude < :latitude2 AND s.longitude > :longitude1 AND s.longitude < :longitude2 ORDER BY s.date DESC")
	List<Search> findByGrid(@Param("latitude1") double latitude1, @Param("longitude1") double longitude1, @Param("latitude2") double latitude2, @Param("longitude2") double longitude2, Pageable pageable);

	List<Search> findByDateLessThan(Date date);
}
