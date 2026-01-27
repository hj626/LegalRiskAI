package com.oracle.Legal.repository;

import org.springframework.stereotype.Repository;

import com.oracle.Legal.domain.Account;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
@Transactional
public class AccountRepositoryImpl implements AccountRepository {

	private final EntityManager em;

	@Override
	public void save(Account account) {
		
		em.persist(account);
	}

	@Override
	public Account findByClient_code(int client_code) {
	    try {
	        return em.createQuery(
	            "select a from Account a where a.client_code = :client_code",
	            Account.class
	        ).setParameter("client_code", client_code)
	         .getSingleResult();
	    } catch (jakarta.persistence.NoResultException e) {
	        return null;
	    }
	}

	@Override
	public void update(Account account) {

		em.merge(account);
		
	}

	

}
