<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%

%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>add board + file</title>
	<style>
		table, th, td {
			border: 1px solid #000000;
			border-collapse: collapse;
		}
	</style>
</head>
<body>
	<h1>PDF 자료 업로드</h1>
	<form action="<%=request.getContextPath()%>/addBoardAction.jsp" method="post" enctype="multipart/form-data">
	<!-- multipart/form-data형식은 반드시 post방식사용-->
		<table>
			<!-- 자료 업로드 제목글 -->
			<tr>
				<th>제목</th>
				<td>
					<textarea rows="3" cols="50" name="boardTitle" required="required"></textarea>
				</td>
			</tr>
			<!-- 자료 업로드 작성자 -->
			<tr>
				<th>작성자</th>
				<td>
					<input type="text" name="memberId" value="" readonly="readonly">
				</td>
			</tr>
			<!-- 자료 업로드 첨부파일 -->
			<tr>
				<th>첨부파일</th>
				<td>
					<input type="file" name="boardFile" required="required">
				</td>
			</tr>
		</table>
		<!-- 자료 업로드 버튼 -->
		<button type="submit">자료 업로드</button>
	</form>
</body>
</html>