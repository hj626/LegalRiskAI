package com.oracle.Legal.security.handler;

import java.io.IOException;

import org.springframework.security.core.Authentication;
import org.springframework.security.web.DefaultRedirectStrategy;
import org.springframework.security.web.RedirectStrategy;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class FormAuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

	private final RequestCache requestCache = new HttpSessionRequestCache();
	private final RedirectStrategy redirectStrategy = new DefaultRedirectStrategy();

	@Override
	public void onAuthenticationSuccess(HttpServletRequest request,
			                            HttpServletResponse response,
			                            Authentication authentication)
			throws IOException, ServletException {
		 // setDefaultTargetUrl("/"); // 인증 성공 후 기본적으로 이동할 URL 설정 (예: 홈 페이지)
		 setDefaultTargetUrl("/main");
		// 인증 성공 후 사용자가 요청한 URL로 리다이렉트
		var savedRequest = requestCache.getRequest(request, response);
		if (savedRequest != null) {
			String targetUrl = savedRequest.getRedirectUrl();
            // RedirectStrategy를 사용하여 인증 성공 후 리다이렉트
			redirectStrategy.sendRedirect(request, response, targetUrl);
		} else {
			redirectStrategy.sendRedirect(request, response, getDefaultTargetUrl());
		}
		// 인증 성공 후 추가적인 작업을 수행할 수 있음
		super.onAuthenticationSuccess(request, response, authentication);
	}
}
