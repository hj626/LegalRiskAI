package com.oracle.Legal.dto;

import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import lombok.Data;

@Data
public class AccountContext implements UserDetails {
	private static final long serialVersionUID = 1L;
	
	private AccountDto accountDto;
	private final List<GrantedAuthority> roles;
	

	public AccountContext(AccountDto accountDto , List<GrantedAuthority> roles) {
        this.accountDto = accountDto;
        this.roles = roles;
	}

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return roles;
	}

	@Override
	public String getUsername() {
		
		return accountDto.getUsername();
	}

	@Override
	public String getPassword() {

		return accountDto.getPassword();
	}


}
