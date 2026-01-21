package com.oracle.Legal.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountDto {
	
//	//private int account_seq;
	private Long id;
	private int client_code;
	private String username;
	private String password;
	private String roles;
	private String displayName;
	
	public AccountDto(int Long, String username, String password,String roles){
		this.client_code = getClient_code();
		this.username = getUsername();
		this.password = getPassword();
		this.roles = getRoles();	
	}
	
}
