package com.oracle.Legal.security.handler;

import java.io.IOException;

import javax.crypto.SecretKey;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.CredentialsExpiredException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class FormAuthenticationFailureHandler extends SimpleUrlAuthenticationFailureHandler {

	@Override
	// 인증 실패 시 호출되는 메서드
	// HttpServletRequest, HttpServletResponse, AuthenticationException 파라미터를 받음
	// 이 메서드에서 인증 실패 후의 로직을 정의할 수 있음
	public void onAuthenticationFailure(HttpServletRequest request, 
										HttpServletResponse response, 
										AuthenticationException exception)
            throws IOException, ServletException {
		String errorMessage = "Invalid Username or Password";
		
		if(exception instanceof BadCredentialsException) {
            errorMessage = "Invalid Password";
		} else if(exception instanceof UsernameNotFoundException) {
            errorMessage = "User not exists";
		} else if(exception instanceof CredentialsExpiredException) {
            errorMessage = "Expired password";
		}  else if(exception instanceof SecretKey) {
            errorMessage = "Invalid Secret key";
		}
		setDefaultFailureUrl("/login?error=true&exception=" + errorMessage);
		System.out.println("onAuthenticationFailure exception->"+exception);
		super.onAuthenticationFailure(request, response, exception);
		
    }
}
