package com.oracle.Legal.repository;

import com.oracle.Legal.domain.Boonjang;

/**
 * 분쟁 데이터 저장소 인터페이스 (Repository Interface)
 * 
 * 작성자: 김은혜
 * 설명: 데이터베이스와 대화(저장, 조회)하기 위한 인터페이스 입니다.
 *       실제 구현하기 위해서는 BoonjangRepositoryImpl 에서 해야 합니다.
 */
public interface BoonjangRepository {

	// 분쟁위험 분석 저장
	Boonjang save(Boonjang boonjang);
	
	// 분쟁위험 찾기
	Boonjang findOne(int clientCode, int intValue);

}
