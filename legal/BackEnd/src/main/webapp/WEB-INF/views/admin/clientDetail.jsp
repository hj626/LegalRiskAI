<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 상세</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="d-flex flex-column min-vh-100">
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main class="container my-5 flex-grow-1">

  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h2 class="fw-bold mb-1">회원 상세</h2>
      <div class="text-muted small">코드: ${client.client_code}</div>
    </div>

    <a class="btn btn-outline-secondary"
       href="${pageContext.request.contextPath}/admin/main?page=${param.page}&size=${param.size}">
      목록으로
    </a>
  </div>

  <!-- 🔽 여기서부터 좌/우 분할 -->
  <div class="row g-4">

    <!-- ✅ 왼쪽: 회원 상세 카드 -->
    <div class="col-md-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">

          <form method="post"
                action="${pageContext.request.contextPath}/admin/client/${client.client_code}/status"
                class="row g-3">

            <input type="hidden" name="page" value="${param.page}">
            <input type="hidden" name="size" value="${param.size}">

            <div class="col-12">
              <label class="form-label">이름</label>
              <input type="text" class="form-control" value="${client.client_name}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">이메일</label>
              <input type="text" class="form-control" value="${client.client_email}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">전화</label>
              <input type="text" class="form-control" value="${client.client_tel}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">직업</label>
              <input type="text" class="form-control" value="${client.client_job}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">회원 상태</label>
              <select name="client_is_del" class="form-select">
                <option value="0" <c:if test="${client.client_is_del == 0}">selected</c:if>>정상</option>
                <option value="1" <c:if test="${client.client_is_del == 1}">selected</c:if>>탈퇴</option>
              </select>
            </div>

            <div class="col-12 d-flex justify-content-end mt-3">
              <button type="submit" class="btn btn-primary px-4">
                변경 저장
              </button>
            </div>

          </form>

        </div>
      </div>
    </div>

    <!-- ⬜ 오른쪽: 빈 카드 (디자인용) -->
    <div class="col-md-6">
      <div class="card border-0 bg-light h-100 d-flex align-items-center justify-content-center">
        <div class="text-muted text-center px-4">
          <div class="fs-6 fw-semibold mb-2">분석 페이지</div>
          <div class="small">
            차후<br/>
            수정예정 
          </div>
        </div>
      </div>
    </div>

  </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
