package com.oracle.Legal.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.oracle.Legal.dto.AccountDto;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class LoginController {
	

	/* private final FindPasswordService findPasswordService; */

	//로그인
	@GetMapping(value = "/login" )
	public String login(
			@RequestParam(value = "error" , required = false) String error,
			@RequestParam(value = "exception" , required = false ) String exception,
			Model model
			) 
	{
	       	model.addAttribute("error",error);
	        model.addAttribute("exception",exception);
	        
	        return "login/loginPage";
	}
	
	
	  //로그아웃
	  
	  @GetMapping(value = "/logout") public String logout(HttpServletRequest
	  request, HttpServletResponse response) { Authentication authentication =
	  SecurityContextHolder.getContextHolderStrategy() .getContext()
	  .getAuthentication(); if (authentication != null) { new
	  SecurityContextLogoutHandler().logout(request, response, authentication); }
	  
	  return "redirect:/login"; }
	 
    //로그인 정보가 틀렸을 경우
    @GetMapping(value="/denied")
    public String accessDenied(@RequestParam(value = "exception", required = false) String exception, 
    		                   @AuthenticationPrincipal AccountDto accountDto, 
    		                   Model model) {
        model.addAttribute("username", accountDto.getUsername());
        model.addAttribute("exception", exception);

        return "login/denied";
    }
    

    
}
