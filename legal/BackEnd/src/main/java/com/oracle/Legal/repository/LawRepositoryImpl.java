package com.oracle.Legal.repository;

import org.springframework.stereotype.Repository;

import com.oracle.Legal.domain.Law;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class LawRepositoryImpl implements LawRepository {

	private final EntityManager em;
	
	@Override
	public Law lawSave(Law law) {
	
	em.persist(law);
	
	return law;
	}

	@Override
	public Law findOne(int client_code, int law_code) {
	    try {
	        return em.createQuery(
	            "select l from Law l where l.client_code = :cc and l.law_code = :lc",
	            Law.class
	        )
	        .setParameter("cc", client_code)
	        .setParameter("lc", law_code)
	        .getSingleResult();
	    } catch (NoResultException e) {
	        return null;
	    }
	}



}
