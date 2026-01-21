package com.oracle.Legal.domain;

import org.hibernate.annotations.ColumnDefault;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import lombok.Data;

@Entity
@Data
@SequenceGenerator (
		name = "account_seq",			
		sequenceName = "ACCOUNT_SEQ",	 
		initialValue = 1,			
		allocationSize = 1				
		)
public class Account {
	@Id
	@GeneratedValue(
			strategy = GenerationType.SEQUENCE,
			generator = "account_seq"	
			)
	@Column(name = "id")			
	private Long id;						//계정 시퀀스
	private int client_code;				//회원 코드
	private String username;				//계정 아이디
	private String password;				//계정 패스워드
	private String roles;					//시스템 롤
	
}
