<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>비밀번호 찾기</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
  .content {
    margin-left: 240px;   /* 사이드바 쓰는 구조면 유지 */
    padding: 40px;
  }

  .find-box {
    max-width: 420px;
    margin: 80px auto;
    padding: 32px;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
  }
</style>
</head>

<body>

<div class="content">
  <div class="find-box">
    <h4 class="fw-bold mb-3 text-center">비밀번호 찾기</h4>
    <p class="text-muted small text-center mb-4">
      가입 시 사용한 정보를 입력하시면<br>
      임시 비밀번호를 이메일로 보내드립니다.
    </p>

    <!-- ✅ URL 수정 -->
    <form action="${pageContext.request.contextPath}/client/findPassword/request" method="post">

      <!-- 이름 -->
      <div class="mb-3">
        <label class="form-label">이름</label>
        <input type="text" name="client_name" class="form-control"
               placeholder="이름을 입력하세요" required>
      </div>

      <!-- 이메일 -->
      <div class="mb-3">
        <label class="form-label">이메일</label>
        <input type="email" name="client_email" class="form-control"
               placeholder="example@email.com" required>
      </div>

      <div class="d-grid">
        <button type="submit" class="btn btn-primary">
          인증 메일 보내기
        </button>
      </div>
    </form>

    <!-- 메시지 출력 -->
    <% if (request.getAttribute("msg") != null) { %>
      <div class="alert alert-success mt-3 text-center">
        <%= request.getAttribute("msg") %>
      </div>
    <% } %>

    <% if (request.getAttribute("err") != null) { %>
      <div class="alert alert-danger mt-3 text-center">
        <%= request.getAttribute("err") %>
      </div>
    <% } %>

    <div class="text-center mt-4">
      <a href="${pageContext.request.contextPath}/login"
         class="text-decoration-none small">
        로그인 화면으로 돌아가기
      </a>
    </div>
  </div>
</div>

</body>
</html>
