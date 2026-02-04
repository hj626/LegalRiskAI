<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="com.oracle.Legal.dto.AccountDto" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>LEGALAI - 메인</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<%
  Authentication auth = SecurityContextHolder.getContext().getAuthentication();

  AccountDto loginUser = null;
  boolean loggedIn = false;

  if (auth != null && auth.getPrincipal() instanceof AccountDto) {
      loginUser = (AccountDto) auth.getPrincipal();
      loggedIn = true;
  }

  String displayName = "";
  if (loggedIn) {
    try {
      displayName = loginUser.getClient_name();
      if (displayName == null || displayName.isBlank()) displayName = loginUser.getUsername();
    } catch(Exception e) {}
  }
%>

<style>
  body { background:#f6f7fb; }

  .card-soft{
    border: 1px solid rgba(16,24,40,.08);
    box-shadow: 0 6px 20px rgba(16,24,40,.06);
    border-radius: 18px;
  }

  .welcome-card{
    border-radius: 18px;
    color: #fff;
    background: linear-gradient(135deg, #2f6cff 0%, #6a46ff 55%, #3a7bff 100%);
    box-shadow: 0 14px 34px rgba(58,123,255,.25);
    overflow: hidden;
    position: relative;
  }
  .welcome-card:before{
    content:"";
    position:absolute;
    top:-80px; right:-80px;
    width:180px; height:180px;
    background: rgba(255,255,255,.14);
    border-radius: 50%;
  }
  .welcome-card:after{
    content:"";
    position:absolute;
    bottom:-110px; left:-110px;
    width:220px; height:220px;
    background: rgba(255,255,255,.10);
    border-radius: 50%;
  }

  .fav-scroll{
    max-height: 330px;
    overflow-y: auto;
    padding-right: 6px;
  }
  .fav-scroll::-webkit-scrollbar{ width: 10px; }
  .fav-scroll::-webkit-scrollbar-thumb{
    background: rgba(15,23,42,.15);
    border-radius: 999px;
    border: 3px solid transparent;
    background-clip: content-box;
  }

  .fav-table thead th{
    font-size: 13px;
    color:#64748b;
    font-weight:700;
    white-space: nowrap;
    position: sticky;
    top: 0;
    background: #fff;
    z-index: 2;
  }
  .fav-table tbody td{
    font-size: 14px;
    vertical-align: middle;
  }

  .chip{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    padding: 4px 12px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 700;
    background: #eef2ff;
    color: #1d4ed8;
    white-space: nowrap;
  }

  .btn-xs{
    padding: 6px 10px;
    font-size: 12px;
    border-radius: 10px;
  }

  .feature-card{
    border-radius: 18px;
    border: 1px solid rgba(16,24,40,.08);
    box-shadow: 0 8px 18px rgba(16,24,40,.05);
    transition: .15s ease;
    height: 100%;
  }
  .feature-card:hover{
    transform: translateY(-2px);
    box-shadow: 0 14px 28px rgba(16,24,40,.08);
  }
  .feature-ico{
    width:48px; height:48px;
    border-radius: 16px;
    display:flex; align-items:center; justify-content:center;
    background:#f1f5f9;
  }
</style>
</head>

<body class="d-flex flex-column min-vh-100">

<main class="container py-4 py-md-5 flex-grow-1">

  <% if (!loggedIn) { %>
    <div class="card card-soft p-4 p-md-5">
      <h2 class="fw-bold mb-2">LEGALAI 메인</h2>
      <p class="text-muted mb-3">로그인 후 서비스를 이용하실 수 있습니다.</p>
      <a class="btn btn-primary" href="<c:url value='/login'/>">로그인</a>
    </div>
  <% } else { %>

    <div class="row g-4 mb-4">
      <!-- LEFT: 즐겨찾기 -->
      <div class="col-12 col-lg-8">
        <div class="card card-soft p-4 h-100">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
              <div class="fw-bold">즐겨찾기 목록</div>
              <div class="text-muted small">즐겨찾기로 저장된 항목만 표시됩니다</div>
            </div>          </div>

          <div class="fav-scroll">
            <div class="table-responsive">
              <table class="table align-middle mb-0 fav-table">
                <thead>
                  <tr>
                    <th style="width:110px;">작성일자</th>
                    <th>사건 요약</th>
                    <th style="width:120px;">서비스 종류</th>
                    <th style="width:90px;">작업</th>
                  </tr>
                </thead>

                <tbody>
                  <c:choose>
                    <c:when test="${empty favorites}">
                      <tr>
                        <td colspan="4" class="text-muted text-center py-4">
                          즐겨찾기한 항목이 없습니다.
                        </td>
                      </tr>
                    </c:when>

                    <c:otherwise>
                      <c:forEach var="f" items="${favorites}">
                        <tr>
                          <!-- 작성일자 -->
                          <td class="text-muted" style="white-space:nowrap;">
                            <c:choose>
                              <c:when test="${not empty f.analysisDate}">
                                <fmt:formatDate value="${f.analysisDate}" pattern="yyyy-MM-dd"/>
                              </c:when>
                              <c:otherwise>-</c:otherwise>
                            </c:choose>
                          </td>

                          <!-- 사건요약(50자 요약) -->
                          <td>
                            <c:choose>
                              <c:when test="${not empty f.input}">
                                <c:choose>
                                  <c:when test="${fn:length(f.input) > 50}">
                                    <c:out value="${fn:substring(f.input, 0, 50)}"/>...
                                  </c:when>
                                  <c:otherwise>
                                    <c:out value="${f.input}"/>
                                  </c:otherwise>
                                </c:choose>
                              </c:when>
                              <c:otherwise>
                                <span class="text-muted">(입력 없음)</span>
                              </c:otherwise>
                            </c:choose>
                          </td>

                          <!-- 서비스 종류(한글) -->
                          <td>
                            <c:choose>
                              <c:when test="${f.serviceType == 'JOGI'}">
                                <span class="chip" style="background:#ecfeff; color:#0e7490;">승소율 측정</span>
                              </c:when>
                              <c:when test="${f.serviceType == 'LAW'}">
                                <span class="chip" style="background:#fef2f2; color:#b91c1c;">법적위험</span>
                              </c:when>
                              <c:when test="${f.serviceType == 'BOONJANG'}">
                                <span class="chip" style="background:#fefce8; color:#a16207;">분쟁위험</span>
                              </c:when>
                              <c:when test="${f.serviceType == 'YUSA'}">
                                <span class="chip" style="background:#eef2ff; color:#1d4ed8;">유사판례</span>
                              </c:when>
                              <c:otherwise>
                                <span class="chip">기타</span>
                              </c:otherwise>
                            </c:choose>
                          </td>

                          <!-- 상세보기: 마이페이지와 동일하게 새 창(window.open) -->
                          <td>
                            <button type="button" class="btn btn-xs btn-outline-primary"
                              onclick="window.open(
                                '${pageContext.request.contextPath}/mypage/history/${f.serviceType}/${f.serviceCode}',
                                'detail_${f.serviceType}_${f.serviceCode}',
                                'width=900,height=700,scrollbars=yes'
                              )">
                              상세보기
                            </button>
                          </td>
                        </tr>
                      </c:forEach>
                    </c:otherwise>
                  </c:choose>
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </div>

      <!-- RIGHT: 환영 카드 -->
      <div class="col-12 col-lg-4">
        <div class="welcome-card p-4 h-100 d-flex flex-column justify-content-between">
          <div style="position:relative; z-index:1;">
            <h3 class="fw-bold mb-2"><%= displayName %> 님,<br/>환영합니다</h3>
            <p class="mb-0" style="color:rgba(255,255,255,.85);">
              LEGALAI 서비스를 이용해주셔서 감사합니다.<br/>
              스마트한 법률 비서가 업무를 지원합니다.
            </p>
          </div>

          <div style="position:relative; z-index:1;" class="mt-4">
            <a class="btn btn-light w-100 fw-semibold py-2" href="<c:url value='/daily'/>">
              데일리 업데이트 확인 <span class="ms-1">›</span>
            </a>

            <div class="d-flex align-items-center gap-2 mt-3 small" style="color:rgba(255,255,255,.85);">
              <span style="width:8px; height:8px; background:#22c55e; border-radius:50%; display:inline-block;"></span>
              AI 모델 최신 상태 유지 중
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 하단 설명용 3카드 -->
    <div class="row g-4">
      <div class="col-12 col-md-4">
        <div class="feature-card p-4">
          <div class="feature-ico mb-3">📌</div>
          <div class="fw-bold mb-1">분쟁</div>
          <div class="text-muted small">
            진행 중인 분쟁 사례에 대한 절차 안내와 전략 수립을 지원합니다.
          </div>
        </div>
      </div>

      <div class="col-12 col-md-4">
        <div class="feature-card p-4">
          <div class="feature-ico mb-3">⚠️</div>
          <div class="fw-bold mb-1">법적 리스크</div>
          <div class="text-muted small">
            계약서 및 사업 영역에서 잠재 리스크를 사전에 식별합니다.
          </div>
        </div>
      </div>

      <div class="col-12 col-md-4">
        <div class="feature-card p-4">
          <div class="feature-ico mb-3">⚖️</div>
          <div class="fw-bold mb-1">유사판례</div>
          <div class="text-muted small">
            사건과 유사한 판례 및 관련 경향을 분석해드립니다.
          </div>
        </div>
      </div>
    </div>

  <% } %>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
