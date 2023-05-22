<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	//1.컨트롤러 계층
	//세션유효성검사
	if(session.getAttribute("loginMember") == null){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
	Object o = session.getAttribute("loginMember");
	Member loginMember = null; 
	if(o instanceof Member){
		loginMember = (Member)o;
	}
	String loginId = loginMember.getMemberId();
	String loginPw = loginMember.getMemberPw();
	System.out.println(loginId + " <--removeBoardAction loginId");
	System.out.println(loginPw + " <--removeBoardAction loginPw");
	
	//요청값 유효성검사
	request.setCharacterEncoding("utf-8");
	//요청값이 잘 넘어오는지 확인
	System.out.println(request.getParameter("boardNo"));
	System.out.println(request.getParameter("boardFileNo"));
	System.out.println(request.getParameter("password"));
	
	//유효성검사: boardNo나 password가 null이면 boardList, password 공백이면 remove폼
	if(request.getParameter("boardNo") == null || request.getParameter("boardFileNo") == null
		|| request.getParameter("password") == null){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	if(request.getParameter("password").equals("")) {
		response.sendRedirect(request.getContextPath()+"removeBoard.jsp?boardNo="+boardNo);
		return;
	}
	String password = request.getParameter("password");
	
	System.out.println(boardNo + " <--removeBoardAction boardNo");
	// System.out.println(password + " <--removeBoardAction password");
	
	//2.모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//비밀번호 확인
	String pwSql = "SELECT COUNT(*) cnt FROM member WHERE member_id = ? and member_pw = PASSWORD(?)";
	PreparedStatement pwStmt = conn.prepareStatement(pwSql);
	pwStmt.setString(1, loginId);
	pwStmt.setString(2, password);
	ResultSet pwRs = pwStmt.executeQuery();
	if(!pwRs.next()){ //세션비밀번호와 입력한 비밀번호가 다르면 삭제폼으로 리다이렉션
		System.out.println("removeBoardAction 입력 비밀번호와 로그인 비밀번호 상이");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo);
		return;
	}
	
	//로그인 비밀번호와 입력비밀번호가 같을 경우 게시글삭제 쿼리실행
	String removeSql = "DELETE FROM board WHERE board_no = ? ";
	PreparedStatement removeStmt = conn.prepareStatement(removeSql);
	removeStmt.setInt(1, boardNo);
	System.out.println(removeStmt + " <--removeBoardAction stmt");
	int removeRow = removeStmt.executeUpdate();

	if(removeRow == 1){ //게시글 삭제 성공한 경우(영향받은 행 1)
		System.out.println(removeRow + " <-- removeBoardAction 게시글삭제 성공");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	} else { //게시글 삭제 실패한 경우
		System.out.println(removeRow + " <-- removeBoardAction 게시글삭제 실패");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp?boardNo="+boardNo+"&boardFileNo"+boardFileNo);
	}
%>