package com.oracle.Legal.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.service.FindPasswordService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class LoginController {
	

	private final FindPasswordService findPasswordService; 

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

 // 비밀번호 찾기 페이지
    @GetMapping("/client/findPassword")
    public String findPasswordPage() {
        return "login/findPassword";   
    }

    //비밀번호 찾기 요청 
    @PostMapping("/client/findPassword/request")
    public String requestFindPassword(
            @RequestParam("client_name") String clientName,
            @RequestParam("client_email") String clientEmail,
            RedirectAttributes ra) {

        FindPasswordService.Result result =
                findPasswordService.resetClientPasswordAndSend(clientName, clientEmail);

        if (result.success()) ra.addFlashAttribute("msg", result.message());
        else                  ra.addFlashAttribute("err", result.message());

        return "redirect:/client/findPassword";
    }
    
    //비밀번호 변경
    @PostMapping("/mypage/password/change")
    public String changePassword(
            @AuthenticationPrincipal AccountDto accountDto,
            @RequestParam("currentPassword") String currentPassword,
            @RequestParam("newPassword") String newPassword,
            @RequestParam("confirmPassword") String confirmPassword,
            RedirectAttributes ra) {

        if (!newPassword.equals(confirmPassword)) {
            ra.addFlashAttribute("pwErr", "새 비밀번호가 확인과 일치하지 않습니다.");
            return "redirect:/mypage/user";
        }

        try {
            findPasswordService.changePassword(
                    accountDto.getClient_code(),
                    currentPassword,
                    newPassword
            );
            ra.addFlashAttribute("pwMsg", "비밀번호가 변경되었습니다. 다시 로그인해주세요.");
            return "redirect:/logout";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("pwErr", e.getMessage());
            return "redirect:/mypage/user";
        }
    }
    
}
