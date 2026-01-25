<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<h2>${detail.serviceType} 사건</h2>
<div>사건번호: ${detail.serviceCode}</div>
<div>날짜: <fmt:formatDate value="${detail.analysisDate}" pattern="yyyy-MM-dd HH:mm"/></div>
<hr/>
<h3>입력</h3>
<pre>${detail.input}</pre>
<h3>출력</h3>
<pre>${detail.output}</pre>
