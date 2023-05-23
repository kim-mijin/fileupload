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
	
	//요청값 잘 넘어오는지 확인
	System.out.println(request.getParameter("boardNo") + " <--modifyBoard param boardNo");
	System.out.println(request.getParameter("boardFileNo") + " <--modifyBoard param boardFileNo");
	
	//요청값 유효성 검사: 요청값이 null이거나 공백이면 boardList로 리다이렉션
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
			|| request.getParameter("boardFileNo") == null || request.getParameter("boardFileNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
	
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	
	//2.모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, b.createdate createdate "
						+"FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no = ? AND f.board_file_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	stmt.setInt(2, boardFileNo);
	ResultSet rs = stmt.executeQuery();
	//쿼리의 결과인 rs를 HashMap<>타입으로 저장한다
	HashMap<String, Object> map = new HashMap<String, Object>();
	if(rs.next()){
		map.put("boardNo", rs.getInt("boardNo"));
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("boardFileNo", rs.getInt("boardFileNo"));
		map.put("originFilename", rs.getString("originFilename"));
		map.put("createdate", rs.getString("createdate").substring(0, 11));
	}
	System.out.println(map + " <--modifyBoard map");
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>modify board</title>
	<!-- 부트스트랩5 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<!----------- 네비게이션 ----------->
	<nav>
	<ul>
		<li><a href="<%=request.getContextPath()%>/boardList.jsp">목록으로</a></li>
		<li><a href="<%=request.getContextPath()%>/login.jsp">로그인</a></li>
	</ul>
	</nav>
	
	<!----------- 오류메시지 ----------->
	<%
		if(request.getParameter("msg") != null){
	%>
			<span><%=request.getParameter("msg")%></span>
	<%
		}
	%>
	
	<!----------- 게시글 수정폼 ----------->
	<h1>게시글 및 첨부파일 수정</h1>
	<form method="post" enctype="multipart/form-data" action="<%=request.getContextPath()%>/modifyBoardAction.jsp">
		<input type="hidden" name="boardNo" value="<%=map.get("boardNo")%>">
		<input type="hidden" name="boardFileNo" value="<%=map.get("boardFileNo")%>">
		<table class="table table-bordered">
			<tr>
				<th>제목</th>
				<td>
					<textarea rows="3" cols="50" name="boardTitle" required="required"><%=(String)map.get("boardTitle")%></textarea>
				</td>
			</tr>
			<tr>
				<th>수정전 파일 : <%=map.get("originFilename") %></th>
				<td>
					<input type="file" name="boardFile">
				</td>
			</tr>
		</table>
		<!-- 수정버튼 -->
		<button class="btn" type="submit">수정</button>
	</form>
</body>
</html>