package com.oracle.Legal.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.oracle.Legal.domain.Law;
import com.oracle.Legal.repository.LawRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class LawService {

    private final LawRepository lawRepository;

    @Transactional
    public int save(String lawInput, int clientCode) {
        Law law = new Law();
        law.setClient_code(clientCode);
        law.setLaw_input(lawInput);
        return lawRepository.lawSave(law).getLaw_code();
    }
}
