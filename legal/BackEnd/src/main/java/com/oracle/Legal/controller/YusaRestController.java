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
import com.oracle.Legal.dto.YusaDto;
import com.oracle.Legal.service.LawService;
import com.oracle.Legal.service.YusaService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor		
@RequestMapping("/api/yusa")			
public class YusaRestController {
	
	private final YusaService yusaService;		
	
    @PostMapping("/save")
    public int save(@RequestBody YusaDto req,
                    @AuthenticationPrincipal AccountDto principal) {
    	
    	if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        int clientCode = principal.getClient_code();
        return yusaService.save(req.getYusa_input(), clientCode, req.getYusa_mark());
    }
}
