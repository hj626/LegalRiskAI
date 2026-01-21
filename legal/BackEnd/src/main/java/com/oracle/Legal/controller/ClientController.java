package com.oracle.Legal.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.oracle.Legal.dto.ClientDto;
import com.oracle.Legal.service.ClientService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/client")
@RequiredArgsConstructor
public class ClientController {

	private final ClientService clientService;
	
	//회원가입페이지 이동
	@GetMapping("/join")
	public String joinPage(Model model) {
	System.out.println("회원가입 페이지 실행중");
    return "login/joinPage";           
	}
	
	//비밀번호 찾기 페이지 이동
	@GetMapping("/findPassword")
	public String findPasswordPage(Model model) {
	System.out.println("비밀번호 찾기 페이지 실행중");
    return "login/findPassword";           
	}
	
	@PostMapping("/saveInform")
	public String saveInform (ClientDto clientDto) { 
	clientService.informSave(clientDto);
	System.out.println("회원가입 정보 전송");
    return "redirect:/login";          
	}
	
	
	
}
