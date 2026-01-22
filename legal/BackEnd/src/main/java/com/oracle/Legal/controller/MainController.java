package com.oracle.Legal.controller;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class MainController {
	
	//세션 확인용
	@GetMapping("/")
	public String mainPage(Model model, HttpSession session) {

	    System.out.println("==== SESSION CHECK (MAIN) ====");
	    System.out.println("session id = " + session.getId());

	    Integer clientCode = (Integer) session.getAttribute("client_code");
	    System.out.println("client_code = " + clientCode);

	    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
	    System.out.println("auth = " + auth);
	    System.out.println("principal = " + (auth != null ? auth.getPrincipal() : null));
	    System.out.println("=============================");

	    return "main";
	}

	
}