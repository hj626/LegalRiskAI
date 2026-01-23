package com.oracle.Legal.controller;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.dto.LawDto;
import com.oracle.Legal.service.LawService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor		
@RequestMapping("/api/law")			
public class LawRestController {
	
	private final LawService lawService;		
	
    @PostMapping("/save")
    public int save(@RequestBody LawDto req,
                    @AuthenticationPrincipal AccountDto principal) {
    	
    	if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        int clientCode = principal.getClient_code();
        return lawService.save(req.getLaw_input(), clientCode, req.getLaw_output(), req.getLaw_mark());
    }
}
