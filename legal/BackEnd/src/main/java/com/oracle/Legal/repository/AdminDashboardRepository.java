package com.oracle.Legal.repository;

import java.time.LocalDateTime;

public interface AdminDashboardRepository {

    // 이번주
    long countWeekDispute(LocalDateTime start, LocalDateTime end);
    long countWeekRisk(LocalDateTime start, LocalDateTime end);
    long countWeekSimilar(LocalDateTime start, LocalDateTime end);
    long countWeekJogi(LocalDateTime start, LocalDateTime end);

    // 누적
    long countTotalDispute();
    long countTotalRisk();
    long countTotalSimilar();
    long countTotalJogi();

    // 회원
    long countWeekNewUsers(LocalDateTime start, LocalDateTime end);
    long countTotalUsers();
    java.util.Map<String, Long> countUsersByJob();

}
