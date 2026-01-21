package com.oracle.Legal.security.details;

import org.springframework.security.web.authentication.WebAuthenticationDetails;

import jakarta.servlet.http.HttpServletRequest;
import lombok.Getter;

@Getter
// 1. Spring Security에서 제공하는 WebAuthenticationDetails를 확장!
// 2. 로그인 요청이 들어왔을 때, 사용자의 기본 인증 정보 외에 추가적인 정보를 담아서 다음 단계(예: 인증 공급자 authenticate 메서드)
// 3. FormWebAuthenticationDetails는 Spring Security의 기본 인증 정보에 개발자가 필요로 하는 추가적인 정보를 덧붙여서 
//   (예를 들어, 사용자 IP, 세션 정보에 더해 secretKey 같은 인증 과정 다음 단계로 안전하게 전달
public class FormWebAuthenticationDetails extends WebAuthenticationDetails {

	// 2. 추가로 저장할 secretKey 필드
	private final String secretKey;

	public FormWebAuthenticationDetails(HttpServletRequest request) {
		super(request);
      
        secretKey = request.getParameter("secret_key");
	}


}
