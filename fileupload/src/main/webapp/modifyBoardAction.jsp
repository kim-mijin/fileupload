<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="vo.*"%>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%
	//ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	//1.컨트롤러 계층
	//MultipartRequest로 request 맵핑
	String dir = request.getServletContext().getRealPath("/upload"); //"*\\upload로 써도 가능"
	System.out.println(dir + " <--dir"); //결과: C:\html_work\fileupload\src\main\webapp\\upload
	int maxFileSize = 10 * 1024 * 1024; // 10Mbyte
	MultipartRequest mRequest = new MultipartRequest(request, dir, maxFileSize, "utf-8", new DefaultFileRenamePolicy());
	
	//요청값이 잘 넘어오는지 확인하기
	System.out.println(mRequest.getParameter("boardNo") + " <--modifyBoardAction param boardNo");
	System.out.println(mRequest.getParameter("boardFileNo") + " <--modifyBoardAction param boardFileNo");
	System.out.println(mRequest.getParameter("boardTitle") + " <--modifyBoardAction param boardTitle");
	System.out.println(mRequest.getParameter("boardFile") + " <--modifyBoardAction param boardFile"); //파일을 선택하지 않으면 null값이 넘어옴
	
	//요청값 유효성 검사: boardFile을 제외한 나머지 요청값이 null인 경우에는 boardList로 리다이렉션
	if(mRequest.getParameter("boardNo") == null || mRequest.getParameter("boardNo") == null
		|| mRequest.getParameter("boardTitle") == null){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}

	//mRequest.getOriginalFileName("boardFile")값이 null이면 board테이블에 title만 수정
	if(mRequest.getOriginalFileName("boardFile") != null){
		String originFilename = mRequest.getOriginalFileName("boardFile");
	}
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	String boardTitle = mRequest.getParameter("boardTitle");
	
	System.out.println(boardNo + " <--modifyBoardAction boardNo");
	System.out.println(boardFileNo + " <--modifyBoardAction boardFileNo");
	System.out.println(boardTitle + " <--modifyBoardAction boardTitle");
	
	//2.모델계층
	//DB접속하기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	int boardFileRs = 0; //새로운 파일업로드 결과
	
	//1)파일을 바꾸지 않은 경우: board_title만 수정
	String modTitleSql = "UPDATE board SET board_title=? WHERE board_no=?";
	PreparedStatement modTitleStmt = conn.prepareStatement(modTitleSql);
	modTitleStmt.setString(1, boardTitle);
	modTitleStmt.setInt(2, boardNo);
	System.out.println(BG_YELLOW + modTitleStmt + " <--modifyBoardAction modTitleStmt" + RESET);
	int modTitleRs = modTitleStmt.executeUpdate();
	System.out.println(modTitleRs + " <--modifyBoardAction modTitleRow 제목수정성공");
	
	//2)파일을 바꾼 경우: 이전 boardFile 삭제, 새로운 boardFile 추가 -> 테이블 수정
	if(mRequest.getOriginalFileName("boardFile") != null){ //수정할 파일이 있으면 -> pdf파일 유효성 검사 진행
		//2-1)pdf파일이 아니면 새로 업로드된 파일 삭제
		if(mRequest.getContentType("boardFile").equals("application/pdf") == false){
			System.out.println("PDF파일이 아닙니다" + " <--modifyBoardAction 업로드파일타입 확인");
			String saveFilename = mRequest.getFilesystemName("boardFile"); //업로드된 파일의 시스템네임을 변수에 저장
			File f = new File(dir+"/"+saveFilename); 
			if(f.exists()){ //f의 파일이 존재하면 삭제
				f.delete();
				System.out.println("새로운파일삭제" + " <--modifyBoardAction");
			}
			response.sendRedirect(request.getContextPath()+"/boardList.jsp");
			return;	
			
		} else { //2-2)pdf파일이면 이전파일 삭제(saveFilename)->db수정(update)
			String type = mRequest.getContentType("type");
			String originFilename = mRequest.getOriginalFileName("originFilename");
			String saveFilename = mRequest.getFilesystemName("saveFilename");
			
			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo);
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			//2-2-1)이전파일 삭제
			String saveFilenameSql = "SELECT save_filename saveFilename FROM board_file WHERE board_file_no = ?";
			PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
			System.out.println(BG_YELLOW + saveFilenameStmt + " <--modifyBoardAction saveFilenameStmt" + RESET);
			ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
			String preSaveFilename = "";
			if(saveFilenameRs.next()){
				preSaveFilename = saveFilenameRs.getString("saveFilename");
			}
			File f = new File(dir+"/"+preSaveFilename);
			if(f.exists()){
				f.delete();
				System.out.println("기존파일삭제" + " <--modifyBoardAction");
			}
			
			//2-2-2) 수정된 파일의 정보로 db를 수정
			//path와 type필드는 값이 고정되어 있으므로 update하지 않음
			String boardFileSql = "UPDATE board_file SET origin_filename = ?, save_filename = ? WHERE board_file_no = ?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardNo());
			System.out.println(BG_YELLOW + boardFileStmt + " <--modifyBoardAction boardFileStmt" + RESET);
			boardFileRs = boardFileStmt.executeUpdate();
		}
	}
	
	//실패하면 modifyBoard로 성공하면 boardList로 리다이렉션
	if(modTitleRs ==1 || boardFileRs == 1){ //새로운 파일 업로드 성공
		System.out.println("modifyBoardAction 새로운 파일 업로드 성공");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	} else {
		System.out.println("modifyBoardAction 새로운 파일 업로드 실패");
		response.sendRedirect(request.getContextPath()+"/modifyBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo);
	}
%>