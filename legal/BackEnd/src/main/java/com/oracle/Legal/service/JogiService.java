package com.oracle.Legal.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.oracle.Legal.domain.Jogi;
import com.oracle.Legal.repository.JogiRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class JogiService {

    private final JogiRepository jogiRepository;

    @Transactional
    public int save(String jogiInput, int clientCode, int jogiWinrate) {
        Jogi jogi = new Jogi();
        jogi.setClient_code(clientCode);
        jogi.setJogi_input(jogiInput);
        jogi.setJogi_winrate(jogiWinrate);
        return jogiRepository.jogiSave(jogi).getJogi_code();
    }
}
