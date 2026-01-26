package com.oracle.Legal.dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.oracle.Legal.domain.Boonjang;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 분쟁 데이터 전송 객체 (DTO)
 * 
 * 작성자: 김은혜
 * 설명: FrontEnd와 통신하기 위한 객체이다
 *       Entity를 직접 노출하지 않고, 필요한 데이터만 선별하여 주고받기 위해 사용한다
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BoonjangDto {
	
	private int 	 boonjang_code;		// PK
	private int 	 client_code;		// 작성자 ID
	private String	 boonjang_input;	// 분쟁 내용
	private String 	 boonjang_output;	// 분석 결과

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss") 
	private LocalDateTime	boonjang_date;	// 작성일
    
	private int 	 boonjang_mark;		// 즐겨찾기
	
	// Entity -> DTO 변환 생성자
	public BoonjangDto(Boonjang boonjang) {
		this.boonjang_code = boonjang.getBoonjang_code();
		this.client_code = boonjang.getClient_code();
		this.boonjang_input = boonjang.getBoonjang_input();
		this.boonjang_output = boonjang.getBoonjang_output();
		this.boonjang_date = boonjang.getBoonjang_date();
		this.boonjang_mark = boonjang.getBoonjang_mark();
			
	}
	
	// 날짜 포맷팅 편의 메서드 (화면 표시용)
    public String getBoonjang_dateFormatted() {
        return (boonjang_date == null)
                ? ""
                : boonjang_date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }
}
