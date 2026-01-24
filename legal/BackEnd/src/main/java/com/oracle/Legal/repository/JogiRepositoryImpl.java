package com.oracle.Legal.repository;

import org.springframework.stereotype.Repository;

import com.oracle.Legal.domain.Jogi;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
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

	@Override
	public Jogi findOne(int client_code, int jogi_code) {
	    try {
	        return em.createQuery(
	            "select j from Jogi j where j.client_code = :cc and j.jogi_code = :jc",
	            Jogi.class
	        )
	        .setParameter("cc", client_code)
	        .setParameter("jc", jogi_code)
	        .getSingleResult();

	    } catch (NoResultException e) {
	        return null;
	    }
	}


}
