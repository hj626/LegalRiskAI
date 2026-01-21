package com.oracle.Legal.security.handler;

import java.io.IOException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.DefaultRedirectStrategy;
import org.springframework.security.web.RedirectStrategy;
import org.springframework.security.web.access.AccessDeniedHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//사용자가 로그인까지는 했는데, 특정 리소스(페이지나 기능)에 접근할 권한이 없을 때 어떻게 처리할지를 정의
public class FormAccessDeniedHandler implements AccessDeniedHandler {

	// RedirectStrategy는 웹 애플리케이션에서 사용자를 다른 URL로 리다이렉트(재경로 지정)할 때 쓰는 객체
	// RedirectStrategy는 Spring Security에서 제공하는 인터페이스로, 리다이렉트 방식과 URL을 정의할 수 있음
	private final RedirectStrategy redirectStrategy = new DefaultRedirectStrategy();
	private final String errorPage;

	public FormAccessDeniedHandler(String errorPage) {
		this.errorPage = errorPage;
	}
	
	@Override
	public void handle(HttpServletRequest request, HttpServletResponse response,
			AccessDeniedException accessDeniedException) throws IOException, ServletException {
		// 오류 페이지에서 "왜 접근이 거부되었는지"를 사용자에게 전달
		String deniedUrl = errorPage + "?exception=" + accessDeniedException.getMessage();
		// DefaultRedirectStrategy를 이용해서 deniedUrl로 사용자를 강제로 이동
		redirectStrategy.sendRedirect(request, response, deniedUrl);
		// 이 메서드는 사용자가 접근 권한이 없는 리소스에 접근하려고 할 때 호출됨
		

	}

}
