package com.oracle.Legal.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.oracle.Legal.domain.Law;
import com.oracle.Legal.domain.Yusa;
import com.oracle.Legal.repository.LawRepository;
import com.oracle.Legal.repository.YusaRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class YusaService {

    private final YusaRepository yusaRepository;

    @Transactional
    public int save(String yusaInput, int clientCode, String yusaOutput, int yusaMark) {
        Yusa yusa = new Yusa();
        yusa.setClient_code(clientCode);
        yusa.setYusa_input(yusaInput);
        yusa.setYusa_output(yusaOutput);
        yusa.setYusa_mark(yusaMark);
        return yusaRepository.yusaSave(yusa).getYusa_code();
    }
}