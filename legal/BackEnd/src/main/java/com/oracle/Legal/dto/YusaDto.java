package com.oracle.Legal.dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.springframework.format.annotation.DateTimeFormat;

import com.oracle.Legal.domain.Yusa;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class YusaDto {

    private int yusa_code;        // 유사판례 사건 코드
    private int client_code;      // 회원 코드

    private String yusa_input;    // 사건 내용 (사용자 입력)
    private String yusa_output;   // AI 분석 결과

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDateTime yusa_date; // 입력일

    private int yusa_mark;        // AI 위험도 점수 or 즐겨찾기

    /* ===============================
     * AI 확장용 (DB 저장 안 해도 됨)
     * =============================== */
    private String caseType;      // 민사/형사/노동/가사 (선택)

    public YusaDto(Yusa yusa) {
        this.yusa_code   = yusa.getYusa_code();
        this.client_code = yusa.getClient_code();
        this.yusa_input  = yusa.getYusa_input();
        this.yusa_output = yusa.getYusa_output();
        this.yusa_date   = yusa.getYusa_date();
        this.yusa_mark   = yusa.getYusa_mark();
    }
	//등록일 yyyy-MM-dd로 변경
    public String getLaw_dateFormatted() {
        return (yusa_date == null)
                ? ""
                : yusa_date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }}
