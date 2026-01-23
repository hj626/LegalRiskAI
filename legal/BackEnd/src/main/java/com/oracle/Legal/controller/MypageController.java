package com.oracle.Legal.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/mypage")
@RequiredArgsConstructor
public class MypageController {
	
	//회원가입페이지 이동
		@GetMapping("/main")
		public String myPage(Model model) {
		System.out.println("마이페이지 진입");
	    return "mypage/main";           
		}
		

}
