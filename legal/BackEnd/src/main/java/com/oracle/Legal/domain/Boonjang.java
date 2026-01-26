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

/**
 * 분쟁 데이터 Entity (Domain Layer)
 * 
 * 작성자: 김은혜
 * 설명: DB의 'boonjang' 테이블과 1:1로 매핑되는 클래스입니다
 *       JPA 어노테이션을 사용하여 테이블 구조(PK, Sequence, Column)를 정의
 */
@Entity
@Data
@Table(name ="boonjang")
@SequenceGenerator (
		name = "boonjang_seq",
		sequenceName = "BOONJANG_SEQ", // DB 시퀀스 명
		initialValue = 100000,
		allocationSize = 1
		)
@EntityListeners(AuditingEntityListener.class) // 생성일/수정일 자동 관리를 위한 리스너
public class Boonjang {
	
	@Id
	@GeneratedValue(
			strategy = GenerationType.SEQUENCE,
			generator = "boonjang_seq"
			)
	private int		boonjang_code;		// PK: 분쟁해결 코드 (시퀀스로 자동 생성)
	
	private int		client_code;		// FK: 작성자 회원 코드
	
	@Lob // 대용량 텍스트 저장 (CLOB)
	private String 	boonjang_input;		// 분쟁 상황 (Input)
	
	@Lob
	private String 	boonjang_output;	// 분석 결과 및 피드백 (Output)
	
	@CreatedDate
	private LocalDateTime boonjang_date;// 등록일시 (자동 생성)
	
	private int 	boonjang_mark;		// 즐겨찾기 여부 (1: On, 0: Off)
}
