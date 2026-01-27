package com.oracle.Legal.service;

import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.oracle.Legal.domain.Account;
import com.oracle.Legal.domain.Client;
import com.oracle.Legal.repository.AccountRepository;
import com.oracle.Legal.repository.ClientRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FindPasswordService {

    private final ClientRepository clientRepository;
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    @Transactional
    public Result resetClientPasswordAndSend(String clientName, String clientEmail) {

        // Client 확인 
        Client client = clientRepository.findEntityByNameAndEmail(
                clientName == null ? "" : clientName.trim(),
                clientEmail == null ? "" : clientEmail.trim()
        );

        if (client == null || client.getClient_is_del() == 1) {
            return Result.fail("일치하는 정보가 없습니다.");
        }

        // Account 조회 
        Account account = accountRepository.findByClient_code(client.getClient_code());
        if (account == null) {
            return Result.fail("일치하는 정보가 없습니다.");
        }

        // 임시 비밀번호 생성,암호화해서 업데이트
        String tempPassword = generateTempPassword();
        account.setPassword(passwordEncoder.encode(tempPassword));
        accountRepository.update(account);

        try {
            String subject = "[LEGALAI] 임시 비밀번호 안내";
            String body =
                "안녕하세요, " + client.getClient_name() + "님.\n\n" +
                "요청하신 계정의 비밀번호가 임시 비밀번호로 초기화되었습니다.\n" +
                "임시 비밀번호: " + tempPassword + "\n\n" +
                "로그인 후 반드시 비밀번호를 변경해 주세요.\n" +
                "- 로그인 아이디: " + account.getUsername() + "\n";

            emailService.sendEmail(client.getClient_email(), subject, body);
            return Result.ok("임시 비밀번호를 이메일로 발송했습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.partial("비밀번호는 초기화되었으나 메일 발송에 실패했습니다.");
        }
    }

    private String generateTempPassword() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 10);
    }

    public record Result(boolean success, String message, boolean mailFailed) {
        public static Result ok(String msg)      { return new Result(true,  msg, false); }
        public static Result partial(String msg) { return new Result(true,  msg, true); }
        public static Result fail(String msg)    { return new Result(false, msg, false); }
    }

    //비밀번호 변경 
    @Transactional
    public void changePassword(int clientCode, String currentPassword, String newPassword) {

        Account account = accountRepository.findByClient_code(clientCode);
        if (account == null) {
            throw new IllegalArgumentException("계정을 찾을 수 없습니다.");
        }

        // 현재 비밀번호 검증
        if (!passwordEncoder.matches(currentPassword, account.getPassword())) {
            throw new IllegalArgumentException("현재 비밀번호가 올바르지 않습니다.");
        }

        // 새 비밀번호로 업데이트
        account.setPassword(passwordEncoder.encode(newPassword));
        accountRepository.update(account);
    }

}
