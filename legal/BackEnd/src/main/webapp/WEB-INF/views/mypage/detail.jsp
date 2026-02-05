<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  :root{
    --bg: #f6f7fb;
    --card: #ffffff;
    --text: #0f172a;
    --muted: #64748b;
    --border: rgba(15, 23, 42, .08);
  }

  body { background: var(--bg); }

  .page-wrap{
    max-width: 980px;
    margin: 32px auto;
    padding: 0 16px;
    font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Noto Sans KR", Arial, sans-serif;
    color: var(--text);
  }

  .hero{
    border-radius: 18px;
    padding: 22px 22px;
    color: #fff;
    background: linear-gradient(135deg, #2563eb 0%, #7c3aed 55%, #0ea5e9 100%);
    box-shadow: 0 14px 30px rgba(2, 6, 23, .12);
    position: relative;
    overflow: hidden;
  }
  .hero:after{
    content:"";
    position:absolute; inset:-60px -80px auto auto;
    width: 240px; height: 240px;
    background: rgba(255,255,255,.18);
    border-radius: 999px;
    filter: blur(0px);
  }

  .hero-title{
    font-weight: 800;
    letter-spacing: -0.02em;
    margin: 0 0 10px 0;
    font-size: 20px;
  }
  .hero-meta{
    display:flex;
    gap:10px;
    flex-wrap:wrap;
    align-items:center;
    color: rgba(255,255,255,.92);
    font-size: 13px;
  }
  .pill{
    display:inline-flex;
    align-items:center;
    gap:8px;
    padding: 6px 10px;
    border-radius: 999px;
    background: rgba(255,255,255,.18);
    border: 1px solid rgba(255,255,255,.22);
    backdrop-filter: blur(6px);
  }

  .content-card{
    margin-top: 16px;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: 0 10px 22px rgba(2, 6, 23, .06);
    overflow: hidden;
  }

  .section{
    padding: 18px 18px;
  }

  .section-title{
    font-weight: 800;
    font-size: 14px;
    margin: 0 0 10px 0;
    color: #334155;
    display:flex;
    align-items:center;
    gap:10px;
  }

  .divider{
    height:1px;
    background: var(--border);
    margin: 0;
  }

  .paper{
    background: #f8fafc;
    border: 1px solid rgba(148,163,184,.35);
    border-radius: 14px;
    padding: 14px 14px;
    font-size: 13px;
    line-height: 1.65;
    white-space: pre-wrap;
    color: #0f172a;
  }

  .badge-soft{
    display:inline-flex;
    align-items:center;
    gap:8px;
    padding: 6px 10px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 700;
    background: rgba(37,99,235,.10);
    color: #1d4ed8;
    border: 1px solid rgba(37,99,235,.18);
  }

  .winrate{
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:12px;
    padding: 14px 16px;
    border-radius: 14px;
    border: 1px solid rgba(34,197,94,.25);
    background: rgba(34,197,94,.08);
  }
  .winrate .label{
    font-weight: 800;
    color:#14532d;
  }
  .winrate .value{
    font-weight: 900;
    font-size: 18px;
    color:#166534;
  }
</style>

<div class="page-wrap">

  <!-- 상단 헤더 -->
  <div class="hero">
    <div class="hero-title">
      <c:choose>
        <c:when test="${detail.serviceType eq 'LAW'}">법적리스크 서비스 상세</c:when>
        <c:when test="${detail.serviceType eq 'JOGI'}">승소율 측정 서비스 상세</c:when>
        <c:when test="${detail.serviceType eq 'YUSA'}">유사 판례 서비스 상세</c:when>
        <c:when test="${detail.serviceType eq 'BOONJANG'}">분쟁유형 서비스 상세</c:when>
        <c:otherwise>${detail.serviceType} 서비스 상세</c:otherwise>
      </c:choose>
    </div>

    <div class="hero-meta">
      <span class="pill">사건번호 <b>#${detail.serviceCode}</b></span>
      <span class="pill">
        <fmt:formatDate value="${detail.analysisDate}" pattern="yyyy-MM-dd HH:mm"/>
      </span>
      <span class="badge-soft">상세 리포트</span>
    </div>
  </div>

  <!-- 본문 카드 -->
  <div class="content-card">

    <div class="section">
      <div class="section-title">입력 내용</div>
      <pre class="paper">${detail.input}</pre>
    </div>

    <hr class="divider"/>

    <div class="section">
      <div class="section-title">AI 분석 결과</div>
      <pre class="paper">${detail.output}</pre>
    </div>

    <!-- JOGI일 때 승소율 -->
    <c:if test="${detail.serviceType eq 'JOGI'}">
      <hr class="divider"/>
      <div class="section">
        <div class="section-title">승소율</div>
        <div class="winrate">
          <div class="label">예상 승소율</div>
          <div class="value"><fmt:formatNumber value="${detail.jogiWinrate}" pattern="0"/>%</div>
        </div>
      </div>
    </c:if>

  </div>
</div>
