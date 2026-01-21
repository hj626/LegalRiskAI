package com.oracle.Legal.dto;

import com.oracle.Legal.domain.Client;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClientDto {

	private int    client_code;				//회원 코드
	private String client_name;				//이름
	private String client_email;			//이메일
	private String    client_tel;				//전화번호
	private String client_job;				//직업
	private int    client_is_del;		//삭제여부
	
	// account
    private String username;
    private String password;
	
	public ClientDto(Client client){
		this.client_code = client.getClient_code();
		this.client_name = client.getClient_name();
		this.client_email = client.getClient_email();
		this.client_tel = client.getClient_tel();
		this.client_job = client.getClient_job();
		this.client_is_del = client.getClient_is_del();
		
	
	}
	
}
