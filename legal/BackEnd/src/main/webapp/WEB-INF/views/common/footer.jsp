<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.Year" %>

<style>
.footer {
  background: #ffffff;
  border-top: 1px solid #e5e7eb;
  margin-top: 80px;
}
.footer-inner {
  max-width: 1280px;
  margin: 0 auto;
  padding: 32px 24px;
}
.footer-top {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
  justify-content: space-between;
}
.footer-bottom {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #f3f4f6;
  text-align: center;
  font-size: 12px;
  color: #9ca3af;
}

/* ===== Footer link style reset ===== */
.footer a,
.footer a:visited,
.footer a:hover,
.footer a:active {
  color: #6b7280;        /* 기존 footer 글자색 */
  text-decoration: none; /* 밑줄 제거 */
}

/* hover 시만 살짝 강조하고 싶으면 */
.footer a:hover {
  color: #111827;
}
</style>
<%
  String ctx = request.getContextPath();
  int currentYear = Year.now().getValue();
%>

<!-- ✅ Footer -->
<footer class="footer">
  <div class="footer-inner">

    <div class="footer-top">
      <div class="footer-logo">
        <span class="text-lg">⚖️</span>
        <span>© <%= currentYear %> LegalRisk AI</span>
      </div>

      <nav class="footer-nav">
<%--         <a href="<%= ctx %>/boonjang">분쟁유형</a> --%>
        <a href="<%= ctx %>/law">법적위험</a>
        <a href="<%= ctx %>/yusa">유사판례</a>
        <a href="<%= ctx %>/jogi">조기위험</a>
      </nav>

      <div class="footer-right">
        <span>문의: support@legalrisk.ai</span>
        <a href="https://github.com/DeepCodeLogicAI/LegalRiskAI.git"
           target="_blank" rel="noopener noreferrer">
          🐙 GitHub
        </a>
      </div>
    </div>

    <div class="footer-bottom">
      본 서비스는 법률 정보 제공 목적으로만 사용되며, 전문적인 법률 자문을 대체하지 않습니다.
    </div>

  </div>
</footer>
