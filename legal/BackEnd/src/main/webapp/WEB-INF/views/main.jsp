<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="com.oracle.Legal.dto.AccountDto" %>
<%@ page import="org.springframework.security.web.csrf.CsrfToken" %>
<%@ page import="java.time.Year" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>LEGALAI - 메인</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
  body { background: #f6f7fb; }

  .glass {
    background: rgba(255,255,255,.9);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(15, 23, 42, .06);
    border-radius: 18px;
    box-shadow: 0 12px 34px rgba(0,0,0,.06);
  }

  .feature-card {
    border: 0;
    border-radius: 18px;
    box-shadow: 0 12px 26px rgba(0,0,0,.06);
    transition: transform .12s ease, box-shadow .12s ease;
  }
  .feature-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 18px 36px rgba(0,0,0,.10);
  }

  .icon-badge {
    width: 44px; height: 44px;
    border-radius: 14px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    background: #f1f5ff;
  }

  /* ===== React Header Style (JSP) ===== */
  .header {
    background: #fff;
    border-bottom: 1px solid #e5e7eb;
  }
  .header-inner {
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 24px;
    height: 64px;
    display: flex;
    align-items: center;
    gap: 32px;
  }
  .logo {
    display: flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
  }
  .logo-icon {
    width: 36px;
    height: 36px;
    border-radius: 16px;
    background: #2563eb;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    box-shadow: 0 4px 10px rgba(0,0,0,.15);
  }
  .logo-text {
    font-size: 20px;
    font-weight: 700;
    color: #111827;
  }
  .logo-text span { color: #2563eb; }

  .nav {
    flex: 1;
    display: flex;
    gap: 8px;
    overflow-x: auto;
    scrollbar-width: none;
  }
  .nav::-webkit-scrollbar { display:none; }
  .nav a {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 14px;
    border-radius: 14px;
    font-size: 15px;
    color: #4b5563;
    text-decoration: none;
    transition: all .15s ease;
    white-space: nowrap;
  }
  .nav a:hover {
    background: #f3f4f6;
    color: #111827;
  }
  .nav a.active {
    background: #eff6ff;
    color: #1d4ed8;
    font-weight: 600;
  }

  .header-user {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .header-user .hello {
    color: #374151;
    font-weight: 600;
    padding: 0 6px;
    white-space: nowrap;
  }
  .header-user a {
    font-size: 14px;
    text-decoration: none;
    padding: 6px 10px;
    border-radius: 10px;
    color: #4b5563;
    transition: all .15s ease;
  }
  .header-user a:hover {
    background: #f3f4f6;
    color: #111827;
  }
  .btn-join {
    background:#2563eb !important;
    color:#fff !important;
    padding:8px 14px !important;
    border-radius:14px !important;
    font-weight: 600;
    box-shadow: 0 6px 14px rgba(37,99,235,.22);
  }
  .btn-join:hover { filter: brightness(.95); }

  .logout-btn {
    border: 0;
    background: transparent;
    font-size: 14px;
    padding: 6px 10px;
    border-radius: 10px;
    color: #4b5563;
    transition: all .15s ease;
  }
  .logout-btn:hover {
    background: #fee2e2;
    color: #dc2626;
  }

  /* ===== React Footer Style (JSP) ===== */
  .footer {
    background: #ffffff;
    border-top: 1px solid #e5e7eb;
    margin-top: 80px;
  }
  .footer-inner {
    max-width: 1280px;
    margin: 0 auto;
    padding: 32px 24px;
  }
  .footer-top {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    align-items: center;
    justify-content: space-between;
  }
  .footer-logo {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #4b5563;
  }
  .footer-nav {
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
    font-size: 14px;
  }
  .footer-nav a {
    color: #6b7280;
    text-decoration: none;
    transition: color .15s ease;
  }
  .footer-nav a:hover {
    color: #111827;
  }
  .footer-right {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    font-size: 14px;
    color: #6b7280;
    align-items: center;
  }
  .footer-right a {
    display: inline-flex;
    gap: 6px;
    align-items: center;
    color: inherit;
    text-decoration: none;
  }
  .footer-right a:hover {
    color: #111827;
  }
  .footer-bottom {
    margin-top: 24px;
    padding-top: 24px;
    border-top: 1px solid #f3f4f6;
    text-align: center;
    font-size: 12px;
    color: #9ca3af;
  }
</style>
</head>

<body>
<%
  // ===== Auth =====
  Authentication auth = SecurityContextHolder.getContext().getAuthentication();

  AccountDto loginUser = null;
  boolean loggedIn = false;

  if (auth != null && auth.getPrincipal() instanceof AccountDto) {
      loginUser = (AccountDto) auth.getPrincipal();
      loggedIn = true;
  }

  // ===== Paths =====
  String ctx = request.getContextPath();
  String uri = request.getRequestURI();   // ex) /legal/law
  String path = uri;

  // contextPath 제거한 path 비교용 (ex: /law)
  if (ctx != null && !ctx.isBlank() && uri.startsWith(ctx)) {
      path = uri.substring(ctx.length());
  }

  // ===== CSRF =====
  CsrfToken csrf = (CsrfToken) request.getAttribute("_csrf");

  // ===== active =====
  String activeBoonjang = path.startsWith("/boonjang") ? "active" : "";
  String activeLaw      = path.startsWith("/law")      ? "active" : "";
  String activeYusa     = path.startsWith("/yusa")     ? "active" : "";
  String activeJogi     = path.startsWith("/jogi")     ? "active" : "";

  // ===== year =====
  int currentYear = Year.now().getValue();

  // ===== display name (client_name 우선) =====
  String displayName = "";
  if (loggedIn) {
      try {
          // AccountDto에 getClient_name()가 있다고 가정
          displayName = loginUser.getClient_name();
      } catch (Exception e) {
          displayName = null;
      }
      if (displayName == null || displayName.isBlank()) {
          displayName = loginUser.getUsername(); // fallback
      }
  }
%>

<!-- ✅ Header -->
<header class="header">
  <div class="header-inner">

    <a href="<%= ctx %>/" class="logo">
      <div class="logo-icon">⚖️</div>
      <div class="logo-text">
        LegalRisk <span>AI</span>
      </div>
    </a>

    <nav class="nav">
      <a class="<%= activeBoonjang %>" href="<%= ctx %>/boonjang">⚖️ 분쟁유형</a>
      <a class="<%= activeLaw %>"      href="<%= ctx %>/law">⚠️ 법적위험</a>
      <a class="<%= activeYusa %>"     href="<%= ctx %>/yusa">🔍 유사판례</a>
      <a class="<%= activeJogi %>"     href="<%= ctx %>/jogi">💡 조기위험</a>
    </nav>

    <div class="header-user">
      <% if (loggedIn) { %>
        <span class="hello">👋 <%= displayName %>님</span>

        <!-- ✅ logout: POST + CSRF -->
        <form method="post" action="<%= ctx %>/logout" class="m-0">
          <% if (csrf != null) { %>
            <input type="hidden" name="<%= csrf.getParameterName() %>" value="<%= csrf.getToken() %>" />
          <% } %>
          <button type="submit" class="logout-btn">로그아웃</button>
        </form>

      <% } else { %>
        <a href="<%= ctx %>/login">로그인</a>
        <a href="<%= ctx %>/client/join" class="btn-join">회원가입</a>
      <% } %>
    </div>

  </div>
</header>

<div class="container py-4 py-md-5">

  <!-- Hero -->
  <div class="glass p-4 p-md-5 mb-4">
    <div class="row g-4 align-items-center">
      <div class="col-lg-7">
        <div class="badge text-bg-primary-subtle text-primary-emphasis rounded-pill px-3 py-2 mb-3">⚖️ Legal Assistant</div>

        <% if (loggedIn) { %>
          <h1 class="fw-bold mb-2"><%= displayName %> 님, 환영합니다</h1>
          <p class="text-muted mb-0">
            LEGALAI에서 법적 위험 분석, 분쟁 유형 분류, 유사 판례 탐색, 조기중재를 빠르게 이용할 수 있습니다.
          </p>
        <% } else { %>
          <h1 class="fw-bold mb-2">LEGALAI 메인</h1>
          <p class="text-muted mb-0">
            로그인 후 더 많은 기능을 이용할 수 있습니다. 아래에서 원하는 기능으로 이동하세요.
          </p>
        <% } %>
      </div>

      <div class="col-lg-5">
        <div class="p-3 p-md-4 bg-white rounded-4 border">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="fw-bold">빠른 이동</div>
            <div class="text-muted small">원하는 기능 선택</div>
          </div>

          <div class="d-grid gap-2">
            <a class="btn btn-primary" href="<%= ctx %>/law">법적위험 분석</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/boonjang">분쟁유형 분류</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/yusa">유사판례 탐색</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/jogi">조기중재</a>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Features -->
  <div class="row g-3 g-md-4">
    <div class="col-md-6 col-lg-3">
      <div class="card feature-card h-100">
        <div class="card-body">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="icon-badge">⚠️</div>
            <div>
              <div class="fw-bold">법적위험</div>
              <div class="text-muted small">리스크 요약/가이드</div>
            </div>
          </div>
          <p class="text-muted mb-3">입력한 상황을 기반으로 쟁점과 위험 요소를 정리합니다.</p>
          <a class="btn btn-primary w-100" href="<%= ctx %>/law">열기</a>
        </div>
      </div>
    </div>

    <div class="col-md-6 col-lg-3">
      <div class="card feature-card h-100">
        <div class="card-body">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="icon-badge">🧩</div>
            <div>
              <div class="fw-bold">분쟁유형</div>
              <div class="text-muted small">카테고리 분류</div>
            </div>
          </div>
          <p class="text-muted mb-3">분쟁 내용을 유형별로 분류해 다음 액션을 제안합니다.</p>
          <a class="btn btn-primary w-100" href="<%= ctx %>/boonjang">열기</a>
        </div>
      </div>
    </div>

    <div class="col-md-6 col-lg-3">
      <div class="card feature-card h-100">
        <div class="card-body">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="icon-badge">📚</div>
            <div>
              <div class="fw-bold">유사판례</div>
              <div class="text-muted small">검색/비교</div>
            </div>
          </div>
          <p class="text-muted mb-3">유사한 케이스의 판례를 찾아 핵심 포인트를 비교합니다.</p>
          <a class="btn btn-primary w-100" href="<%= ctx %>/yusa">열기</a>
        </div>
      </div>
    </div>

    <div class="col-md-6 col-lg-3">
      <div class="card feature-card h-100">
        <div class="card-body">
          <div class="d-flex align-items-center gap-2 mb-3">
            <div class="icon-badge">⏱️</div>
            <div>
              <div class="fw-bold">조기중재</div>
              <div class="text-muted small">빠른 해결</div>
            </div>
          </div>
          <p class="text-muted mb-3">초기 대응 전략과 중재 방향을 빠르게 정리합니다.</p>
          <a class="btn btn-primary w-100" href="<%= ctx %>/jogi">열기</a>
        </div>
      </div>
    </div>
  </div>

</div>

<!-- ✅ Footer -->
<footer class="footer">
  <div class="footer-inner">

    <div class="footer-top">
      <div class="footer-logo">
        <span class="text-lg">⚖️</span>
        <span>© <%= currentYear %> LegalRisk AI</span>
      </div>

      <nav class="footer-nav">
        <a href="<%= ctx %>/boonjang">분쟁유형</a>
        <a href="<%= ctx %>/law">법적위험</a>
        <a href="<%= ctx %>/yusa">유사판례</a>
        <a href="<%= ctx %>/jogi">조기위험</a>
      </nav>

      <div class="footer-right">
        <span>문의: support@legalrisk.ai</span>
        <a href="https://github.com/DeepCodeLogicAI/LegalRiskAI.git"
           target="_blank" rel="noopener noreferrer">
          🐙 GitHub
        </a>
      </div>
    </div>

    <div class="footer-bottom">
      본 서비스는 법률 정보 제공 목적으로만 사용되며, 전문적인 법률 자문을 대체하지 않습니다.
    </div>

  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
