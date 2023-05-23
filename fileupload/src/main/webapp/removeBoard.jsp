<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vo.*"%>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%
	//1.컨트롤러 계층
	//세션유효성검사: 로그인 상태가 아니면 해당 페이지 접근 불가
	String msg = null;
	if(session.getAttribute("loginMember") == null){
		msg = URLEncoder.encode("로그인 후 이용해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
		return;
	}

	//요청값이 잘 넘어오는지 확인하기
	System.out.println(request.getParameter("boardNo") + " <--removeBoard param boardNo");
	System.out.println(request.getParameter("boardFileNo") + " <--removeBoard param boardFileNo");
	
	//요청값 유효성 검사: 요청값이 null이거나 공백이면 boardList로 리다이렉션
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
		|| request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	
	// 2.모델계층: boardTitle, originFilename 받아오기
	//DB접속하기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/*
		SELECT b.board_title boardTitle, f.origin_filename originFileName, f.save_filename saveFilename
		FROM board b inner join board_file f
		ON b.board_no = f.board_no
		WHERE b.board_no = ?
	*/
	String sql = "SELECT b.board_title boardTitle, f.origin_filename originFileName, f.save_filename saveFilename "
					+ "FROM board b inner join board_file f "
					+ "ON b.board_no = f.board_no WHERE b.board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	System.out.println(stmt + " <--removeBoard stmt");
	ResultSet rs = stmt.executeQuery();
	
	//ResultSet -> HashMap
	HashMap<String, Object> map = new HashMap<String, Object>();
	if(rs.next()){
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("originFilename", rs.getString("originFilename"));
		map.put("saveFilename", rs.getString("saveFilename")); //저장된 첨부파일을 삭제하기 위해서 removeBoardAction으로 값 넘기기
	}
	System.out.println(map + " <--removeBoard map");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>remove board</title>
</head>
<body>
	<!----------- 네비게이션 ----------->
	<nav>
	<ul>
		<li><a href="<%=request.getContextPath()%>/boardList.jsp">목록으로</a></li>
		<li><a href="<%=request.getContextPath()%>/login.jsp">로그인</a></li>
	</ul>
	</nav>
	
	<!----------- 메시지 ----------->
	<%
		if(request.getParameter("msg") != null){
	%>
			<span><%=request.getParameter("msg")%></span>
	<%
		}
	%>
	
	<!----------- 게시글 삭제폼 ----------->
	<h1>게시글 및 첨부파일 삭제</h1>
	<form method="post" enctype="multipart/form-data" action="<%=request.getContextPath()%>/removeBoardAction.jsp">
		<input type="hidden" name="boardNo" value="<%=boardNo%>">
		<input type="hidden" name="boardFileNo" value="<%=boardFileNo%>"><!-- 리다이렉션을 위해 넘기기 -->
		<input type="hidden" name="saveFilename" value="<%=map.get("saveFilename")%>">
		<table class="table table-bordered">
			<tr>
				<th>제목</th>
				<td><input type="text" name="boardTitle" value="<%=(String)map.get("boardTitle")%>" readonly></td>
			</tr>
			<tr>
				<th>첨부파일</th>
				<td><%=(String)map.get("originFilename")%></td>
			</tr>
			<tr>
				<th>비밀번호</th>
				<td><input type="password" name="password"></td>
			</tr>
		</table>
		<!-- 삭제버튼 -->
		<button type="submit">삭제</button>
	</form>
</body>
</html>