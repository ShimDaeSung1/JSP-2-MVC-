<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">
  <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js"></script>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<div class="container">
<h2>파일 첨부형 게시판- 상세보기(View)</h2>

<table class="table">
	<colgroup>
		<col width="15%"/><col width="35%"/>
		<col width="15%"/><col width="*"/>
	</colgroup>
	
	<!-- 게시글 정보 -->
	<tr>
		<td class="bg-color1">번호</td> <td>${dto.idx}</td>
		<td class="bg-color1">작성자</td> <td>${dto.name}</td>
	</tr>
	<tr>
		<td class="bg-color1">작성일</td> <td>${dto.postdate}</td>
		<td class="bg-color1">조회수</td> <td>${dto.visitcount}</td>
	</tr>
	<tr>
		<td class="bg-color1">제목</td>
		<td colspan="3" height="100">${dto.content}</td>
	</tr>
	<!-- 첨부파일 -->
	<tr>
		<td class="bg-color1">첨부파일</td>
		<td>
			<c:if test="${not empty dto.ofile}">
			${dto.ofile}
			<a href="/download.do?ofile=${dto.ofile}&sfile=${dto.sfile}&idx=${dto.idx}">[다운로드]</a>
			</c:if>
		</td>
		<td class="bg-color1">다운로드수</td>
		<td>${dto.downcount}</td>
	</tr>
	
	<!-- 하단메뉴 (버튼) -->
	<tr>
		<td colspan="4" align="center">
			<button type = "button" onclick="location.href= '/pass.do?mode=edit&idx=${param.idx}';">수정하기</button>
			<button type = "button" onclick="location.href= '/pass.do?mode=delete&idx=${param.idx}';">삭제하기</button>
			<button type = "button" onclick = "location.href='/list.do';">목록 바로가기</button> 
		</td>
	</tr>
</div>
</table>
</body>
</html>