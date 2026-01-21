package com.oracle.Legal.security.provider;

import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.oracle.Legal.dto.AccountContext;
import com.oracle.Legal.security.details.FormWebAuthenticationDetails;
import com.oracle.Legal.security.exception.SecretException;

import lombok.RequiredArgsConstructor;

@Component("authenticationProvider")
@RequiredArgsConstructor	
//DB에서 가져온 정보와 input 된 정보가 비교되서 체크되는 로직이 포함되어있는 인터페이스
//사용자가 입력한 아이디와 비밀번호가 맞는지, 그리고 추가적인 보안 키까지 확인해서 이 사람이 진짜로 우리 서비스에 들어올 자격이 있는지 인증(Authentication) 검증
public class FormAuthenticationProvider implements AuthenticationProvider {

	private final UserDetailsService userDetailsService;
	private final PasswordEncoder    passwordEncoder;
	
	
	@Override
	public Authentication authenticate(Authentication authentication) throws AuthenticationException {
		String loginId = authentication.getName();
		String password = (String) authentication.getCredentials();
		
		AccountContext accountContext = (AccountContext) userDetailsService.loadUserByUsername(loginId);
		
        if(!passwordEncoder.matches(password, accountContext.getPassword())) {
        	throw new BadCredentialsException("Invalid Password");
        }
        
      
	    // 4. 추가 Secret Key 검증
        String secretKey = ((FormWebAuthenticationDetails) authentication.getDetails()).getSecretKey();
               
        if (secretKey == null || !secretKey.equals("secret")) {
            throw new SecretException("Invalid Secret");
        }
       
        
        // 5. 인증 성공 시 Authentication 객체 반환
        // 1) principal: 인증된 사용자 주체 (여기서는 accountContext.getAccountDto())
        // 2) credentials: 사용자의 자격 증명 (비밀번호 같은 거!)
        // 3) authorities: 사용자의 권한 (예: ROLE_USER, ROLE_ADMIN 등)
		return new UsernamePasswordAuthenticationToken(accountContext.getAccountDto(), null, accountContext.getAuthorities());
	}

	@Override
	public boolean supports(Class<?> authentication) {

		return authentication.isAssignableFrom(UsernamePasswordAuthenticationToken.class);
	}

}
