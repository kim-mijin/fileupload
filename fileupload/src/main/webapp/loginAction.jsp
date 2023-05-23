<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="vo.*" %>
<%@ page import="java.sql.*" %>
<%
	//1.컨트롤러계층
	//요청값이 잘 넘어오는지 확인
	System.out.println(request.getParameter("memberId") + " <--loginAction param memberId");
	System.out.println(request.getParameter("memberPw") + " <--loginAction param memberPw");
	
	//요청값 유효성검사: 요청값이 null이거나 공백이면 로그인폼으로 리다이렉션, 메시지넘기기
	String msg = null;
	if(request.getParameter("memberId") == null || request.getParameter("memberId").equals("")
			|| request.getParameter("memberPw") == null || request.getParameter("memberPw").equals("")){
		System.out.println("ID 혹은 PW 미입력 <-- loginAction");
		msg = URLEncoder.encode("ID 혹은 PW를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/login.jsp?msg="+msg);
		return;
	}
	
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	Member loginMember = new Member(); //요청값을 저장한 memberId, memberPw변수를 vo타입입 Member타입으로 저장
	loginMember.setMemberId(memberId);
	loginMember.setMemberPw(memberPw);
	
	//2.모델계층
	//DB접속하기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String sql = "SELECT member_id memberId, member_pw memberPw from member where member_id = ? and member_pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, loginMember.getMemberId());
	stmt.setString(2, loginMember.getMemberPw());
	ResultSet rs = stmt.executeQuery();
	if(rs.next()){
		session.setAttribute("loginMember", loginMember);
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		System.out.println("loginAction 로그인성공");
	} else {
		msg = URLEncoder.encode("ID 혹은 PW를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/login.jsp?msg="+msg);
	}
	
	
%>