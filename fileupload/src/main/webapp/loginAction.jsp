<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%
	//요청값이 잘 넘어오는지 확인
	System.out.println(request.getParameter("memberId") + " <--loginAction param memberId");
	System.out.println(request.getParameter("memberPw") + " <--loginAction param memberPw");
	
	String errMsg = null;
	if(request.getParameter("memberId").equals("") || request.getParameter("memberId") == null
			|| request.getParameter("memberPw").equals("") || request.getParameter("memberPw") == null){
		System.out.println("ID 혹은 PW 미입력 <-- loginAction");
		errMsg = URLEncoder.encode("ID 혹은 PW를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/login.jsp?errMst="+errMsg);
		return;
	}
%>