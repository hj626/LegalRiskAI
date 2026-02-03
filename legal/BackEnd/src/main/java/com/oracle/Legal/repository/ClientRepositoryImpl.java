package com.oracle.Legal.repository;

import java.util.List;
import java.util.stream.Collectors;

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
		        dto.setClient_email(c.getClient_email());
		        dto.setClient_tel(c.getClient_tel());
		        dto.setClient_job(c.getClient_job());
		        dto.setClient_is_del(c.getClient_is_del());  
		        dto.setClient_reg_date(c.getClient_reg_date());

		        
		        return dto;

		    } catch (NoResultException e) {
		        return null; 

		    }
	}

	@Override
	public Client findEntityByClient_code(int client_code) {
	    try {
	        return em.createQuery(
	            "select c from Client c where c.client_code = :client_code",
	            Client.class
	        ).setParameter("client_code", client_code)
	         .getSingleResult();
	    } catch (NoResultException e) {
	        return null;
	    }
	}
	
	@Override
	public Client findEntityByNameAndEmail(String client_name, String client_email) {
	    try {
	        return em.createQuery(
	            "select c from Client c where c.client_name = :name and c.client_email = :email",
	            Client.class
	        )
	        .setParameter("name", client_name)
	        .setParameter("email", client_email)
	        .getSingleResult();
	    } catch (NoResultException e) {
	        return null;
	    }
	}

    @Override
    public int countClients() {
        Long cnt = em.createQuery("select count(c) from Client c", Long.class)
                     .getSingleResult();
        return cnt.intValue();
    }


	@Override
	public List<ClientDto> findClientsPage(int offset, int size) {
	    List<Client> list = em.createQuery(
	            "select c from Client c order by c.client_code asc",
	            Client.class
	    )
	    .setFirstResult(offset)
	    .setMaxResults(size)
	    .getResultList();
	
	    return list.stream().map(c -> {
	        ClientDto dto = new ClientDto();
	        dto.setClient_code(c.getClient_code());
	        dto.setClient_name(c.getClient_name());
	        dto.setClient_email(c.getClient_email());
	        dto.setClient_tel(c.getClient_tel());
	        dto.setClient_job(c.getClient_job());
	        dto.setClient_is_del(c.getClient_is_del()); 
	        dto.setClient_reg_date(c.getClient_reg_date());
	        return dto;
	    }).collect(Collectors.toList());
	}

}
