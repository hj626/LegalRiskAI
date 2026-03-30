package com.oracle.Legal.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationDetailsSource;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;

import com.oracle.Legal.security.handler.FormAccessDeniedHandler;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

@EnableWebSecurity
@EnableMethodSecurity(securedEnabled = true)
@Configuration
@RequiredArgsConstructor
public class SecurityConfig {
	private final AuthenticationProvider	authenticationProvider;
	private final AuthenticationDetailsSource<HttpServletRequest, WebAuthenticationDetails> 
	                     authenticationDetailsSource;
	private final AuthenticationSuccessHandler successHandler;
	private final AuthenticationFailureHandler failureHandler;
	private final UserDetailsService userDetailsService;

	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

		// CSRF 활성화 - React(SPA) 호환을 위한 Cookie 저장소 사용
		http.csrf(csrf -> csrf
				.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
				.csrfTokenRequestHandler(new CsrfTokenRequestAttributeHandler())
				.ignoringRequestMatchers("/analyze/**", "/health", "/client/**") // API 엔드포인트 중 필요한 것만 예외 처리
		);

		http
			// 인가 설정
        	.authorizeHttpRequests(auth->auth
                    .requestMatchers( "/css/**", "/images/**", "/image/**", "/js/**", "/favicon.*", "/*/icon-*"
                    	         	, "/WEB-INF/views/**").permitAll()
                    .requestMatchers("/", "/login", "/error**", "/assets/**").permitAll()
                    .requestMatchers("/client/**").permitAll()
                    .requestMatchers("/admin/**").hasAnyAuthority("ROLE_ADMIN")
                    .anyRequest().authenticated()
			)
			
        	.formLogin(form -> form
        		    .loginPage("/login").permitAll()
        		    .loginProcessingUrl("/login")
        		    .authenticationDetailsSource(authenticationDetailsSource)
        		    .successHandler(successHandler)
        		    .failureHandler(failureHandler)
        		    .permitAll()
        		)

            .authenticationProvider(authenticationProvider)
            .exceptionHandling(
          		   exception -> exception
                                       .accessDeniedHandler(new FormAccessDeniedHandler("/denied"))
                               )
              ;

		return http.build();
	}
}
