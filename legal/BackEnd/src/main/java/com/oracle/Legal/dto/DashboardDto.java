package com.oracle.Legal.dto;

import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardDto {

    // 서비스 count
    private long weekDisputeCount;   
    private long weekRiskCount;      
    private long weekSimilarCount;   
    private long weekJogiCount;      

    // 누적 count
    private long totalDisputeCount;
    private long totalRiskCount;
    private long totalSimilarCount;
    private long totalJogiCount;

    // 회원 count
    private long weekNewUsers;
    private long totalUsers;
    
    //회원 직업 count
    private Map<String, Long> jobCounts;

}
