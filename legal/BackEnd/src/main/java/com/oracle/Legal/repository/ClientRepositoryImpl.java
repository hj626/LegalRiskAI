package com.oracle.Legal.repository;

import org.springframework.stereotype.Repository;

import com.oracle.Legal.domain.Client;
import com.oracle.Legal.dto.ClientDto;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
@Transactional
public class ClientRepositoryImpl implements ClientRepository {
	
	private final EntityManager em;

	@Override
	public void save(Client client) {
		
		em.persist(client);
	}

	@Override
	public ClientDto findByClient_code(int client_code) {
		
		  try {
		        Client c = em.createQuery(
		                "select c from Client c where c.client_code = :client_code",
		                Client.class
		        )
		        .setParameter("client_code", client_code)
		        .getSingleResult();

		        ClientDto dto = new ClientDto();
		        dto.setClient_code(c.getClient_code());
		        dto.setClient_name(c.getClient_name());
		        // ClientDto에 필요한 필드 더 있으면 여기서 계속 set 하시면 됩니다.

		        return dto;

		    } catch (NoResultException e) {
		        return null; 

		    }
	}
}
