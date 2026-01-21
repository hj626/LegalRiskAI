<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f5f5f5;
    }

    .login-box {
        width: 350px;
        margin: 120px auto;
        padding: 30px;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        text-align: center;
    }

    .login-box h2 {
        margin-bottom: 25px;
    }

    .login-box input {
        width: 100%;
        height: 40px;
        margin-bottom: 12px;
        padding: 0 10px;
        box-sizing: border-box;
        font-size: 14px;
    }

    .login-box button {
        width: 100%;
        height: 42px;
        background-color: #007bff;
        color: #fff;
        border: none;
        font-size: 15px;
        cursor: pointer;
        margin-top: 10px;
    }

    .login-box button:hover {
        background-color: #0056b3;
    }

    .login-links {
        margin-top: 18px;
        font-size: 13px;
    }

    .login-links a {
        color: #555;
        text-decoration: none;
        margin: 0 8px;
    }

    .login-links a:hover {
        text-decoration: underline;
    }   
    
    .logo-wrapper {
    text-align: center;
    margin-top: 80px;
    margin-bottom: -60px; /* 로그인 박스랑 간격 조절 */
}

	.logo {
	    font-size: 42px;
	    font-weight: 800;
	    letter-spacing: 1px;
	    text-decoration: none;
	    color: #222;
	}
	
	.logo span {
	    color: #007bff; /* AI 포인트 컬러 */
	}
	
	.logo:hover {
	    opacity: 0.85;
	}
	     
</style>
</head>
<body>

<!-- 🔹 로고 영역 -->
<div class="logo-wrapper">
    <a href="${pageContext.request.contextPath}/" class="logo">
        LEGAL<span>AI</span>
    </a>
</div>


<div class="login-box">
    <h2>로그인</h2>
	<% if (request.getParameter("error") != null) { %>
	  <div class="alert alert-danger d-flex align-items-center gap-2 py-2 mb-3">
	    <span>⚠️</span>
	    <span>아이디와 비밀번호를 확인해주세요.</span>
	  </div>
	<% } %>
	<form action="${pageContext.request.contextPath}/login" method="post">
	    <input type="hidden" name="secret_key" value="secret">
	
	    <input type="text" name="username" placeholder="아이디" required>
	    <input type="password" name="password" placeholder="비밀번호" required>
	    <button type="submit">로그인</button>
	</form>

    <div class="login-links">
    	<a href="${pageContext.request.contextPath}/client/findPassword">비밀번호 찾기</a>
        <a href="${pageContext.request.contextPath}/client/join">회원가입</a>
    </div>
    
</div>

</body>
</html>