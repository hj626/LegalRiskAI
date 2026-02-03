package com.oracle.Legal.repository;

import java.time.LocalDateTime;

import org.springframework.stereotype.Repository;

import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class AdminDashboardRepositoryImpl implements AdminDashboardRepository {

    private final EntityManager em;

    @Override
    public long countWeekDispute(LocalDateTime start, LocalDateTime end) {
        Long cnt = em.createQuery(
                "select count(b) from Boonjang b " +
                "where b.boonjang_date >= :s and b.boonjang_date < :e",
                Long.class
        ).setParameter("s", start)
         .setParameter("e", end)
         .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countWeekRisk(LocalDateTime start, LocalDateTime end) {
        Long cnt = em.createQuery(
                "select count(l) from Law l " +
                "where l.law_date >= :s and l.law_date < :e",
                Long.class
        ).setParameter("s", start)
         .setParameter("e", end)
         .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countWeekSimilar(LocalDateTime start, LocalDateTime end) {
        Long cnt = em.createQuery(
                "select count(y) from Yusa y " +
                "where y.yusa_date >= :s and y.yusa_date < :e",
                Long.class
        ).setParameter("s", start)
         .setParameter("e", end)
         .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countWeekJogi(LocalDateTime start, LocalDateTime end) {
        Long cnt = em.createQuery(
                "select count(j) from Jogi j " +
                "where j.jogi_date >= :s and j.jogi_date < :e",
                Long.class
        ).setParameter("s", start)
         .setParameter("e", end)
         .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countTotalDispute() {
        Long cnt = em.createQuery("select count(b) from Boonjang b", Long.class)
                .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countTotalRisk() {
        Long cnt = em.createQuery("select count(l) from Law l", Long.class)
                .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countTotalSimilar() {
        Long cnt = em.createQuery("select count(y) from Yusa y", Long.class)
                .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countTotalJogi() {
        Long cnt = em.createQuery("select count(j) from Jogi j", Long.class)
                .getSingleResult();
        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countWeekNewUsers(LocalDateTime start, LocalDateTime end) {
        Long cnt = em.createQuery(
                "select count(c) from Client c " +
                "where c.client_is_del = 0 " +
                "and c.client_reg_date >= :s and c.client_reg_date < :e",
                Long.class
        )
        .setParameter("s", start)
        .setParameter("e", end)
        .getSingleResult();

        return cnt == null ? 0L : cnt;
    }

    @Override
    public long countTotalUsers() {
        Long cnt = em.createQuery(
                "select count(c) from Client c where c.client_is_del = 0",
                Long.class
        ).getSingleResult();
        return cnt == null ? 0L : cnt;
    }@Override
    public java.util.Map<String, Long> countUsersByJob() {

        java.util.List<Object[]> rows = em.createQuery(
                "select c.client_job, count(c) " +
                "from Client c " +
                "where c.client_is_del = 0 " +
                "group by c.client_job",
                Object[].class
        ).getResultList();

        java.util.Map<String, Long> map = new java.util.HashMap<>();

        for (Object[] r : rows) {
            String job = (String) r[0];
            Long cnt = (Long) r[1];

            if (job == null || job.trim().isEmpty()) job = "기타";

            map.put(job, cnt == null ? 0L : cnt);
        }

        map.putIfAbsent("학생", 0L);
        map.putIfAbsent("회사원", 0L);
        map.putIfAbsent("공무원", 0L);
        map.putIfAbsent("자영업자", 0L);
        map.putIfAbsent("프리랜서", 0L);
        map.putIfAbsent("전문직", 0L);
        map.putIfAbsent("군인", 0L);
        map.putIfAbsent("무직", 0L);
        map.putIfAbsent("기타", 0L);

        return map;
    }

}
