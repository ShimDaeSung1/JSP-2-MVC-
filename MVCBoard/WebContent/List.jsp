<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>파일 첨부형 게시판</title>
<style>
a {
	text-decoration: none;
}
</style>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">
<script
	src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.slim.min.js"></script>
<script
	src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="/css/style.css">
</head>
<body>
	<div class="container">
		<h2>파일 첨부형 게시판 - 목록 보기(List)</h2>

		<!-- 검색 폼 -->
		<form method="get">
			<table width="100%">
				<tr>
					<td align="center"><select name="searchField">
							<option value="title">제목</option>
							<option value="content">내용</option>
					</select> <input type="text" name="searchWord" class="form-control"
						style="width: 30%; display: inline-block;" /> <input type="submit"
						value="검색하기" class="btn bg-color2"
						style="width: 15%; display: inline-block;" /></td>
				</tr>
			</table>
		</form>

		<!-- 목록 테이블 -->
		<table class="table" >
			<tr class="bg-color1">
				<th width="10%">번호</th>
				<th width="*">제목</th>
				<th width="15%">작성자</th>
				<th width="10%">조회수</th>
				<th width="15%">작성일</th>
				<th width="8%">첨부</th>
			</tr>
			<c:choose>
				<c:when test="${ empty boardLists }">
					<!-- 게시물이 없을 때 -->
					<tr>
						<td colspan="6" align="center">등록된 게시물이 없습니다^^*</td>
					</tr>
				</c:when>
				<c:otherwise>
					<!-- 게시물이 있을 때 -->
					<c:forEach items="${ boardLists }" var="row" varStatus="loop">
						<tr align="center">
							<td>
								<!-- 번호 --> ${ map.totalCount - (((map.pageNum-1) * map.pageSize) + loop.index)}
							</td>
							<td align="left">
								<!-- 제목(링크) --> <a href="../view.do?idx=${ row.idx }">${ row.title }</a>
							</td>
							<td>${ row.name }</td>
							<!-- 작성자 -->
							<td>${ row.visitcount }</td>
							<!-- 조회수 -->
							<td>${ row.postdate }</td>
							<!-- 작성일 -->
							<td>
								<!-- 첨부 파일 --> <c:if test="${ not empty row.ofile }">
									<a
										href="/download.do?ofile=${ row.ofile }&sfile=${ row.sfile }&idx=${ row.idx }">[Down]</a>
								</c:if>
							</td>
						</tr>
					</c:forEach>
				</c:otherwise>
			</c:choose>
		</table>

		<!-- 하단 메뉴(바로가기, 글쓰기) -->
		<table  width="100%">
			<tr align="center">
				<td>${ map.pagingImg }</td>
				<td width="100"><button type="button"
						onclick="location.href='/write.do';">글쓰기</button></td>
			</tr>
		</table>
	</div>

</body>
</html>