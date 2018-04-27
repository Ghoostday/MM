package com.innology.moonmasons.repo;

import java.util.Date;
import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import com.innology.moonmasons.model.Photo;

@RepositoryRestResource(exported = false)
public interface PhotoRepo extends CrudRepository<Photo, Long> {
	
	Photo findByProviderAndIdentifier(int provider, long identifier);
	
	List<Photo> findAll();
	
	@Query("SELECT p from Photo p WHERE p.latitude > :latitude1 AND p.latitude < :latitude2 AND p.longitude > :longitude1 AND p.longitude < :longitude2")
	List<Photo> findByGrid(@Param("latitude1") double latitude1, @Param("longitude1") double longitude1, @Param("latitude2") double latitude2, @Param("longitude2") double longitude2);

	List<Photo> findByDateLessThan(Date date);
}
