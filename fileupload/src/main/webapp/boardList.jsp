<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	//boardList: 게시글 누구나 접근 가능
	//1.컨트롤러계층
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
	
	//2.모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//--------------------------------------PDF 페이지네이션------------------------------------------
	int lastPage = 0;
	int totalRow = 0; // lastPage를 구하기 위해 board(게시글)의 totalCount 구하기
	
	String totalRowSql = "SELECT COUNT(*) cnt FROM board";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("cnt");
	}
	System.out.println(totalRow + " <--boardList totalRow");
	lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage !=0 ){ //totalRow가 rowPerPage로 나누어 떨어지지 않으면 마지막 페이지는 +1
		lastPage = lastPage + 1;
	}
	
	int pagePerPage = 10; //한페이지 블럭에 들어가는 페이지의 수
	/*
		currentPage	startPage	endPage
		1~10		1			10
		11~20		11			20
		21~30		21			30
	*/
	int startPage = ((currentPage-1)/pagePerPage)*pagePerPage + 1; //페이지 블럭의 첫페이지
	int endPage = startPage + pagePerPage - 1; //페이지 블럭의 마지막 페이지
	if(endPage > lastPage){ //페이지블럭의 마지막페이지가 실제마지막페이지보다 큰 경우에는 실제마지막페이지를 해당 페이지블럭의 마지막 페이지로 한다
		endPage = lastPage;
	}
	System.out.println(startPage + " <--boardList startPage");
	System.out.println(endPage + " <--boardList endPage");
	//--------------------------------------PDF 목록 출력------------------------------------------
	/*
		SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path path, b.createdate createdate 
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		ORDER BY b.createdate DESC
		LIMIT ?, ?
		
		*게시글에 file이 없는 경우는 OUTER JOIN 사용해야 한다*
	*/
	
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, f.path path, b.createdate createdate "
				+"FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC LIMIT ?, ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, startRow);
	stmt.setInt(2, rowPerPage);
	System.out.println(stmt + " <--boardList stmt");
	ResultSet rs = stmt.executeQuery();
	//쿼리의 결과인 rs를 ArrayList<HashMap<>>타입을 저장한다
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
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
	<title>board list</title>
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
		<li><a href="<%=request.getContextPath()%>/logoutAction.jsp">로그아웃</a></li>
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

	<!----------------------------------------------- 게시글목록 시작 ---------------------------------------------------------->
	<h1>PDF 자료 목록</h1>
	<!-- 게시글 입력버튼 -->
	<a href="<%=request.getContextPath()%>/addBoard.jsp">글쓰기</a>
	
	<!-- 게시글 목록 테이블 -->
	<table class="table table-bordered">
		<tr>
			<th>게시글번호</th>
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
					<td><%=(Integer)m.get("boardNo")%></td>
					<td><%=(String)m.get("boardTitle")%></td>
					<td><a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("originFilename")%>">
						<!-- a태그 다운로드 속성을 이용하면 참조주소를 다운로드 한다 -->
						<!-- 파일 다운로드 경로 -->
						<%=(String)m.get("originFilename")%>
						</a>
					</td>
					<td><%=(String)m.get("createdate")%></td>
					<td><a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">수정</a></td>
					<td><a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a></td>
				</tr>
		<%
			}
		%>
	</table>
	<!-- --------------------------------------페이지네이션------------------------------------------ -->
	<ul class="pagination">
		<!-- 첫페이지 -->
		<li class="page-item">
			<a class="page-link" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=1">&#60;&#60;</a>
		</li>
		<!-- 이전 페이지블럭 (startPage - 1) -->
		<%
			if(startPage > 1){ //startPage가 1인 페이지블럭에서는 '이전'버튼 비활성화
		%>
				<li class="page-item disabled"><a class="page-link" href="#">&#60;</a></li>
		<%	
			} else {
		%>
				<li class="page-item">
					<a class="page-link" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=startPage-1%>">&#60;</a>
				</li>
		<%
			}
		%>
		
		<!-- 현재페이지 -->
		<%
			for(int i=startPage; i<=endPage; i+=1){ //startPage~endPage 사이의 페이지i 출력하기
				if(currentPage == i){ //현재페이지와 i가 같은 경우에는 표시하기
		%>
				<li class="page-item active">
					<a class="page-link" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=i%>">
						<span class="sr-only"><%=i%></span>
					</a>
				</li>
		<%
				} else {
		%>
				<li class="page-item">
					<a class="page-link" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=i%>">
						<%=i%>
					</a>
				</li>
		<%	
				}
			}
		%>
		<!-- 다음 페이지블럭 (endPage + 1) -->
		<%
			if(lastPage == endPage){ //마지막페이지에서는 '다음'버튼 비활성화
		%>
				<li class="page-item disabled"><a class="page-link" href="#">&#62;</a></li>
		<%	
			} else {
		%>
				<li class="page-item">
					<a class="page-link" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=endPage+1%>">&#62;</a>
				</li>
		<%
			}
		%>
		
		<!-- 마지막페이지 -->
		<li class="page-item">
			<a class="page-link" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=lastPage%>">&#62;&#62;</a>
		</li>
	</ul>
	<!----------------------------------------------- 게시글목록 끝 ---------------------------------------------------------->
</body>
</html>