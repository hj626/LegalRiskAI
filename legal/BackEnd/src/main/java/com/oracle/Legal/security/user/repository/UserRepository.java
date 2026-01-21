package com.oracle.Legal.security.user.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.oracle.Legal.domain.Account;


public interface UserRepository extends JpaRepository<Account, Long> {

	Account findByUsername(String username);

	@Query(value =" SELECT a.id, a.username, a.password, a.roles"
		     	+ " FROM (SELECT ROWNUM rn, id, username, password, roles"
		     	+ "       FROM Account ORDER BY id) a "
		     	+ " WHERE rn BETWEEN :start AND :end", 
		       nativeQuery = true)
	List<Object[]> findPageAccountNative(@Param("start") int start, @Param("end") int end);
}
