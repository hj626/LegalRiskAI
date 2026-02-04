package com.oracle.Legal.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.dto.ClientDto;
import com.oracle.Legal.dto.DashboardDto;
import com.oracle.Legal.repository.BoonjangRepository;
import com.oracle.Legal.repository.JogiRepository;
import com.oracle.Legal.repository.LawRepository;
import com.oracle.Legal.repository.YusaRepository;
import com.oracle.Legal.service.AdminDashboardService;
import com.oracle.Legal.service.ClientService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class MainController {

    private final ClientService clientService;
    private final LawRepository lawRepository;
    private final YusaRepository yusaRepository;
    private final JogiRepository jogiRepository;
    private final BoonjangRepository boonjangRepository;
    private final AdminDashboardService adminDashboardService;

    @GetMapping("/")
    public String mainPage(Model model, HttpSession session) {

        Integer clientCode = (Integer) session.getAttribute("client_code");

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated()
                && auth.getPrincipal() instanceof AccountDto) {

            AccountDto account = (AccountDto) auth.getPrincipal();

            // client_code = null일때 세션에 채우기
            if (clientCode == null) {
                clientCode = account.getClient_code();
                if (clientCode != null) {
                    session.setAttribute("client_code", clientCode);
                }
            }

            if (clientCode != null) {
                ClientDto user = clientService.getSingleClient(clientCode);
                
                long cntLaw      = lawRepository.countByClientCode(clientCode);
                long cntYusa     = yusaRepository.countByClientCode(clientCode);
                long cntJogi     = jogiRepository.countByClientCode(clientCode);
                long cntBoonjang = boonjangRepository.countByClientCode(clientCode);

                model.addAttribute("cntLaw", cntLaw);
                model.addAttribute("cntYusa", cntYusa);
                model.addAttribute("cntJogi", cntJogi);
                model.addAttribute("cntBoonjang", cntBoonjang);
                model.addAttribute("user", user);
                model.addAttribute("favorites", clientService.getFavorites(clientCode));
                
                
                
            }

            boolean isAdmin = auth.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

            if (isAdmin) {
                DashboardDto dashboard = adminDashboardService.getDashboard();
                model.addAttribute("dashboard", dashboard);
            }
        }

        return "main";
    }
    
    @PostMapping("/mypage/history/detail")
    public String goDetail(@RequestParam String serviceType,
                           @RequestParam Long serviceCode) {
        return "redirect:/history/" + serviceType + "/" + serviceCode;
    }

}
