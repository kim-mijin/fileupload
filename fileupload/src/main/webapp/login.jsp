<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>login</title>
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
	
	<!----------- 로그인 ----------->
	<h1>로그인</h1>
	<form action="<%=request.getContextPath()%>/loginAction.jsp">
		<table>
			<tr>
				<th>아이디</th>
				<td><input type="text" name="memberId"></td>
			</tr>
			<tr>
				<th>비밀번호</th>
				<td><input type="password" name="memberPw"></td>
			</tr>
		</table>
		<button type="submit">로그인</button>
	</form>
</body>
</html>