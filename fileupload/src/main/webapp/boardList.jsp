<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	//1.컨트롤러계층
	//session유효성검사: 로그인이 되어있으면 loginMember변수에 저장한다
	Object o = null;
	if(session.getAttribute("loginMember") != null){
		o = session.getAttribute("loginMember");
	}
	
	String loginMember = "";
	if(o instanceof String){
		loginMember = (String)o;
	}
	System.out.println(loginMember + " <--boardList loginMember");
	
	//요청값: currentPage(int)
	//요청값이 잘 넘어오는지 확인
	System.out.println(request.getParameter("currentPage") + " <--boardList param currentPage"); 
	
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	System.out.println(currentPage + " <--boardList currentPage");
	int startRow = (currentPage - 1)*rowPerPage;
	/*
		currentPage 	startRow	rowPerPage
		1				0			10
		2				10			10
		3				20			10
	*/
	
	//모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//--------------------------------------PDF 페이지네이션------------------------------------------
	int lastPage = 0;
	int totalRow = 0; // lastPage를 구하기 위해 totalCount 구하기
	
	//--------------------------------------PDF 목록 출력------------------------------------------
	/*
		SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path path, b.createdate createdate 
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		ORDER BY b.createdate DESC
		
		*게시글에 file이 없는 경우는 OUTER JOIN 사용해야 한다*
	*/
	
	String sql = "SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path path, b.createdate createdate "
				+"FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC ";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	//쿼리의 결과인 rs를 ArrayList<HashMap<>>타입을 저장한다
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		m.put("createdate", rs.getString("createdate").substring(0, 11));
		list.add(m);
	}
	System.out.println(list + " <--boardList list");

%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	<style>
		table, th, td {
			border: 1px solid #000000;
			border-collapse: collapse;
		}
	</style>
</head>
<body>
	<h1>PDF 자료 목록</h1>
	<table>
		<tr>
			<th>제목</th>
			<th>파일</th>
			<th>작성일</th>
			<th>수정</th><!-- 작성자가 아닐 경우 수정버튼 클릭시 로그인 화면을 리다이렉션 -->
			<th>삭제</th><!-- 작성자가 아닐 경우 삭제버튼 클릭시 로그인 화면을 리다이렉션 -->
		</tr>
		<%
			for(HashMap<String,Object> m : list){
		%>
				<tr>
					<td><%=(String)m.get("boardTitle")%></td>
					<td><a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("originFilename")%>">
						<!-- 파일 다운로드 경로 -->
						<%=(String)m.get("saveFilename")%>
						</a>
					</td>
					<td><%=(String)m.get("createdate")%></td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
		<%
			}
		%>
	</table>
</body>
</html>