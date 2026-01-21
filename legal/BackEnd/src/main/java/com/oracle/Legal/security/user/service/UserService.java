package com.oracle.Legal.security.user.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.oracle.Legal.domain.Account;
import com.oracle.Legal.security.user.repository.UserRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;
	
	@Transactional
	public void createUser(Account account) {
		userRepository.save(account);
	}

	public Long totalAccount() {
        Long totalCount = userRepository.count();
		return totalCount;
	}

	@Transactional
	public void changePassword(String username, String currentPassword, String newPassword) {
	    Account account = userRepository.findByUsername(username);
	    if (account == null) {
	        throw new IllegalArgumentException("계정을 찾을 수 없습니다.");
	    }

	 
	    // 3. 새 비밀번호 암호화 후 저장
	    String encoded = passwordEncoder.encode(newPassword);
	    account.setPassword(encoded);
	    userRepository.save(account); 
	}

}