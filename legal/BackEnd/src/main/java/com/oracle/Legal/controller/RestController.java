package com.oracle.Legal.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import com.oracle.Legal.dto.AccountDto;

@org.springframework.web.bind.annotation.RestController
public class RestController {

	/*
	 * 현재 로그인한 사용자 정보 반환 (React Header 연동용)
	 * @return 로그인된 사용자 정보 (AccountDto) 또는 401 Unauthorized
	 */
	@GetMapping("/api/user/me")
    public org.springframework.http.ResponseEntity<?> getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        // 인증 정보 확인 및 Principal 타입 검증
        if (auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof AccountDto) {
            AccountDto account = (AccountDto) auth.getPrincipal();
            
            // 보안: 패스워드 정보는 클라이언트로 전달하지 않음
            account.setPassword(null); 
            return org.springframework.http.ResponseEntity.ok(account);
        }
        
        // 비회원 접근 시 401 응답
        return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.UNAUTHORIZED).build();
    }
}
