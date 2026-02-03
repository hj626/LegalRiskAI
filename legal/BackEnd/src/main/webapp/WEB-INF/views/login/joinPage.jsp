<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f5f5f5;
    }

    .join-box {
        width: 420px;
        margin: 100px auto;
        padding: 30px;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .join-box h2 {
        text-align: center;
        margin-bottom: 25px;
    }

    .form-row {
        margin-bottom: 14px;
    }

    .form-row label {
        display: block;
        font-size: 13px;
        margin-bottom: 6px;
        color: #333;
    }

    .form-row input {
        width: 100%;
        height: 40px;
        padding: 0 10px;
        box-sizing: border-box;
        font-size: 14px;
    }

    .btn-row {
        margin-top: 18px;
        display: flex;
        gap: 10px;
    }

    .btn-row button {
        flex: 1;
        height: 42px;
        border: none;
        cursor: pointer;
        font-size: 14px;
    }

    .btn-submit {
        background: #007bff;
        color: #fff;
    }

    .btn-submit:hover {
        background: #0056b3;
    }

    .btn-home {
        background: #e9ecef;
        color: #333;
    }

    .btn-home:hover {
        background: #dfe3e6;
    }
</style>
</head>
<body>

<div class="join-box">
    <h2>회원가입</h2>

	<form action="${pageContext.request.contextPath}/client/saveInform" method="post">

        <!-- 회원 정보 -->
        <div class="form-row">
            <label>이름</label>
            <input type="text" name="client_name" required>
        </div>

        <div class="form-row">
            <label>이메일</label>
            <input type="email" name="client_email" required>
        </div>

        <div class="form-row">
            <label>전화번호</label>
            <input type="text" name="client_tel"
		       placeholder="010-0000-0000"
		       maxlength="13"
		       oninput="autoHyphen(this)"
		       required>
        </div>
		
		<div class="form-row">
		    <label>직업</label>
		    <select name="client_job" required
		            style="width:100%; height:40px; padding:0 10px; box-sizing:border-box; font-size:14px;">
		        <option value="" selected disabled>선택하세요</option>
		        <option value="학생">학생</option>
		        <option value="회사원">회사원</option>
		        <option value="공무원">공무원</option>
		        <option value="자영업자">자영업자</option>
		        <option value="프리랜서">프리랜서</option>
		        <option value="전문직">전문직</option>
		        <option value="군인">군인</option>
		        <option value="무직">무직</option>
		        <option value="기타">기타</option>
		    </select>
		</div>


        <!-- 로그인 정보 -->
        <div class="form-row">
            <label>아이디</label>
            <input type="text" name="username" required>
        </div>

        <div class="form-row">
            <label>비밀번호</label>
            <input type="password" name="password" required>
        </div>

        <div class="btn-row">
            <button type="submit" class="btn-submit">가입하기</button>
            <button type="button" class="btn-home" onclick="location.href='/'">홈으로</button>
        </div>
    </form>

</div>

<script>
function autoHyphen(target) {
    // 숫자만 남기기
    target.value = target.value
        .replace(/[^0-9]/g, '')
        .replace(/^(\d{3})(\d{0,4})(\d{0,4})$/, function(_, p1, p2, p3) {
            let result = p1;
            if (p2) result += '-' + p2;
            if (p3) result += '-' + p3;
            return result;
        });
}
</script>

</body>
</html>
