package com.oracle.Legal.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.oracle.Legal.domain.Law;

public interface LawRepository2 extends JpaRepository<Law,Integer> {
    @Query("select l from Law l where l.client_code = :clientCode order by l.law_date desc")
     List<Law> findHistory(@Param("clientCode") int clientCode);
}
