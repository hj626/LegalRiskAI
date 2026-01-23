package com.oracle.Legal.controller;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.oracle.Legal.dto.AccountDto;
import com.oracle.Legal.dto.JogiDto;
import com.oracle.Legal.service.JogiService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/jogi")
public class JogiController {
	private final JogiService jogiService;		
	
    @PostMapping("/save")
    public int save(@RequestBody JogiDto req,
                    @AuthenticationPrincipal AccountDto principal) {
    	
    	if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        int clientCode = principal.getClient_code();
        return jogiService.save(req.getJogi_input(), clientCode, req.getJogi_output(), req.getJogi_winrate(), req.getJogi_mark());
    }
}
