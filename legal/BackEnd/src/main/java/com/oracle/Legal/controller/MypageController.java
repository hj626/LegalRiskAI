package com.oracle.Legal.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.dto.HistoryPageDto;
import com.oracle.Legal.service.MyPageService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/mypage")
@RequiredArgsConstructor
public class MypageController {
	
	//회원가입페이지 이동
    private final MyPageService myPageService;

    // ✅ /mypage → /mypage/main 으로 보내기
    @GetMapping("")
    public String mypageRootRedirect(
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "size", defaultValue = "10") int size
    ) {
        return "redirect:/mypage/main?page=" + page + "&size=" + size;
    }

    // ✅ 실제 마이페이지
    @GetMapping("/main")
    public String mypageMain(
            Model model,
            @RequestParam(name="page", defaultValue="1") int page,
            @RequestParam(name="size", defaultValue="10") int size
    ) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        AccountDto user = (AccountDto) auth.getPrincipal();
        int client_code = user.getClient_code();

        HistoryPageDto result =
                myPageService.getHistoryPage(client_code, page, size);

        model.addAttribute("historyList", result.getContent());
        model.addAttribute("totalCount", result.getTotalCount());
        model.addAttribute("page", result.getPage());
        model.addAttribute("size", result.getSize());
        model.addAttribute("totalPages", result.getTotalPages());

        return "mypage/main";
    }
		
	//회원정보 조회,수정 페이지 이동
		@GetMapping("/user")
		public String userPage(Model model) {
		System.out.println("회원정보 페이지 진입");
	    return "mypage/user";           
		}
	

		

}
