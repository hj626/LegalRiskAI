package com.oracle.Legal.controller;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.dto.ClientDto;
import com.oracle.Legal.service.ClientService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class MainController {
	
	    private final ClientService clientService;

	
	 // 세션 확인용
	    @GetMapping("/")
	    public String mainPage(Model model, HttpSession session) {

	        Integer clientCode = (Integer) session.getAttribute("client_code");

	        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

	        if (auth != null && auth.isAuthenticated()
	                && auth.getPrincipal() instanceof AccountDto) {

	            AccountDto account = (AccountDto) auth.getPrincipal();

	            // client_code = null일때
	            if (clientCode == null) {
	                clientCode = account.getClient_code();   
	                if (clientCode != null) {
	                    session.setAttribute("client_code", clientCode);
	                }
	            }

	            // 비정상 로그인 상태 
	            if (clientCode != null) {
	                ClientDto user = clientService.getSingleClient(clientCode);
	                model.addAttribute("user", user);
	            }
	        }

	        return "main";
	    }


	
}