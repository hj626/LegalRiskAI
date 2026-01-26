package com.oracle.Legal.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.oracle.Legal.domain.Boonjang;

/**
 * 분쟁 이력 조회용 저장소 (JPA Repository)
 * 
 * 작성자: 김은혜
 * 설명: '마이페이지'에서 내가 작성한 분쟁 내역 목록을 가져올 때 사용합니다.
 *       따로 구현체(Impl)를 만들지 않아도, Spring이 알아서 '최신순 정렬 조회' 기능을 만들어줍니다.
 */
public interface BoonjangRepository2 extends JpaRepository<Boonjang, Integer> {
    
    // 특정 회원(clientCode)의 분쟁 내역을 날짜 내림차순(최신순)으로 조회
    @Query("select b from Boonjang b where b.client_code = :clientCode order by b.boonjang_date desc")
     List<Boonjang> findHistory(@Param("clientCode") int clientCode);
}
