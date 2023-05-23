<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="vo.*" %>
<%
	//세션유효성검사: 로그인 상태가 아니면 해당 페이지 접근 불가
	String msg = URLEncoder.encode("로그인 후 이용해주세요", "utf-8");
	if(session.getAttribute("loginMember") == null){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
		return;
	}
	Object o = session.getAttribute("loginMember");
	Member loginMember = null; 
	if(o instanceof Member){
		loginMember = (Member)o;
	}
	String loginId = loginMember.getMemberId();
	System.out.println(loginId + " <--addBoard loginId");

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
	<!----------- 네비게이션 ----------->
	<nav>
	<ul>
		<li><a href="<%=request.getContextPath()%>/boardList.jsp">목록으로</a></li>
		<li><a href="<%=request.getContextPath()%>/login.jsp">로그인</a></li>
	</ul>
	</nav>
	
	<!----------- 에러메시지 ----------->
	<%
		if(request.getParameter("msg") != null){
	%>
			<span><%=request.getParameter("msg")%></span>
	<%
		}
	%>
	
	<!----------- 게시글 입력폼 ----------->
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
					<input type="text" name="memberId" value="<%=loginId%>" readonly="readonly">
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