package com.oracle.Legal.security.service;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.dto.ClientDto;
import com.oracle.Legal.service.ClientService;

import lombok.RequiredArgsConstructor;

@ControllerAdvice
@RequiredArgsConstructor
public class CurrentUserViewAdvice {

    private final ClientService clientService;

    @ModelAttribute("displayName")
    public String displayName(@AuthenticationPrincipal AccountDto p) {
        if (p == null) return null;

        // 회원정보 가져오기 
        if (p.getClient_code() != 0) {
            ClientDto client = clientService.getSingleClient(p.getClient_code());
            return (client != null && client.getClient_name() != null && !client.getClient_name().isBlank())
                    ? client.getClient_name()
                    : p.getUsername();
        }

        return p.getUsername();
    }
}
