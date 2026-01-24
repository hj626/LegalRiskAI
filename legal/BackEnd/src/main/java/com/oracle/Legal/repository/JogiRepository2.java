package com.oracle.Legal.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.oracle.Legal.domain.Jogi;

public interface JogiRepository2 extends JpaRepository<Jogi, Integer> {
	@Query("select j from Jogi j where j.client_code = :clientCode order by j.jogi_date desc")
	  List<Jogi> findHistory(@Param("clientCode") int clientCode);
}
