package com.oracle.Legal.controller;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.dto.BoonjangDto;
import com.oracle.Legal.service.BoonjangService;

import lombok.RequiredArgsConstructor;

/**
 * 분쟁 유형 분석(Boonjang) 관련 API 컨트롤러
 * 
 * 작성자: 김은혜
 * 설명: 클라이언트의 분쟁 분석 요청을 처리하고, 결과를 DB에 저장하는 역할을 담당합니다.
 *       JWT 기반 인증을 통해 로그인한 사용자만 접근할 수 있도록 보안 처리하였습니다.
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/boonjang")
public class BoonjangRestController {

    private final BoonjangService boonjangService;

    /**
     * 분쟁/법적 위험 분석 결과 저장 API
     * 
     * @param req : 클라이언트에서 전달받은 분쟁 내용 및 분석 결과 (DTO)
     * @param principal : Spring Security가 주입해주는 현재 로그인한 사용자 정보
     * @return savedBoonjangCode : 저장된 분쟁 레코드의 PK
     */
    @PostMapping("/save")
    public int save(@RequestBody BoonjangDto req,
                    @AuthenticationPrincipal AccountDto principal) {
        
        // 보안 검증: 비로그인 사용자의 요청 차단
        if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요한 서비스입니다.");
        }

        // Entity 변환 및 비즈니스 로직은 Service 계층으로 위임
        int clientCode = principal.getClient_code();
        return boonjangService.save(req.getBoonjang_input(), clientCode, req.getBoonjang_output(), req.getBoonjang_mark());
    }
}
