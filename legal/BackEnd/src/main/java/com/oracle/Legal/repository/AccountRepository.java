package com.oracle.Legal.repository;

import com.oracle.Legal.domain.Account;

public interface AccountRepository {

	void save(Account account);
	
    Account findByClient_code(int client_code);

	void update(Account account);  

}	
