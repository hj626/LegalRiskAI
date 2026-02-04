<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="com.oracle.Legal.dto.AccountDto" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>LEGALAI - 메인</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />

<!-- ✅ 로그인 전 랜딩(Tailwind) -->
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">

<!-- ✅ 로그인 후 기존 Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
  body { background:#f6f7fb; font-family:'Inter','Noto Sans KR',sans-serif; scroll-behavior:smooth; }

  /* ===== Bootstrap(로그인 후) 기존 스타일 ===== */
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
    min-height: 220px;
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
    background: #fff;
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
    font-size: 20px;
  }

  /* ===== Tailwind 랜딩 보조 스타일 ===== */
  .slide-transition { transition: transform 0.8s cubic-bezier(0.65, 0, 0.35, 1); }
  .feature-card2 { transition: all 0.5s ease; }
  .feature-card2.active { border-color: #dbeafe; box-shadow: 0 20px 50px rgba(37, 99, 235, 0.1); opacity: 1; transform: scale(1); }
  .feature-card2.inactive { border-color: transparent; opacity: 0.5; transform: scale(0.95); filter: grayscale(1); }
</style>
</head>

<body class="d-flex flex-column min-vh-100">

<% if (!loggedIn) { %>

  <!-- ===== 로그인 전: Tailwind 랜딩 ===== -->
  <div class="bg-slate-50 text-slate-900 overflow-x-hidden">

    <main>
      <!-- Hero Slider Section -->
<!-- Hero Slider Section -->
<section class="relative h-screen min-h-[700px] w-full overflow-hidden bg-white">
  <div id="hero-container" class="flex h-full slide-transition">

    <!-- Slide 1 -->
    <div class="relative w-full h-full flex-shrink-0 flex flex-col lg:flex-row">
      <div class="w-full lg:w-1/2 h-full flex items-center bg-slate-50 px-6 pt-32 pb-16 md:px-16 lg:px-24">
        <div class="max-w-xl">
          <span class="inline-block bg-blue-600/10 text-blue-600 text-[10px] font-black uppercase tracking-widest px-3 py-1.5 rounded-full mb-8">판례 분석 • 실시간 리스크</span>
          <h3 class="text-blue-600 font-bold text-lg md:text-xl mb-4">스마트한 법률 비서, LexAI</h3>

          <p class="text-slate-700 font-black text-base md:text-lg mb-2">
            <%= (displayName == null || displayName.isBlank()) ? "고객" : displayName %>님
          </p>

          <h1 class="text-4xl md:text-5xl lg:text-7xl font-black text-slate-900 mb-8 leading-[1.1] whitespace-pre-line">AI 법률 분석의<br>새로운 패러다임</h1>
          <p class="text-lg text-slate-500 mb-12 leading-relaxed max-w-lg">방대한 판례 데이터와 법률 리스크를 실시간으로 분석하여 신속한 의사결정을 지원합니다.</p>

          <a href="<c:url value='/login'/>"
             class="group bg-blue-600 text-white px-8 py-4 rounded-2xl font-black shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all flex items-center w-fit">
            솔루션 시작하기
            <svg class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
          </a>
        </div>
      </div>
      <div class="w-full lg:w-1/2 h-full relative overflow-hidden">
        <img src="${pageContext.request.contextPath}/image/photo1.jpg"
     class="w-full h-full object-cover">
        <div class="absolute inset-0 bg-blue-900/10 mix-blend-multiply"></div>
      </div>
    </div>

    <!-- Slide 2 -->
    <div class="relative w-full h-full flex-shrink-0 flex flex-col lg:flex-row">
      <div class="w-full lg:w-1/2 h-full flex items-center bg-slate-50 px-6 pt-32 pb-16 md:px-16 lg:px-24">
        <div class="max-w-xl">
          <span class="inline-block bg-blue-600/10 text-blue-600 text-[10px] font-black uppercase tracking-widest px-3 py-1.5 rounded-full mb-8">분쟁 매칭 • 승소 예측</span>
          <h3 class="text-blue-600 font-bold text-lg md:text-xl mb-4">유사 판례와 승소율 예측</h3>

          <p class="text-slate-700 font-black text-base md:text-lg mb-2">
            <%= (displayName == null || displayName.isBlank()) ? "고객" : displayName %>님
          </p>

          <h1 class="text-4xl md:text-5xl lg:text-7xl font-black text-slate-900 mb-8 leading-[1.1] whitespace-pre-line">정밀한 분쟁 유형<br>분석 엔진</h1>
          <p class="text-lg text-slate-500 mb-12 leading-relaxed max-w-lg">사건의 핵심 쟁점을 파악하고 유사 판례를 매칭해 대응 방향을 돕습니다.</p>

          <a href="<c:url value='/login'/>"
             class="bg-blue-600 text-white px-8 py-4 rounded-2xl font-black shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all inline-flex">
            예측 모델 보기
          </a>
        </div>
      </div>
      <div class="w-full lg:w-1/2 h-full relative overflow-hidden">
        <img src="${pageContext.request.contextPath}/image/photo2.jpg"
     class="w-full h-full object-cover">
        <div class="absolute inset-0 bg-blue-900/10 mix-blend-multiply"></div>
      </div>
    </div>

    <!-- Slide 3 -->
    <div class="relative w-full h-full flex-shrink-0 flex flex-col lg:flex-row">
      <div class="w-full lg:w-1/2 h-full flex items-center bg-slate-50 px-6 pt-32 pb-16 md:px-16 lg:px-24">
        <div class="max-w-xl">
          <span class="inline-block bg-blue-600/10 text-blue-600 text-[10px] font-black uppercase tracking-widest px-3 py-1.5 rounded-full mb-8">자동 알림 • 계약 분석</span>
          <h3 class="text-blue-600 font-bold text-lg md:text-xl mb-4">사용자 편의 중심 인터페이스</h3>

          <p class="text-slate-700 font-black text-base md:text-lg mb-2">
            <%= (displayName == null || displayName.isBlank()) ? "고객" : displayName %>님
          </p>

          <h1 class="text-4xl md:text-5xl lg:text-7xl font-black text-slate-900 mb-8 leading-[1.1] whitespace-pre-line">통합 리스크 관리<br>대시보드</h1>
          <p class="text-lg text-slate-500 mb-12 leading-relaxed max-w-lg">중요 리스크를 한 곳에서 모니터링하고 관리할 수 있습니다.</p>

          <a href="<c:url value='/login'/>"
             class="bg-blue-600 text-white px-8 py-4 rounded-2xl font-black shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all inline-flex">
            대시보드 체험
          </a>
        </div>
      </div>
      <div class="w-full lg:w-1/2 h-full relative overflow-hidden">
        <img src="${pageContext.request.contextPath}/image/photo3.jpg"
     class="w-full h-full object-cover">
        <div class="absolute inset-0 bg-blue-900/10 mix-blend-multiply"></div>
      </div>
    </div>

  </div>

  <!-- Hero Controls -->
  <div class="absolute bottom-12 right-6 md:right-16 lg:right-24 flex items-center gap-12 z-20">
    <div class="flex gap-4">
      <button type="button" onclick="moveHero(-1)" class="w-14 h-14 rounded-2xl border border-slate-200 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white transition-all shadow-sm">
        <svg class="w-6 h-6 text-slate-900" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M15 19l-7-7 7-7" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
      </button>
      <button type="button" onclick="moveHero(1)" class="w-14 h-14 rounded-2xl border border-slate-200 bg-white/50 backdrop-blur-sm flex items-center justify-center hover:bg-white transition-all shadow-sm">
        <svg class="w-6 h-6 text-slate-900" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M9 5l7 7-7 7" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
      </button>
    </div>

    <div id="hero-indicators" class="hidden sm:flex gap-2">
      <div class="indicator h-1 w-12 bg-blue-600 rounded-full transition-all duration-500"></div>
      <div class="indicator h-1 w-4 bg-slate-200 rounded-full transition-all duration-500"></div>
      <div class="indicator h-1 w-4 bg-slate-200 rounded-full transition-all duration-500"></div>
    </div>
  </div>
</section>

<!-- ✅ 슬라이더 JS는 hero 섹션 바로 아래에! (중요) -->
<script>
(function () {

  /* ======================
     HERO SLIDER
  ====================== */
  let heroIdx = 0;
  const heroCount = 3;

  function updateHero() {
    const container = document.getElementById('hero-container');
    const indicators = document.querySelectorAll('#hero-indicators .indicator');
    if (!container) return;

    container.style.transform = 'translateX(-' + (heroIdx * 100) + '%)';

    indicators.forEach((ind, i) => {
      ind.classList.toggle('bg-blue-600', i === heroIdx);
      ind.classList.toggle('bg-slate-200', i !== heroIdx);
      ind.style.width = (i === heroIdx) ? '48px' : '16px';
    });
  }

  window.moveHero = function(dir) {
    heroIdx = (heroIdx + dir + heroCount) % heroCount;
    updateHero();
  };



  /* ======================
     FEATURE SLIDER (아래 3개)
  ====================== */
  let featureIdx = 0;

  window.moveFeature = function(dir) {
    const cards = document.querySelectorAll('.feature-card2');
    const track = document.getElementById('feature-track');
    if (!cards.length || !track) return;

    // ✅ 무한 루프
    featureIdx = (featureIdx + dir + cards.length) % cards.length;

    const width = cards[0].getBoundingClientRect().width;
    const gap = 24;

    track.style.transform =
      'translateX(-' + (featureIdx * (width + gap)) + 'px)';

    cards.forEach((card, i) => {
      card.classList.toggle("active", i === featureIdx);
      card.classList.toggle("inactive", i !== featureIdx);
    });
  };


  /* ======================
     INIT
  ====================== */
  function init() {
    updateHero();
    setInterval(() => moveHero(1), 8000);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
</script>


      <!-- Features Slider Section -->
      <section id="features" class="py-32 bg-slate-50 relative overflow-hidden">
        <div class="max-w-7xl mx-auto px-6">
          <div class="flex flex-col lg:flex-row gap-16 items-center">
            <div class="lg:w-1/3 relative min-h-[340px]">
  <h4 class="text-blue-600 font-black tracking-widest uppercase text-xs mb-4">
    CORE TECHNOLOGY
  </h4>

  <h2 class="text-4xl font-black text-slate-900 mb-8 leading-tight">
    전문성을 더하는<br>혁신적인 법률 도구
  </h2>

  <!-- 버튼을 아래로 내리기 위한 빈 공간(버튼 자리 확보) -->
  <div class="h-24"></div>

  <!-- ✅ 버튼: 왼쪽 컬럼 하단에 고정 -->
  <div class="absolute left-0 bottom-0 flex items-center gap-4 z-50">
    <button type="button" onclick="moveFeature(-1)"
      class="w-12 h-12 rounded-full border border-slate-200 bg-white flex items-center justify-center hover:bg-blue-600 hover:text-white transition-all">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path d="M15 19l-7-7 7-7" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    </button>

    <button type="button" onclick="moveFeature(1)"
      class="w-12 h-12 rounded-full border border-slate-200 bg-white flex items-center justify-center hover:bg-blue-600 hover:text-white transition-all">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path d="M9 5l7 7-7 7" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    </button>
  </div>
</div>


            <div class="lg:w-2/3 relative overflow-visible">
              <div id="feature-track" class="flex gap-6 slide-transition" style="transform: translateX(0px);">
                <div class="feature-card2 active min-w-[320px] md:min-w-[380px] bg-white p-10 rounded-[40px] border-2">
                  <div class="w-16 h-16 bg-blue-50 rounded-2xl flex items-center justify-center text-blue-600 mb-10">
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" strokeWidth="2"/></svg>
                  </div>
                  <h3 class="text-2xl font-black text-slate-900 mb-4">스마트 판례 검색</h3>
                  <p class="text-slate-500 text-lg leading-relaxed">자연어 질문에서도 핵심 법리를 찾아 관련 판례를 제시합니다.</p>
                </div>

                <div class="feature-card2 inactive min-w-[320px] md:min-w-[380px] bg-white p-10 rounded-[40px] border-2">
                  <div class="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center text-blue-600 mb-10">
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M13 10V3L4 14h7v7l9-11h-7z" strokeWidth="2"/></svg>
                  </div>
                  <h3 class="text-2xl font-black text-slate-900 mb-4">실시간 리스크 진단</h3>
                  <p class="text-slate-500 text-lg leading-relaxed">문서/상황의 법적 허점을 빠르게 식별해 리스크를 줄입니다.</p>
                </div>

                <div class="feature-card2 inactive min-w-[320px] md:min-w-[380px] bg-white p-10 rounded-[40px] border-2">
                  <div class="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center text-blue-600 mb-10">
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7" strokeWidth="2"/></svg>
                  </div>
                  <h3 class="text-2xl font-black text-slate-900 mb-4">비용 효율적 솔루션</h3>
                  <p class="text-slate-500 text-lg leading-relaxed">리서치 시간을 대폭 단축하여 비용 부담을 줄입니다.</p>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      <!-- ✅ CTA Section 삭제 완료 -->
    </main>
  </div>

<% } else { %>

  <!-- ===== 로그인 후: 기존 메인 화면 ===== -->
  <main class="container py-4 py-md-5 flex-grow-1">

    <div class="row g-4 mb-4">

      <!-- LEFT: 즐겨찾기 -->
      <div class="col-12 col-lg-8">
        <div class="card card-soft p-4 h-100">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
              <div class="fw-bold">즐겨찾기 목록</div>
              <div class="text-muted small">즐겨찾기로 저장된 항목만 표시됩니다</div>
            </div>
          </div>

          <div class="fav-scroll">
            <div class="table-responsive">
              <table class="table align-middle mb-0 fav-table">
                <thead>
                  <tr>
                    <th style="width:110px;">작성일자</th>
                    <th>사건 요약</th>
                    <th style="width:120px;">서비스 종류</th>
                    <th style="width:90px;">상세보기</th>
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
                          <td class="text-muted" style="white-space:nowrap;">
                            <c:choose>
                              <c:when test="${not empty f.analysisDate}">
                                <fmt:formatDate value="${f.analysisDate}" pattern="yyyy-MM-dd"/>
                              </c:when>
                              <c:otherwise>-</c:otherwise>
                            </c:choose>
                          </td>

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

                          <td>
                            <button type="button" class="btn btn-xs btn-outline-primary"
                              onclick="window.open(
                                '${pageContext.request.contextPath}/mypage/history/${f.serviceType}/${f.serviceCode}',
                                'detail_${f.serviceType}_${f.serviceCode}',
                                'width=900,height=700,scrollbars=yes'
                              )">
                              바로가기
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

      <!-- RIGHT: 환영 + 나의서비스 -->
      <div class="col-12 col-lg-4">

        <div class="welcome-card p-4 d-flex flex-column justify-content-between">
          <div style="position:relative; z-index:1;">
            <h3 class="fw-bold mb-2"><%= displayName %>님,<br/>환영합니다</h3>
            <p class="mb-0" style="color:rgba(255,255,255,.85);">
              LEGALAI 서비스를 이용해주셔서 감사합니다.<br/>
              스마트한 법률 비서가 업무를 지원합니다.
            </p>
          </div>
        </div>

        <div class="card card-soft p-4 mt-4">
          <div class="fw-bold mb-3" style="color:#5b4bff;">나의 서비스</div>
          <div class="row text-center g-2">
            <div class="col-3">
              <div class="fs-2 fw-bold">${cntBoonjang}회</div>
              <div class="text-muted small">분쟁</div>
            </div>
            <div class="col-3">
              <div class="fs-2 fw-bold">${cntLaw}회</div>
              <div class="text-muted small">법적</div>
            </div>
            <div class="col-3">
              <div class="fs-2 fw-bold">${cntYusa}회</div>
              <div class="text-muted small">유사</div>
            </div>
            <div class="col-3">
              <div class="fs-2 fw-bold">${cntJogi}회</div>
              <div class="text-muted small">승소율</div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <div class="row g-4">
      <div class="col-12 col-md-3">
        <div class="feature-card p-4">
          <div class="feature-ico mb-3">⚖️</div>
          <div class="fw-bold mb-1">분쟁</div>
          <div class="text-muted small">진행 중인 분쟁 사례에 대한 절차 안내와 전략 수립을 지원합니다.</div>
        </div>
      </div>

      <div class="col-12 col-md-3">
        <div class="feature-card p-4">
          <div class="feature-ico mb-3">⚠️</div>
          <div class="fw-bold mb-1">법적 리스크</div>
          <div class="text-muted small">계약서 및 사업 영역에서 잠재 리스크를 사전에 식별합니다.</div>
        </div>
      </div>

      <div class="col-12 col-md-3">
        <div class="feature-card p-4">
          <div class="feature-ico mb-3">🔍</div>
          <div class="fw-bold mb-1">유사판례</div>
          <div class="text-muted small">사건과 유사한 판례 및 관련 경향을 분석해드립니다.</div>
        </div>
      </div>

      <div class="col-12 col-md-3">
        <div class="feature-card p-4">
          <div class="feature-ico mb-3">💡</div>
          <div class="fw-bold mb-1">승소율 측정</div>
          <div class="text-muted small">사건 정보를 기반으로 승소 가능성을 예측하고 핵심 근거를 요약합니다.</div>
        </div>
      </div>
    </div>

  </main>

<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
