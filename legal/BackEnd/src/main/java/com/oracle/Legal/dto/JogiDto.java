package com.oracle.Legal.dto;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.oracle.Legal.domain.Jogi;
import com.oracle.Legal.domain.Law;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class JogiDto {
	
	private int 	 jogi_code;						
	private int 	 client_code;					
	private String	 jogi_input;					
	private String 	 jogi_output;					
	
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss") 
	private LocalDateTime	jogi_date;
    private int jogi_winrate;
    private int jogi_mark;
	
	public JogiDto(Jogi jogi) {
		this.jogi_code = jogi.getJogi_code();
		this.client_code = jogi.getClient_code();
		this.jogi_input = jogi.getJogi_input();
		this.jogi_output = jogi.getJogi_output();
		this.jogi_date = jogi.getJogi_date();
		this.jogi_winrate = jogi.getJogi_winrate();
		this.jogi_mark = jogi.getJogi_mark();
	}
	
	//등록일 yyyy-MM-dd로 변경
    public String getJogi_dateFormatted() {
        return (jogi_date == null)
                ? ""
                : jogi_date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }
	

}
