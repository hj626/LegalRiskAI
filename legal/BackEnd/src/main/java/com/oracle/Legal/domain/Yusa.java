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
@Table(name = "yusa")     // 유사판례 테이블
@SequenceGenerator(
        name = "yusa_seq",
        sequenceName = "YUSA_SEQ",
        initialValue = 400000,     // law랑 겹치지 않게 범위 분리
        allocationSize = 1
)
@EntityListeners(AuditingEntityListener.class)
public class Yusa {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "yusa_seq"
    )

    private int yusa_code;
    private int client_code;       // 회원 코드
    @Lob
    private String yusa_input;     // 사건 내용
    @Lob
    private String yusa_output;    // 사건 결과(AI 분석)

    @CreatedDate
    private LocalDateTime yusa_date;   // 입력일

    private int yusa_mark;     // 즐겨찾기 (0/1)

    // ===== 검증용 코드 (Law 패턴 그대로) =====

    public void changeYusa_id(int yusa_code) {
        this.yusa_code = yusa_code;
    }

    public void changeClient_code(int client_code) {
        this.client_code = client_code;
    }

    public void changeYusa_input(String yusa_input) {
        this.yusa_input = yusa_input;
    }

    public void changeYusa_output(String yusa_output) {
        this.yusa_output = yusa_output;
    }

    public void changeYusa_date(LocalDateTime yusa_date) {
        this.yusa_date = yusa_date;
    }

    public void changeYusa_bookmark(int yusa_mark) {
        this.yusa_mark = yusa_mark;
    }
}