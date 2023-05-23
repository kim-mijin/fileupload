<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="vo.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%
	//1.컨트롤러 계층
	//세션유효성검사: 로그인 상태가 아니면 해당 페이지 접근 불가
	String msg = null;
	if(session.getAttribute("loginMember") == null){
		msg = URLEncoder.encode("잘못된 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
		return;
	}
	
	//삭제시 비밀번호 확인을 위해서 세션정보 구하기
	Object o = session.getAttribute("loginMember");
	Member loginMember = null; 
	if(o instanceof Member){
		loginMember = (Member)o;
	}
	String loginPw = loginMember.getMemberPw();
	System.out.println(loginPw + " <--removeBoardAction loginPw");
	
	//MultipartRequest로 request 맵핑
	String dir = request.getServletContext().getRealPath("/upload"); //"*\\upload로 써도 가능"
	System.out.println(dir + " <--dir"); //결과: C:\html_work\fileupload\src\main\webapp\\upload
	int maxFileSize = 10 * 1024 * 1024; // 10Mbyte
	MultipartRequest mRequest = new MultipartRequest(request, dir, maxFileSize, "utf-8", new DefaultFileRenamePolicy());
	
	//요청값이 잘 넘어오는지 확인
	System.out.println(mRequest.getParameter("boardNo") + " <--removeBoardAction param boardNo");
	System.out.println(mRequest.getParameter("boardFileNo") + " <--removeBoardAction param boardFileNo");
	System.out.println(mRequest.getParameter("saveFilename") + " <--removeBoardAction param saveFilename");
	System.out.println(mRequest.getParameter("password") + " <--removeBoardAction param password");
	
	//유효성검사: boardNo나 password가 null이면 boardList, password 공백이면 boardList로 리다이렉션
	if(mRequest.getParameter("boardNo") == null || mRequest.getParameter("boardFileNo") == null
			|| mRequest.getParameter("saveFilename") == null || mRequest.getParameter("password") == null){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
		return;
	}
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	String saveFilename = mRequest.getParameter("saveFilename");
	String password = mRequest.getParameter("password");
	System.out.println(boardNo + " <--removeBoardAction boardNo");
	System.out.println(boardFileNo + " <--removeBoardAction boardFileNo");
	System.out.println(saveFilename + " <--removeBoardAction saveFilename");
	System.out.println(password + " <--removeBoardAction password");
	
	//비밀번호 확인: 비밀번호가 공백이거나 다르면 리다이렉션
	if(mRequest.getParameter("password").equals("") || !loginMember.getMemberPw().equals(password)) {
		System.out.println("removeBoardAction 비밀번호 공백이거나 상이");
		msg = URLEncoder.encode("비밀번호를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp?msg="+msg+"&boardNo="+boardNo+"&boardFileNo="+boardFileNo);
		return;
	}
	
	//2.모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
			
	//로그인 비밀번호와 입력비밀번호가 같을 경우 게시글삭제, 저장된 파일 삭제 
	String removeSql = "DELETE FROM board WHERE board_no = ? ";
	PreparedStatement removeStmt = conn.prepareStatement(removeSql);
	removeStmt.setInt(1, boardNo);
	System.out.println(removeStmt + " <--removeBoardAction stmt");
	int removeRow = removeStmt.executeUpdate();

	if(removeRow == 1){ //게시글 삭제 성공한 경우(영향받은 행 1)
		System.out.println(removeRow + " <-- removeBoardAction 게시글삭제 성공");
		File f = new File(dir+"/"+saveFilename); //파일 삭제
		if(f.exists()){
			f.delete();
			System.out.println("removeBoardAction 파일삭제 성공");
		}
		msg = URLEncoder.encode("게시글이 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
	} else { //게시글 삭제 실패한 경우
		System.out.println(removeRow + " <-- removeBoardAction 게시글삭제 실패");
		msg = URLEncoder.encode("게시글 삭제에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp?msg="+msg+"&boardNo="+boardNo+"&boardFileNo"+boardFileNo);
	}
%>