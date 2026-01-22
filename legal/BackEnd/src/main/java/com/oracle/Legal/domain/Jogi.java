package com.oracle.Legal.domain;

import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name="jogi")
@SequenceGenerator (
		name = "jogi_seq",
		sequenceName = "JOGI_SEQ",
		initialValue = 500000,
		allocationSize = 1
		)
@EntityListeners(AuditingEntityListener.class)
public class Jogi {
	@Id
	@GeneratedValue(
			strategy = GenerationType.SEQUENCE,
			generator = "jogi_seq"		//법적위험사건ID-시퀀스 생성기
			)
	private int jogi_code;
	private int client_code;
	@Lob
	private String jogi_input;
	@Lob
	private String jogi_output;
	@CreatedDate
	private LocalDateTime jogi_date;
	private int jogi_winrate;
	
	public void changeJogi_code(int jogi_code) {
		this.jogi_code = jogi_code;
	}
	public void changeClient_code(int client_code) {
		this.client_code = client_code;
	}
	public void changeJogi_input(String jogi_input) {
		this.jogi_input = jogi_input;
	}
	public void changeJogi_output(String jogi_output) {
		this.jogi_output = jogi_output;
	}
	public void changejogi_date(LocalDateTime jogi_date) {
		this.jogi_date = jogi_date;
	}
	public void changejogi_winrate(int jogi_winrate) {
		this.jogi_winrate = jogi_winrate;
	}
}
