<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	//로그인이 되어있으면 로그아웃
	String msg = null;
	if(session.getAttribute("loginMember") != null){
		session.invalidate();
		System.out.println("로그아웃");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
	}
%>