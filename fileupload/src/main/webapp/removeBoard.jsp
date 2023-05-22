<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vo.*"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	//1.컨트롤러 계층
	
	//요청값이 잘 넘어오는지 확인하기
	System.out.println(request.getParameter("boardNo") + " <--removeBoardAction param boardNo");
	System.out.println(request.getParameter("boardFileNo") + " <--removeBoardAction param boardFileNo");
	
	//요청값 유효성 검사: 요청값이 null이거나 공백이면 boardList로 리다이렉션
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
		|| request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
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
		SELECT b.board_title boardTitle, f.origin_filename originFileName
		FROM board b inner join board_file f
		ON b.board_no = f.board_no
		WHERE b.board_no = ?
	*/
	String sql = "SELECT b.board_title boardTitle, f.origin_filename originFileName FROM board b inner join board_file f "
					+ "ON b.board_no = f.board_no WHERE b.board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	ResultSet rs = stmt.executeQuery();
	
	//ResultSet -> HashMap
	HashMap<String, Object> map = new HashMap<String, Object>();
	if(rs.next()){
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("originFilename", rs.getString("originFilename"));
	}
	System.out.println(map + " <--removeBoard map");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Remove Board</title>
</head>
<body>
	<h1>게시글 및 첨부파일 삭제</h1>
	<form method="post" enctype="multipart/form-date" action="<%=request.getContextPath()%>/removeBoardAction.jsp">
		<input type="hidden" name="boardNo" value="<%=boardNo%>">
		<input type="hidden" name="boardNo" value="<%=boardFileNo%>"><!-- 리다이렉션을 위해 넘기기 -->
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