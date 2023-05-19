<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%
	// 원본 request를 객체를 cos api로 랩핑
	// new MultipartRequest(원본request, 업로드폴더, 최대파일사이즈byte, 인코딩, 중복이름정책)
   
	// 프로젝트안 upload폴더의 실제 물리적 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir + " <--dir");
	//결과: C:\html_work\fileupload\src\main\webapp\\upload <--dir

	int maxFileSize = 1024 * 1024 * 100; // 100Mbyte (1byte * 2024(2의10제곱) = 1Kbyte * 2024 = 1Mbyte)
	//하루 1000* 60 * 60 * 24 (1000밀리세컨즈 * 60초 * 60분 * 24시간)
   
	// 업로드 폴더내 동일한 이름이 있으면 뒤에 숫자를 추가 
	DefaultFileRenamePolicy fp = new DefaultFileRenamePolicy();
   
	MultipartRequest mreq = new MultipartRequest(request, dir, maxFileSize, "utf-8", fp);
%>