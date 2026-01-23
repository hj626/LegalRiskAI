<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="com.oracle.Legal.dto.AccountDto" %>
<%@ page import="org.springframework.security.web.csrf.CsrfToken" %>

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
</style>

<%
  Authentication auth = SecurityContextHolder.getContext().getAuthentication();

  AccountDto loginUser = null;
  boolean loggedIn = false;

  if (auth != null && auth.getPrincipal() instanceof AccountDto) {
      loginUser = (AccountDto) auth.getPrincipal();
      loggedIn = true;
  }

  String ctx = request.getContextPath();
  String uri = request.getRequestURI();
  String path = uri;

  if (ctx != null && !ctx.isBlank() && uri.startsWith(ctx)) {
      path = uri.substring(ctx.length());
  }

  CsrfToken csrf = (CsrfToken) request.getAttribute("_csrf");

  String activeBoonjang = path.startsWith("/boonjang") ? "active" : "";
  String activeLaw      = path.startsWith("/law") ? "active" : "";
  String activeYusa     = path.startsWith("/yusa") ? "active" : "";
  String activeJogi     = path.startsWith("/jogi") ? "active" : "";

  String displayName = "";
  if (loggedIn) {
      displayName = loginUser.getClient_name();
      if (displayName == null || displayName.isBlank()) {
          displayName = loginUser.getUsername();
      }
  }
%>

<header class="header">
  <div class="header-inner">
    <a href="<%= ctx %>/" class="logo">
      <div class="logo-icon">⚖️</div>
      <div class="logo-text">LegalRisk <span>AI</span></div>
    </a>

    <nav class="nav">
      <a class="<%= activeBoonjang %>" href="<%= ctx %>/boonjang">⚖️ 분쟁유형</a>
      <a class="<%= activeLaw %>" href="<%= ctx %>/law">⚠️ 법적위험</a>
      <a class="<%= activeYusa %>" href="<%= ctx %>/yusa">🔍 유사판례</a>
      <a class="<%= activeJogi %>" href="<%= ctx %>/jogi">💡 조기위험</a>
    </nav>

    <div class="header-user">
      <% if (loggedIn) { %>
        <span class="hello">👋 <%= displayName %>님</span>
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
