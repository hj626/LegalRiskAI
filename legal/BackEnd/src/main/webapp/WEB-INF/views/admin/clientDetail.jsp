<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 상세</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ✅ Chart.js + 라벨 플러그인 -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0"></script>

</head>

<body class="d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main class="container my-5 flex-grow-1">

  <!-- 상단 -->
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

  <div class="row g-4">

    <!-- ================================================= -->
    <!-- ✅ 왼쪽 : 회원 정보 -->
    <!-- ================================================= -->
    <div class="col-md-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">

          <form method="post"
                action="${pageContext.request.contextPath}/admin/client/${client.client_code}/status"
                class="row g-3">

            <div class="col-12">
              <label class="form-label">이름</label>
              <input class="form-control" value="${client.client_name}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">이메일</label>
              <input class="form-control" value="${client.client_email}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">전화</label>
              <input class="form-control" value="${client.client_tel}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">직업</label>
              <input class="form-control" value="${client.client_job}" readonly>
            </div>

            <div class="col-12">
              <label class="form-label">가입일</label>
              <div class="form-control bg-light">
                <c:choose>
                  <c:when test="${empty client.client_reg_date}">-</c:when>
                  <c:otherwise>${fn:substring(client.client_reg_date,0,10)}</c:otherwise>
                </c:choose>
              </div>
            </div>

            <div class="col-12">
              <label class="form-label">회원 상태</label>
              <select name="client_is_del" class="form-select">
                <option value="0" <c:if test="${client.client_is_del == 0}">selected</c:if>>정상</option>
                <option value="1" <c:if test="${client.client_is_del == 1}">selected</c:if>>탈퇴</option>
              </select>
            </div>

            <div class="col-12 text-end">
              <button class="btn btn-primary">변경 저장</button>
            </div>

          </form>
        </div>
      </div>
    </div>


    <!-- ================================================= -->
    <!-- ✅ 오른쪽 : 서비스 이용 도넛 + 표 -->
    <!-- ================================================= -->
    <div class="col-md-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">

          <div class="d-flex justify-content-between mb-2">
            <div class="fw-bold">서비스 이용 현황</div>
            <span class="badge bg-primary">
              총 ${empty totalUsage ? 0 : totalUsage} 회
            </span>
          </div>

          <!-- 도넛 -->
          <div style="height:260px">
            <canvas id="serviceDonut"></canvas>
          </div>


          <!-- ================= 표 ================= -->
          <table class="table table-sm mt-4 text-center align-middle">
            <thead class="table-light">
              <tr>
                <th>서비스</th>
                <th>횟수</th>
                <th>비율</th>
              </tr>
            </thead>

            <tbody>
              <c:set var="total" value="${empty totalUsage ? 0 : totalUsage}" />
              
              <tr>
                <td>분쟁 유형 분류</td>
                <td>${cntBoonjang}</td>
                <td><fmt:formatNumber value="${total==0?0:(cntBoonjang*100.0/total)}" maxFractionDigits="1"/>%</td>
              </tr>
              
              <tr>
                <td>법적 위험 분석</td>
                <td>${cntLaw}</td>
                <td><fmt:formatNumber value="${total==0?0:(cntLaw*100.0/total)}" maxFractionDigits="1"/>%</td>
              </tr>

              <tr>
                <td>유사 판례 탐색</td>
                <td>${cntYusa}</td>
                <td><fmt:formatNumber value="${total==0?0:(cntYusa*100.0/total)}" maxFractionDigits="1"/>%</td>
              </tr>

              <tr>
                <td>승소율 측정</td>
                <td>${cntJogi}</td>
                <td><fmt:formatNumber value="${total==0?0:(cntJogi*100.0/total)}" maxFractionDigits="1"/>%</td>
              </tr>

              <tr class="table-secondary fw-bold">
                <td>합계</td>
                <td>${total}</td>
                <td>100%</td>
              </tr>
            </tbody>
          </table>


          <!-- ================= 도넛 스크립트 ================= -->
          <script>
          (function(){

            const data = [
              ${cntBoonjang},
              ${cntLaw},
              ${cntYusa},
              ${cntJogi},
            ];

            const total = data.reduce((a,b)=>a+b,0);

            Chart.register(ChartDataLabels);

            new Chart(document.getElementById('serviceDonut'),{
              type:'doughnut',
              data:{
                labels:["분쟁유형","법적위험","유사판례","승소율 측정"],
                datasets:[{ data:data }]
              },
              options:{
                responsive:true,
                cutout:"65%",

                plugins:{
                  legend:{ position:'bottom' },

                  // ✅ 조각 위 숫자 표시 핵심
                  datalabels:{
                    color:"#000",
                    font:{ weight:"bold", size:13 },
                    formatter:(v)=>{
                      if(v===0) return "";
                      const pct=((v*100)/total).toFixed(1);
                      return v+"회\n("+pct+"%)";
                    }
                  }
                }
              }
            });

          })();
          </script>

        </div>
      </div>
    </div>

  </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
