package com.oracle.Legal.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class HistoryPageDto {
    private List<HistoryDto> content;   
    private int totalCount;             
    private int page;                   
    private int size;                   
    private int totalPages;             
}