<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="com.oracle.Legal.dto.AccountDto" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
  String ctx = request.getContextPath();
  Authentication auth = SecurityContextHolder.getContext().getAuthentication();
  String displayName = "운영자";

  if (auth != null && auth.getPrincipal() instanceof AccountDto) {
    AccountDto u = (AccountDto) auth.getPrincipal();
    if (u.getClient_name() != null && !u.getClient_name().isBlank())
      displayName = u.getClient_name();
    else if (u.getUsername() != null)
      displayName = u.getUsername();
  }
%>

<c:set var="wDispute" value="${empty dashboard ? 0 : dashboard.weekDisputeCount}" />
<c:set var="wRisk"    value="${empty dashboard ? 0 : dashboard.weekRiskCount}" />
<c:set var="wSimilar" value="${empty dashboard ? 0 : dashboard.weekSimilarCount}" />
<c:set var="wJogi"    value="${empty dashboard ? 0 : dashboard.weekJogiCount}" />
<c:set var="wTotal"   value="${wDispute + wRisk + wSimilar + wJogi}" />

<c:set var="tDispute" value="${empty dashboard ? 0 : dashboard.totalDisputeCount}" />
<c:set var="tRisk"    value="${empty dashboard ? 0 : dashboard.totalRiskCount}" />
<c:set var="tSimilar" value="${empty dashboard ? 0 : dashboard.totalSimilarCount}" />
<c:set var="tJogi"    value="${empty dashboard ? 0 : dashboard.totalJogiCount}" />
<c:set var="tTotal"   value="${tDispute + tRisk + tSimilar + tJogi}" />

<c:set var="weekNewUsers" value="${empty dashboard ? 0 : dashboard.weekNewUsers}" />
<c:set var="totalUsers"   value="${empty dashboard ? 0 : dashboard.totalUsers}" />

