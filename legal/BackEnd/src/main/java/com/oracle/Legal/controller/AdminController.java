package com.oracle.Legal.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.oracle.Legal.dto.ClientDto;
import com.oracle.Legal.dto.PageDto;
import com.oracle.Legal.service.ClientService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin")
public class AdminController {
	
	
	private final ClientService clientService; 
	
    @GetMapping("/main")
    public String AdminClientPage(
            Model model,
            @RequestParam(name="page", defaultValue="1") int page,
            @RequestParam(name="size", defaultValue="10") int size
    ) {
        System.out.println("운영자 페이지 실행중");

        PageDto<ClientDto> result = clientService.getClientPage(page, size);

        model.addAttribute("clientList", result.getContent());
        model.addAttribute("totalCount", result.getTotalCount());
        model.addAttribute("page", result.getPage());
        model.addAttribute("size", result.getSize());
        model.addAttribute("totalPages", result.getTotalPages());

        return "admin/clientPage";
    }
}
