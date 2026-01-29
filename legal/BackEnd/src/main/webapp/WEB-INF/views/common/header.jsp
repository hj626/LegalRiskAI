<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="com.oracle.Legal.dto.AccountDto" %>
<%@ page import="org.springframework.security.web.csrf.CsrfToken" %>

<style>
  /* ===== Page base ===== */
  body { background: #f6f7fb; }

  /* ===== Header (React Header 동일 컨셉) ===== */
  .header {
    background: #fff;
    border-bottom: 1px solid #e5e7eb;
    position: sticky;
    top: 0;
    z-index: 150;
  }

  .header-inner {
    position: relative;
    width: 100%;
    max-width: 1600px;
    margin: 0 auto;
    padding: 0 80px;          /* px-20 */
    height: 72px;             /* h-18 */
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  /* ===== Logo ===== */
  .logo {
    flex-shrink: 0;
    display: flex;
    align-items: center;
    gap: 10px;                /* gap-2.5 */
    text-decoration: none;
    transition: opacity .15s ease;
  }
  .logo:hover { opacity: .9; }

  .logo-icon {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 8px rgba(59,130,246,.30);
  }

  .logo-text {
    font-size: 18px;
    font-weight: 600;
    color: #1e293b;           /* slate-800 */
    letter-spacing: -0.2px;
  }
  .logo-text .accent { color: #3b82f6; }

  /* ===== Center Nav (React처럼 pill background) ===== */
  .nav {
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    align-items: center;
    gap: 8px;
    background: #f1f5f9;      /* slate-100 */
    padding: 4px;
    border-radius: 12px;      /* rounded-xl */
  }

  .nav a {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;       /* px-5 py-2.5 */
    font-size: 14px;
    font-weight: 500;
    color: #64748b;           /* slate-500 */
    border-radius: 8px;       /* rounded-lg */
    text-decoration: none;
    transition: all .15s ease;
    white-space: nowrap;
  }
  .nav a:hover {
    background: rgba(255,255,255,.70);
    color: #3b82f6;
  }
  .nav a.active {
    background: #fff;
    color: #3b82f6;
    box-shadow: 0 1px 3px rgba(0,0,0,.10);
  }

  /* ===== Right user area ===== */
  .header-user {
    position: relative;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .auth-link {
    font-size: 14px;
    font-weight: 500;
    color: #475569; /* slate-600 */
    text-decoration: none;
    padding: 8px 12px;
    border-radius: 10px;
    transition: all .15s ease;
  }
  .auth-link:hover {
    color: #1f2937;
    background: #f3f4f6;
  }

  .btn-join {
    font-size: 14px;
    font-weight: 600;
    color: #fff !important;
    text-decoration: none;
    padding: 8px 14px;
    border-radius: 10px;
    background: linear-gradient(90deg, #3b82f6 0%, #2563eb 100%);
    box-shadow: 0 6px 14px rgba(37,99,235,.22);
    transition: all .15s ease;
    white-space: nowrap;
  }
  .btn-join:hover { filter: brightness(.97); }

  /* ===== ✅ 사용자 버튼 (React: px-4 py-2, text-sm) ===== */
  .user-btn{
    padding: 8px 16px;        /* px-4 py-2 */
    border-radius: 10px;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: transparent;
    border: 0;
    cursor: pointer;
    transition: background .15s ease;
  }
  .user-btn:hover { background: #f3f4f6; }

  .user-btn .hello-emoji{
    font-size: 16px;
    line-height: 1;
    display: inline-block;
  }
  .user-btn .user-name{
    font-size: 14px;          /* text-sm */
    font-weight: 500;
    color: #111827;
    line-height: 1;
    white-space: nowrap;
  }

  /* ===== Dropdown menu (React 동일) ===== */
  .user-menu {
    position: absolute;
    right: 0;
    top: calc(100% + 8px);
    width: 224px;             /* w-56 */
    background: #fff;
    border: 1px solid #e5e7eb; /* border-gray-200 */
    border-radius: 12px;      /* rounded-xl */
    box-shadow: 0 10px 15px rgba(0,0,0,.10), 0 4px 6px rgba(0,0,0,.06); /* shadow-lg */
    overflow: hidden;
    z-index: 9999;
    display: none;
  }

  .menu-head {
    padding: 12px 16px;       /* px-4 py-3 */
    border-bottom: 1px solid #f3f4f6; /* border-gray-100 */
  }
  .menu-head .name {
    margin: 0;
    font-size: 14px;
    font-weight: 600;         /* font-semibold */
    color: #1e293b;           /* text-slate-800 */
  }
  .menu-head .sub {
    margin: 2px 0 0 0;
    font-size: 12px;
    color: #64748b;           /* text-slate-500 */
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  /* React 메뉴 아이템: 이모지 + 텍스트 */
  .menu-item {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 12px;                /* gap-3 */
    padding: 12px 16px;       /* px-4 py-3 */
    font-size: 14px;
    color: #334155;           /* text-slate-700 */
    text-decoration: none;
    background: transparent;
    border: 0;
    cursor: pointer;
    text-align: left;
    transition: background .15s ease, color .15s ease;
  }
  .menu-item:hover { background: #f8fafc; } /* hover:bg-slate-50 */

  .menu-item .emoji{
    font-size: 16px;
    line-height: 1;
    display: inline-block;
  }

  /* Logout: React 동일 (text-red-600 + hover:bg-red-50) */
  .menu-item.logout {
    color: #dc2626;
  }
  .menu-item.logout:hover {
    background: #fef2f2;      /* red-50 */
  }

  /* ===== Responsive: md 미만에서 중앙 nav 숨김 ===== */
  @media (max-width: 767px) {
    .header-inner { padding: 0 16px; }
    .nav { display: none; }
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

  String activeBoonjang = path.startsWith("/ai-analysis") ? "active" : "";
  String activeLaw = path.startsWith("/law") ? "active" : "";
  String activeYusa = path.startsWith("/yusa") ? "active" : "";
  String activeJogi = path.startsWith("/jogi") ? "active" : "";

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
    <!-- Left: Logo -->
    <a href="<%= ctx %>/" class="logo">
      <div class="logo-icon">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <rect x="3" y="3" width="18" height="4" rx="1" fill="white" />
          <rect x="3" y="10" width="18" height="4" rx="1" fill="white" opacity="0.7" />
          <rect x="3" y="17" width="18" height="4" rx="1" fill="white" opacity="0.4" />
        </svg>
      </div>
      <span class="logo-text">LegalRisk<span class="accent">AI</span></span>
    </a>

    <!-- Center: Nav (Desktop) -->
    <nav class="nav">
      <a href="<%= ctx %>/ai-analysis" class="<%= activeBoonjang %>">
        <span style="font-size:16px;">📋</span>
        <span>법률 종합 검과</span>
      </a>
      <a href="<%= ctx %>/mypage/main">
        <span style="font-size:16px;">👤</span>
        <span>마이페이지</span>
      </a>
    </nav>

    <!-- Right: User Area -->
    <div class="header-user" id="userArea">
      <% if (loggedIn) { %>
        <!-- ✅ React처럼 버튼 크기/정렬 -->
        <button type="button" class="user-btn" id="userBtn">
          <span class="hello-emoji">👋</span>
          <span class="user-name"><%= displayName %> 님</span>
        </button>

        <!-- Dropdown -->
        <div class="user-menu" id="userMenu">
          <div class="menu-head">
            <p class="name"><%= displayName %> 님</p>
            <p class="sub"><%= loginUser.getUsername() %></p>
          </div>

          <!-- ✅ React처럼: 이모지 아이콘 + slate 텍스트 -->
          <a
            href="<%= ctx %>/mypage/main"
            class="menu-item"
            onclick="document.getElementById('userMenu').style.display='none';"
          >
            <span class="emoji">👤</span>
            <span>마이페이지</span>
          </a>

          <form method="post" action="<%= ctx %>/logout" class="m-0">
            <% if (csrf != null) { %>
              <input type="hidden" name="<%= csrf.getParameterName() %>" value="<%= csrf.getToken() %>" />
            <% } %>

            <!-- ✅ React처럼: 이모지 아이콘 + red 텍스트 -->
            <button type="submit" class="menu-item logout">
              <span class="emoji">🚪</span>
              <span>로그아웃</span>
            </button>
          </form>
        </div>
      <% } else { %>
        <a href="<%= ctx %>/login" class="auth-link">로그인</a>
        <a href="<%= ctx %>/client/join" class="btn-join">회원가입</a>
      <% } %>
    </div>
  </div>
</header>

<script>
  (function () {
    const btn = document.getElementById("userBtn");
    const menu = document.getElementById("userMenu");
    const area = document.getElementById("userArea");
    if (!btn || !menu || !area) return;

    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      menu.style.display = (menu.style.display === "block") ? "none" : "block";
    });

    document.addEventListener("mousedown", function (e) {
      if (!area.contains(e.target)) {
        menu.style.display = "none";
      }
    });
  })();
</script>
