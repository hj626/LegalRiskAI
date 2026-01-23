package com.oracle.Legal.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.oracle.Legal.domain.Yusa;

public interface YusaRepository2 extends JpaRepository<Yusa, Integer> {
	  @Query("select y from Yusa y where y.client_code = :clientCode order by y.yusa_date desc")
	  List<Yusa> findHistory(@Param("clientCode") int clientCode);
}
