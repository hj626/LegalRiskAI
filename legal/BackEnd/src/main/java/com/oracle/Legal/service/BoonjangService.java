package com.oracle.Legal.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.oracle.Legal.domain.Boonjang;
import com.oracle.Legal.repository.BoonjangRepository;

import lombok.RequiredArgsConstructor;

/**
 * 분쟁 분석 서비스 (Service Layer)
 * 
 * 작성자: 김은혜
 * 설명: 컨트롤러와 리포지토리 사이에서 데이터  및 트랜잭션 처리를 담당한
 *       단순 저장이지만, 향후 AI 분석 로직 연동이나 데이터 검증 로직이 추가될 수 있습니다.
 */
@Service
@RequiredArgsConstructor
public class BoonjangService {

    private final BoonjangRepository boonjangRepository;

    /**
     * 분쟁 데이터 저장 (Transactional)
     * 
     * @param boonjangInput  : 사용자가 입력한 분쟁 상황
     * @param clientCode     : 작성자 식별 코드
     * @param boonjangOutput : AI 분석 결과 (또는 테스트용 출력 값)
     * @param boonjangMark   : 즐겨찾기 상태 (1: 즐겨찾기, 0: 일반)
     * @return savedCode     : 저장된 PK 값 반환
     */
    @Transactional
    public int save(String boonjangInput, int clientCode, String boonjangOutput, int boonjangMark) {
        
        // 1. Entity 생성 
        Boonjang boonjang = new Boonjang();
        boonjang.setClient_code(clientCode);
        boonjang.setBoonjang_input(boonjangInput);
        boonjang.setBoonjang_output(boonjangOutput);
        boonjang.setBoonjang_mark(boonjangMark);
        
        // 2. Repository를 통해  결과 반환
        return boonjangRepository.save(boonjang).getBoonjang_code();
    }
}
