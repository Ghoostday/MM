package com.innology.moonmasons.repo;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import com.innology.moonmasons.model.UserAccount;

public interface UserAccountRepo extends CrudRepository<UserAccount, Long> {
	
//	REQUIRES Spring Data JPA 1.8.0, not really needed 
//	@Query("SELECT u from UserAccount u WHERE u.username = ?#{principal.username}")
//	List<UserAccount> findAll();
//
//	@Query("SELECT u from UserAccount u WHERE u.id = :id AND u.username = ?#{principal.username}")
//	UserAccount findOne(@Param("id") Long id);

//	@Query("SELECT u from UserAccount u WHERE u.username = :username AND u.username = ?#{principal.username}")
	UserAccount findByUsername(@Param("username") String username);
	
	UserAccount findByProviderAndIdentifier(int provider, long identifier);
}
