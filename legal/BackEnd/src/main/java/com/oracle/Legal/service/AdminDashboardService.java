package com.oracle.Legal.service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.oracle.Legal.dto.DashboardDto;
import com.oracle.Legal.repository.AdminDashboardRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final AdminDashboardRepository repo;

    @Transactional(readOnly = true)
    public DashboardDto getDashboard() {

        LocalDate today = LocalDate.now();
        LocalDate weekStartDate =
                today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        LocalDateTime start = weekStartDate.atStartOfDay();
        LocalDateTime end   = start.plusDays(7);

        DashboardDto dto = new DashboardDto();

        // 이번 주
        dto.setWeekDisputeCount(repo.countWeekDispute(start, end));
        dto.setWeekRiskCount(repo.countWeekRisk(start, end));
        dto.setWeekSimilarCount(repo.countWeekSimilar(start, end));
        dto.setWeekJogiCount(repo.countWeekJogi(start, end));

        // 누적
        dto.setTotalDisputeCount(repo.countTotalDispute());
        dto.setTotalRiskCount(repo.countTotalRisk());
        dto.setTotalSimilarCount(repo.countTotalSimilar());
        dto.setTotalJogiCount(repo.countTotalJogi());

        // 회원
        dto.setWeekNewUsers(repo.countWeekNewUsers(start, end));
        dto.setTotalUsers(repo.countTotalUsers());        
        dto.setJobCounts(repo.countUsersByJob());

        return dto;
    }
}
