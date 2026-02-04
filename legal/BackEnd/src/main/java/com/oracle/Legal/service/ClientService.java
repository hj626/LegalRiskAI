package com.oracle.Legal.service;
import java.util.List;

import com.oracle.Legal.dto.ClientDto;
import com.oracle.Legal.dto.HistoryDto;
import com.oracle.Legal.dto.PageDto;

public interface ClientService {

	void informSave(ClientDto clientDto);

	ClientDto getSingleClient(int client_code);

	void updateUser(ClientDto clientDto);

	void clientDel(int clientCode);

	PageDto<ClientDto> getClientPage(int page, int size);

	void updateClientIsDel(int clientCode, int clientIsDel);
	
    List<HistoryDto> getFavorites(int clientCode);


}
