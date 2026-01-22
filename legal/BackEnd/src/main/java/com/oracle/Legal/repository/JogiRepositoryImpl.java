package com.oracle.Legal.repository;

import org.springframework.stereotype.Repository;

import com.oracle.Legal.domain.Jogi;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class JogiRepositoryImpl implements JogiRepository {

	private final EntityManager em; 
	
	@Override
	public Jogi jogiSave(Jogi jogi) {
		
		em.persist(jogi);
		
		return jogi;
	}

}
