<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 목록</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="d-flex flex-column min-vh-100">
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <main class="container my-5 flex-grow-1">
        <div class="d-flex justify-content-between align-items-end mb-3">
            <div>
                <h2 class="fw-bold mb-1">회원 목록</h2>
                <div class="text-muted small">총 ${totalCount}명</div>
            </div>

            <!-- 페이지 사이즈 변경 -->
            <form method="get" action="${pageContext.request.contextPath}/admin/main" class="d-flex gap-2">
                <input type="hidden" name="page" value="1"/>
                <select name="size" class="form-select form-select-sm" onchange="this.form.submit()">
                    <option value="10" <c:if test="${size == 10}">selected</c:if>>10개</option>
                    <option value="20" <c:if test="${size == 20}">selected</c:if>>20개</option>
                    <option value="30" <c:if test="${size == 30}">selected</c:if>>30개</option>
                </select>
            </form>
        </div>

        <div class="card shadow-sm">
            <div class="card-body">

                <c:choose>
                    <c:when test="${empty clientList}">
                        <p class="text-muted mb-0">회원이 없습니다.</p>
                    </c:when>

                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width: 90px;">코드</th>
                                        <th>이름</th>
                                        <th>이메일</th>
                                        <th style="width: 160px;">전화</th>
                                        <th style="width: 140px;">직업</th>
                                        <th style="width: 110px;">회원여부</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:forEach var="c" items="${clientList}">
                                        <tr>
                                            <td>${c.client_code}</td>
                                            <td>${c.client_name}</td>
                                            <td>${c.client_email}</td>
                                            <td>${c.client_tel}</td>
                                            <td>${c.client_job}</td>

                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.client_is_del == 1}">
                                                        <span class="badge text-bg-secondary">탈퇴</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge text-bg-success">정상</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <!-- 페이징 -->
                        <nav class="mt-3">
                            <ul class="pagination pagination-sm justify-content-center mb-0">
                                <c:set var="baseUrl" value="${pageContext.request.contextPath}/admin/main?size=${size}" />

                                <li class="page-item <c:if test='${page <= 1}'>disabled</c:if>">
                                    <a class="page-link" href="${baseUrl}&page=${page-1}">이전</a>
                                </li>

                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <li class="page-item <c:if test='${p == page}'>active</c:if>">
                                        <a class="page-link" href="${baseUrl}&page=${p}">${p}</a>
                                    </li>
                                </c:forEach>

                                <li class="page-item <c:if test='${page >= totalPages}'>disabled</c:if>">
                                    <a class="page-link" href="${baseUrl}&page=${page+1}">다음</a>
                                </li>
                            </ul>
                        </nav>
                    </c:otherwise>
                </c:choose>

            </div>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
