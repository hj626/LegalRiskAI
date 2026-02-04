<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>접근 권한 오류</title>
    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .form-container {
            width: 100%;
            max-width: 980px;
            margin: 0 auto;
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
    

    <div class="d-flex flex-grow-1">
    

        <!-- 본문 + 푸터 같은 컬럼 -->
        <div class="d-flex flex-column flex-grow-1">
           <main class="flex-grow-1 d-flex align-items-center justify-content-center">
					    <div class="form-container">
					        <div class="card shadow-sm">
                        <div class="card-header bg-danger text-white">
                            <h2 class="h5 mb-0">접근 권한 오류</h2>
                        </div>

                        <div class="card-body">
                            <div class="row align-items-center">
                                <!-- 텍스트 영역 -->
                                <div class="col-md-6">
                                    <h5 class="mb-3"><c:out value="${exception}" /></h5>
                                    <p class="mb-4">
                                        <c:if test="${username != null}">
                                            <strong><c:out value="${displayName}" /></strong> 님은 이 페이지에 대한 접근 권한이 없습니다.
                                        </c:if>
                                        <c:if test="${username == null}">
                                            비정상적인 접근입니다. 로그인 후 다시 시도해 주세요.
                                        </c:if>
                                    </p>

                                    <div class="d-flex gap-2 justify-content-start">
                                        <!-- 프로젝트 표준 버튼 스타일 가정: btn-brown-outline -->
                                        <button type="button" class="btn btn-brown-outline"
                                                onclick="history.back()">이전 페이지</button>
                                        <a class="btn btn-secondary"
                                           href="${pageContext.request.contextPath}/">홈으로</a>
                                    </div>
                                </div>

                                <!-- 이미지 영역 -->
                                <div class="col-md-6 text-center">
									<img src="<c:url value='/image/accessban.jpg'/>"
									     class="img-fluid" alt="접근 제한 안내 이미지">
                                </div>
                            </div>
                        </div><!-- card-body -->
                    </div><!-- card -->
                </div><!-- form-container -->
            </main>

        </div>
    </div>

</body>
</html>
