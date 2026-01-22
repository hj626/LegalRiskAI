package com.oracle.Legal.repository;

import org.springframework.stereotype.Repository;

import com.oracle.Legal.domain.Yusa;

import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class YusaRepositoryImpl implements YusaRepository {

	private final EntityManager em;
	
	@Override
	public Yusa yusaSave(Yusa yusa) {
		
	em.persist(yusa);
	
	return yusa;
	}
	
}
