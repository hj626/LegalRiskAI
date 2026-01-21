package com.oracle.Legal.security.details;

import org.springframework.security.authentication.AuthenticationDetailsSource;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;

@Component
public class FormWebAuthenticationDetailsSource
		implements AuthenticationDetailsSource<HttpServletRequest, WebAuthenticationDetails> {

	@Override
	public WebAuthenticationDetails buildDetails(HttpServletRequest request) {
		// FormWebAuthenticationDetails를 사용하여 HttpServletRequest에서 인증 세부 정보를 생성
		return new FormWebAuthenticationDetails(request);
	}

}
