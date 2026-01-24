package com.oracle.Legal.repository;

import com.oracle.Legal.domain.Client;
import com.oracle.Legal.dto.ClientDto;

public interface ClientRepository {

	void save(Client client);

	ClientDto findByClient_code(int client_code);

	Client findEntityByClient_code(int client_code);

}
