<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="com.oracle.Legal.dto.AccountDto" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원정보</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
  body { background: #f6f7fb; }
  .glass{
    background: rgba(255,255,255,.9);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(15, 23, 42, .06);
    border-radius: 18px;
    box-shadow: 0 12px 34px rgba(0,0,0,.06);
  }
  .avatar{
    width: 72px; height: 72px;
    border-radius: 22px;
    background: #eef2ff;
    display:flex; align-items:center; justify-content:center;
    font-size: 34px;
    border: 1px solid rgba(15, 23, 42, .06);
  }
  .kv { display:flex; justify-content:space-between; padding:10px 0; border-top:1px solid #f1f5f9; font-size:14px; }
  .kv:first-child{ border-top:0; padding-top:0; }
  .kv .k{ color:#64748b; } .kv .v{ font-weight:600; color:#0f172a; }
  .help{ font-size:12px; color:#64748b; }
</style>
</head>

<%
  Authentication auth = SecurityContextHolder.getContext().getAuthentication();
  AccountDto loginUser = null;
  boolean loggedIn = false;

  if (auth != null && auth.getPrincipal() instanceof AccountDto) {
    loginUser = (AccountDto) auth.getPrincipal();
    loggedIn = true;
  }

  String ctx = request.getContextPath();

  String displayName = "";
  String username = "";
  Integer clientCode = null;

  if (loggedIn) {
    try { displayName = loginUser.getClient_name(); } catch(Exception e) {}
    try { username = loginUser.getUsername(); } catch(Exception e) {}
    try { clientCode = loginUser.getClient_code(); } catch(Exception e) {}
    if (displayName == null || displayName.isBlank()) displayName = username;
  }
%>

<body class="d-flex flex-column min-vh-100">
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container py-4 py-md-5 flex-grow-1">
  <div class="row g-4">

    <!-- LEFT -->
    <div class="col-12 col-lg-4">
      <div class="glass p-4">
        <div class="d-flex align-items-center gap-3 mb-3">
          <div class="avatar">👤</div>
          <div>
			<div class="fw-bold fs-4">${user.client_name}</div>
            <div class="text-muted small"><%= username %></div>
          </div>
        </div>

        <div class="mt-3">
          <div class="kv">
            <div class="k">회원 코드</div>
            <div class="v"><%= clientCode != null ? clientCode : "-" %></div>
          </div>
        </div>

        <div class="d-grid gap-2 mt-4">
          <a class="btn btn-outline-secondary" href="<%= ctx %>/mypage">← 마이페이지</a>
        </div>
      </div>
    </div>

    <!-- RIGHT -->
    <div class="col-12 col-lg-8">
      <div class="glass p-4">
        <div class="mb-3">
          <div class="fw-bold fs-4">회원정보 수정</div>
          <div class="text-muted small">이름/이메일/전화번호/직업을 변경할 수 있습니다.</div>
        </div>

        <!-- 메시지(선택) -->
        <c:if test="${not empty msg}">
          <div class="alert alert-info py-2 mb-3">${msg}</div>
        </c:if>

        <!-- ✅ 아직 컨트롤러 없어도 form 구조부터 만들어두기 -->
        <form method="post" action="${pageContext.request.contextPath}/mypage/user/update" class="row g-3">

          <!-- PK는 수정 금지 (hidden) -->
          <input type="hidden" name="client_code" value="<%= clientCode != null ? clientCode : 0 %>"/>

          <div class="col-md-6">
            <label class="form-label">이름</label>
            <input type="text" class="form-control" name="client_name"
                   value="${user.client_name != null ? user.client_name : ''}">
            <div class="help mt-1">이름은 꼭 입력해주세요.</div>
          </div>

          <div class="col-md-6">
            <label class="form-label">이메일</label>
            <input type="email" class="form-control" name="client_email"
                   value="${user.client_email != null ? user.client_email : ''}">
          </div>

          <div class="col-md-6">
            <label class="form-label">전화번호</label>
            <input type="text" class="form-control" name="client_tel"
                   value="${user.client_tel != null ? user.client_tel : ''}">
          </div>

          <div class="col-md-6">
            <label class="form-label">직업</label>
            <input type="text" class="form-control" name="client_job"
                   value="${user.client_job != null ? user.client_job : ''}">
          </div>

          <div class="col-12">
            <hr class="my-2">
            <div class="d-flex gap-2 justify-content-end">
              <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/mypage/user">취소</a>
              <button type="submit" class="btn btn-primary">저장</button>
            </div>
          </div>

        </form>

      </div>
    </div>

  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
