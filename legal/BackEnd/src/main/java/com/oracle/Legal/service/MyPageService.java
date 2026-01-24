package com.oracle.Legal.service;

import java.util.*;
import org.springframework.stereotype.Service;
import com.oracle.Legal.dto.HistoryDto;
import com.oracle.Legal.dto.HistoryPageDto;
import com.oracle.Legal.repository.*;

import lombok.RequiredArgsConstructor;
@Service
@RequiredArgsConstructor
public class MyPageService {

    private final LawRepository2 lawRepository2;
    private final YusaRepository2 yusaRepository2;
    private final JogiRepository2 jogiRepository2;

    public List<HistoryDto> getAllHistory(int client_code) {

        List<HistoryDto> list = new ArrayList<>();

        // LAW
        lawRepository2.findHistory(client_code).forEach(l -> {
            list.add(HistoryDto.builder()
                .serviceType("LAW")
                .serviceCode((long) l.getLaw_code())
                .analysisDate(java.sql.Timestamp.valueOf(l.getLaw_date()))
                .input(l.getLaw_input())
                .output(l.getLaw_output())
                .mark(l.getLaw_mark())
                .build());
        });

        // YUSA
        yusaRepository2.findHistory(client_code).forEach(y -> {
            list.add(HistoryDto.builder()
                .serviceType("YUSA")
                .serviceCode((long) y.getYusa_code())
                .analysisDate(java.sql.Timestamp.valueOf(y.getYusa_date())) 
                .input(y.getYusa_input())
                .output(y.getYusa_output())
                .mark(y.getYusa_mark())
                .build());
        });

        // JOGI
        jogiRepository2.findHistory(client_code).forEach(j -> {
            list.add(HistoryDto.builder()
                .serviceType("JOGI")
                .serviceCode((long) j.getJogi_code())
                .analysisDate(java.sql.Timestamp.valueOf(j.getJogi_date())) 
                .input(j.getJogi_input())
                .output(j.getJogi_output())
                .mark(j.getJogi_mark())
                .build());
        });

        list.sort((a, b) -> b.getAnalysisDate().compareTo(a.getAnalysisDate())); return list;
    }
    
    //페이징
    public HistoryPageDto getHistoryPage(int client_code, int page, int size) {
        // 1) 전체 목록 만들기(지금 작성하신 getAllHistory 재사용)
        List<HistoryDto> all = getAllHistory(client_code);

        int totalCount = all.size();
        int totalPages = (int) Math.ceil((double) totalCount / size);

        // page 보정(1~totalPages)
        if (page < 1) page = 1;
        if (totalPages > 0 && page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * size;
        int toIndex = Math.min(fromIndex + size, totalCount);

        List<HistoryDto> content =
                (totalCount == 0) ? java.util.Collections.emptyList()
                                  : all.subList(fromIndex, toIndex);

        return new HistoryPageDto(content, totalCount, page, size, totalPages);
    }
}