<style>
  body{ background:#f6f7fb; }

  .dash-card{
    background:#fff;
    border:1px solid rgba(0,0,0,.06);
    border-radius:18px;
    box-shadow:0 8px 22px rgba(15,23,42,.06);
  }
  .dash-card .card-body{ padding:22px; }

  .icon-pill{
    width:38px;height:38px;
    display:inline-flex;align-items:center;justify-content:center;
    border-radius:12px;
    background:#eef4ff;color:#2563eb;
  }
  .icon-pill.green{ background:rgba(16,185,129,.12); color:#10b981; }
  .icon-pill.indigo{ background:rgba(79,70,229,.12); color:#4f46e5; }
  .icon-pill.gray{ background:rgba(100,116,139,.12); color:#64748b; }

  .big-number{ font-size:2rem;font-weight:800; }
  .mini{ font-size:.85rem;color:rgba(0,0,0,.55); }

  .action-card{
    background:#fff;
    border:1px solid rgba(0,0,0,.06);
    border-radius:18px;
    box-shadow:0 8px 22px rgba(15,23,42,.06);
    padding:22px;
    height:100%;
  }

  /* 도넛 높이 */
  .donut-wrap{ height:170px; }
</style>

<div class="container py-4 py-md-5">

  <div class="mb-4">
    <h1 class="fw-bold mb-1"><%= displayName %> 대시보드</h1>
    <div class="mini">서비스 운영 현황을 한눈에 파악하세요.</div>
  </div>

  <!-- 상단 4칸 -->
  <div class="row g-3 g-md-4">

    <!-- ✅ 주간 서비스 사용량 (도넛 + 숫자표시) -->
    <div class="col-lg-3">
      <div class="dash-card h-100">
        <div class="card-body">
          <div class="d-flex gap-2 mb-2">
            <div class="icon-pill">📊</div>
            <div>
              <div class="fw-bold">주간 총 사용량</div>
              <div class="mini">서비스별 주간 이용</div>
            </div>
          </div>

          <div class="donut-wrap">
            <canvas id="weekUsageDonut"></canvas>
          </div>

          <!-- ✅ 도넛 아래 숫자(항목별 건수) -->
          <div class="small mt-2">
            <div class="d-flex justify-content-between"><span>분쟁유형</span><span>${wDispute}건</span></div>
            <div class="d-flex justify-content-between"><span>법적리스크</span><span>${wRisk}건</span></div>
            <div class="d-flex justify-content-between"><span>유사판례</span><span>${wSimilar}건</span></div>
            <div class="d-flex justify-content-between"><span>해결전략</span><span>${wJogi}건</span></div>
          </div>

          <hr class="my-2">

          <div class="d-flex justify-content-between">
            <span class="mini">합계</span>
            <strong><fmt:formatNumber value="${wTotal}" />건</strong>
          </div>
        </div>
      </div>
    </div>

    <!-- 누적 -->
    <div class="col-lg-3">
      <div class="dash-card h-100">
        <div class="card-body">
          <div class="d-flex gap-2 mb-2">
            <div class="icon-pill indigo">📈</div>
            <div>
              <div class="fw-bold">누적 총 사용량</div>
              <div class="mini">전체 누적</div>
            </div>
          </div>

          <div class="big-number mb-3"><fmt:formatNumber value="${tTotal}" />건</div>

          <table class="table table-sm mb-0">
            <tbody>
              <tr><td>분쟁유형</td><td class="text-end">${tDispute}건</td></tr>
              <tr><td>법적리스크</td><td class="text-end">${tRisk}건</td></tr>
              <tr><td>유사판례</td><td class="text-end">${tSimilar}건</td></tr>
              <tr><td>해결전략</td><td class="text-end">${tJogi}건</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- 주간 신규 -->
    <div class="col-lg-3">
      <div class="dash-card h-100">
        <div class="card-body">
          <div class="d-flex gap-2 mb-2">
            <div class="icon-pill green">👤</div>
            <div>
              <div class="fw-bold">주간 신규 가입</div>
              <div class="mini">이번 주</div>
            </div>
          </div>

          <div class="big-number"><fmt:formatNumber value="${weekNewUsers}" />명</div>

          <div class="mini mt-3 d-flex justify-content-between">
            <span>총 회원</span>
            <strong><fmt:formatNumber value="${totalUsers}" />명</strong>
          </div>
        </div>
      </div>
    </div>

    <!-- ✅ 직업별 회원 수 (원래대로 테이블) -->
    <div class="col-lg-3">
      <div class="dash-card h-100">
        <div class="card-body">
          <div class="d-flex gap-2 mb-2">
            <div class="icon-pill gray">👥</div>
            <div>
              <div class="fw-bold">직업별 회원 수</div>
              <div class="mini">전체</div>
            </div>
          </div>

          <table class="table table-sm mb-0">
            <tbody>
              <tr><td>학생</td><td class="text-end">${empty dashboard.jobCounts['학생'] ? 0 : dashboard.jobCounts['학생']}명</td></tr>
              <tr><td>회사원</td><td class="text-end">${empty dashboard.jobCounts['회사원'] ? 0 : dashboard.jobCounts['회사원']}명</td></tr>
              <tr><td>공무원</td><td class="text-end">${empty dashboard.jobCounts['공무원'] ? 0 : dashboard.jobCounts['공무원']}명</td></tr>
              <tr><td>자영업자</td><td class="text-end">${empty dashboard.jobCounts['자영업자'] ? 0 : dashboard.jobCounts['자영업자']}명</td></tr>
              <tr><td>프리랜서</td><td class="text-end">${empty dashboard.jobCounts['프리랜서'] ? 0 : dashboard.jobCounts['프리랜서']}명</td></tr>
              <tr><td>전문직</td><td class="text-end">${empty dashboard.jobCounts['전문직'] ? 0 : dashboard.jobCounts['전문직']}명</td></tr>
              <tr><td>군인</td><td class="text-end">${empty dashboard.jobCounts['군인'] ? 0 : dashboard.jobCounts['군인']}명</td></tr>
              <tr><td>무직</td><td class="text-end">${empty dashboard.jobCounts['무직'] ? 0 : dashboard.jobCounts['무직']}명</td></tr>
              <tr><td>기타</td><td class="text-end">${empty dashboard.jobCounts['기타'] ? 0 : dashboard.jobCounts['기타']}명</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

  </div>

  <!-- 하단 액션 -->
  <div class="row g-3 g-md-4 mt-4">
    <div class="col-lg-6">
      <div class="action-card">
        <h5 class="fw-bold">운영자 페이지</h5>
        <p class="mini">관리/운영</p>
        <a class="btn btn-primary w-100" href="<%= ctx %>/admin/main">열기</a>
      </div>
    </div>

    <div class="col-lg-6">
      <div class="action-card">
        <h5 class="fw-bold">기능 확인</h5>
        <p class="mini">기능 테스트</p>
        <a class="btn btn-outline-primary w-100" href="<%= ctx %>/ai-analysis">열기</a>
      </div>
    </div>
  </div>

</div>

<!-- ✅ Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

<script>
(function () {
  // 주간 총 사용량 도넛
  const labels = ["분쟁유형", "법적리스크", "유사판례", "해결전략"];
  const values = [${wDispute}, ${wRisk}, ${wSimilar}, ${wJogi}];
  const total = values.reduce((a,b)=>a+b,0);

  const el = document.getElementById("weekUsageDonut");
  if (!el) return;

  const dataLabels = total === 0 ? ["데이터 없음"] : labels;
  const dataValues = total === 0 ? [1] : values;

  new Chart(el, {
    type: "doughnut",
    data: {
      labels: dataLabels,
      datasets: [{ data: dataValues }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: "70%",
      interaction: { mode: "nearest", intersect: true },
      plugins: {
        legend: { display: false },
        tooltip: {
          enabled: true,
          callbacks: {
            label: function (ctx) {
              if (total === 0) return "데이터 없음";
              const v = Number(ctx.raw || 0);
              const pct = total ? ((v / total) * 100).toFixed(1) : "0.0";
              return ctx.label + ": " + v + "건 (" + pct + "%)";
            }
          }
        }
      }
    }
  });
})();
</script>
