package com.oracle.Legal.repository;

import java.util.List;

import com.oracle.Legal.domain.Client;
import com.oracle.Legal.dto.ClientDto;

public interface ClientRepository {

	void save(Client client);

	ClientDto findByClient_code(int client_code);

	Client findEntityByClient_code(int client_code);
	
	Client findEntityByNameAndEmail(String client_name, String client_email);
	int countClients();
	List<ClientDto> findClientsPage(int offset, int safeSize);

}
