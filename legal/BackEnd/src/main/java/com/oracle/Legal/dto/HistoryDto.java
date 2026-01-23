package com.oracle.Legal.dto;

import java.util.Date;
import lombok.*;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HistoryDto {
    private String serviceType;   
    private Long serviceCode;     
    private Date analysisDate;    
    private String input;         
    private String output;        
    private int mark;
}