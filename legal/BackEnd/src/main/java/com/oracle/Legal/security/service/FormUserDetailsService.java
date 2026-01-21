package com.oracle.Legal.security.service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.modelmapper.ModelMapper;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.oracle.Legal.security.user.repository.UserRepository;
import com.oracle.Legal.domain.Account;
import com.oracle.Legal.dto.AccountContext;
import com.oracle.Legal.dto.AccountDto;

import lombok.RequiredArgsConstructor;

@Service("userDetailService") // 이름은 상관없지만 타입 주입이면 그대로 OK
@RequiredArgsConstructor
public class FormUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final ModelMapper modelMapper = new ModelMapper(); // (선호) Bean 주입으로 바꿔도 됩니다.

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1) 사용자 조회 + null 방어
        Account account = userRepository.findByUsername(username);
        if (account == null) {
            // ← 이 예외를 던져야 Spring Security가 "인증 실패"로 처리하고 500이 안 납니다.
            throw new UsernameNotFoundException("No user with username: " + username);
        }

        // 2) roles 안전 파싱 (비어있으면 ROLE_USER 기본값)
        String rolesStr = account.getRoles();
        if (rolesStr == null || rolesStr.isBlank()) {
            rolesStr = "ROLE_USER";
        }
        // 콤마로 여러 권한 저장했다면 분리 처리 (예: "ROLE_USER,ROLE_MANAGER")
        List<GrantedAuthority> authorities = Arrays.stream(rolesStr.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(SimpleGrantedAuthority::new) // 반드시 "ROLE_" 접두 포함
                .collect(Collectors.toList());

        // 3) UserDetails 변환
        AccountDto accountDto = modelMapper.map(account, AccountDto.class);
        return new AccountContext(accountDto, authorities);
    }
}
