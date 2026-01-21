package com.oracle.Legal.repository;

import org.springframework.stereotype.Repository;

import com.oracle.Legal.domain.Account;

import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Repository
@Transactional
@RequiredArgsConstructor
public class AccountRepositoryImpl implements AccountRepository {

	private final EntityManager em;

	@Override
	public void save(Account account) {
		
		em.persist(account);
	}
	
	

}
