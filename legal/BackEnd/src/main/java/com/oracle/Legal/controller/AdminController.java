package com.oracle.Legal.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.oracle.Legal.dto.ClientDto;
import com.oracle.Legal.dto.PageDto;
import com.oracle.Legal.repository.BoonjangRepository;
import com.oracle.Legal.repository.JogiRepository;
import com.oracle.Legal.repository.LawRepository;
import com.oracle.Legal.repository.YusaRepository;
import com.oracle.Legal.service.ClientService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin")
public class AdminController {
	
	
	private final ClientService clientService; 
    private final LawRepository lawRepository;
    private final YusaRepository yusaRepository;
    private final JogiRepository jogiRepository;
    private final BoonjangRepository boonjangRepository;
	
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
    
    @GetMapping("/client/{clientCode}")
    public String clientDetail(@PathVariable("clientCode") int clientCode, Model model) {

        ClientDto client = clientService.getSingleClient(clientCode);
        model.addAttribute("client", client);

        long cntLaw      = lawRepository.countByClientCode(clientCode);      
        long cntYusa     = yusaRepository.countByClientCode(clientCode);     
        long cntJogi     = jogiRepository.countByClientCode(clientCode);     
        long cntBoonjang = boonjangRepository.countByClientCode(clientCode); 

        long totalUsage = cntLaw + cntYusa + cntJogi + cntBoonjang;

        model.addAttribute("cntLaw", cntLaw);
        model.addAttribute("cntYusa", cntYusa);
        model.addAttribute("cntJogi", cntJogi);
        model.addAttribute("cntBoonjang", cntBoonjang);
        model.addAttribute("totalUsage", totalUsage);

        System.out.println("상세보기페이지 실행");
        return "admin/clientDetail";
    }

    @PostMapping("/client/{clientCode}/status")
    public String updateClientStatus(
            @PathVariable("clientCode") int clientCode,
            @RequestParam("client_is_del") int clientIsDel,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size
    ) {
        clientService.updateClientIsDel(clientCode, clientIsDel);
        System.out.println("상태수정완료 ");
        return "redirect:/admin/main?page=" + page + "&size=" + size;
    }
}
