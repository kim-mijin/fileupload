<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="vo.*"%>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%
	//1.컨트롤러계층
	//세션유효성검사: 로그인 안하면 접근불가
	String msg = null;
	if(session.getAttribute("loginMember") == null){
		msg = URLEncoder.encode("잘못된 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg="+msg);
		return;
	}

	//request를 MultipartRequest로 맵핑
	/*
		MultipartRequest 사용하지 않는 경우
		
		InputStream is = request.getInputStream(); //java.io
		System.out.println(is); 
		//Content-Disposition: form-data; name="boardTitle"
		//Content-Disposition: form-data; name="memberId"
		//Content-Disposition: form-data; name="boardFile"; filename="velog bg2.jpg" Content-Type: image/jpeg
		//해쉬코드값

		int result = 0;
		while((result = is.read()) != -1) { 
			// read()메서드: 입력 스트림으로부터 1바이트를 읽고 int 타입으로 리턴, 입력 스트림으로부터 더 이상 바이트를 읽을 수 없으면 read()는 -1 리턴
			System.out.print((char)result); //int인 result를 char타입으로 형변환하여 출력
		}
		
		-> InputStream을 사용할 경우 출력결과물에서 파일정보를 가져오는 것이 번거로워 MultipartRequest API를 사용
	*/
	
	//파일 업로드 위치 (server설정에서 Serve modules without publishing 체크 -> 내가 알수있는 upload폴더 디렉토리)
	String dir = request.getServletContext().getRealPath("/upload"); //"*\\upload로 써도 가능"
	System.out.println(dir + " <--dir"); //결과: C:\html_work\fileupload\src\main\webapp\\upload
	
	int maxFileSize = 10 * 1024 * 1024; // 10Mbyte
	MultipartRequest mRequest = new MultipartRequest(request, dir, maxFileSize, "utf-8", new DefaultFileRenamePolicy());
	/*
		* MultipartRequest API를 사용하여 스트림내에서 문자값을 반환받을 수 있다.
			-> multipart-data방식으로 전송한 데이터를 request.getIntputStream을 사용하지 않고 호출할 수 있음
			-> new MultipartRequest(원본request, 업로드폴더, 최대파일사이즈byte, 인코딩, 중복이름정책)
		* DefaultFileRenamePolicy()로 하면 중복된 원래의 이름 +1
			-> 문제: 기존의 파일이름들을 조회해서 중복된 이름을 검색하므로 저장된 파일이 많을 경우 시간이 오래걸리고 업로드가 불가능하게 된다
					-> DB에 저장할 때는 중복되지 않는 이름을 만들어 저장하고(메소드사용) 다운로드 할 때는 업로드된 이름으로 다운받을 수 있도록 한다
	*/
		
	//1) 업로드 파일이 pdf파일이 아니면 리다이렉션(코드진행종료)
	if(mRequest.getContentType("boardFile").equals("application/pdf") == false){
		/*
			문제: 파일의 정보가 호출되는 순간 파일이 지정한 위치에 저장됨 -> 저장된 파일을 삭제해야한다
			-> java.io.File의 delete메소드 사용하여 파일 삭제
		*/
		System.out.println("PDF파일이 아닙니다" + " <--addBoardAction 업로드파일타입 확인");
		String saveFilename = mRequest.getFilesystemName("boardFile"); //업로드된 파일의 시스템네임을 변수에 저장
		File f = new File(dir+"/"+saveFilename); //new File(C:\html_work\fileupload\src\main\webapp\\upload\\velog bg2.jpg) 
		// File : An abstract representation of file and directory pathnames. 파일유무와 경로 추출하는 API
		// *해당API는 운영체제에 따라 역슬래쉬를 슬래쉬로 자동으로 바꿔준다
		if(f.exists()){ //f의 파일이 존재하면 삭제
			f.delete();
			System.out.println("파일삭제" + " <--addBoardAction 업로드된 파일삭제");
		}
		msg = URLEncoder.encode("PDF파일이 아닙니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/addBoard.jsp?msg="+msg);
		return;	
	}
	
	//2) input type="text" 값반환 API -- board테이블에 저장
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberId = mRequest.getParameter("memberId");
	
	System.out.println(boardTitle + " <--addBoardAction boardTitle");
	System.out.println(memberId + " <--addBoardAction memberId");
	
	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	//3) input type="file" 값(파일 메타 정보)반환 API (원본파일이름, 저장된파일이름, 컨텐츠타입) -- board_file테이블에 저장
	//->파일(바이너리)는 MultipartRequest객체 생성 시(request맵핑 시) 먼저 저장됨
	String type = mRequest.getContentType("boardFile");
	String originFilename = mRequest.getOriginalFileName("boardFile"); //파일의 원래이름
	String saveFilename = mRequest.getFilesystemName("boardFile"); //저장된 파일이름을 불러온다
	
	BoardFile boardFile = new BoardFile();
	//bordFile.setBoardNo();
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	System.out.println(type + " <--addBoardAction type");
	System.out.println(originFilename + " <--addBoardAction originFilename");
	System.out.println(saveFilename + " <--addBoardAction saveFilename");
	
	//2. 모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	/*
		INSERT INTO board(board_title, member_id, createdate, updatedate)
		VALUES(?, ?, NOW(), NOW())
		
		INSERT쿼리 실행 후 기본키값 받아오기 JDBC API
		INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, createdate)
		String sql = "INSERT 쿼리문";
		pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
		int row = pstmt.executeUpdate(); // insert 쿼리 실행
		ResultSet keyRs = pstmt.getGeneratedKeys(); // insert 후 입력된 행의 키값을 받아오는 select쿼리를 진행
		int keyValue = 0;
		if(keyRs.next()){
			keyValue = rs.getInt(1);
		}
	*/
	
	//board테이블에 저장하기 위한 쿼리 실행
	String boardSql = "INSERT INTO board(board_title, member_id, createdate, updatedate) VALUES(?, ?, NOW(), NOW())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS); 
	//PreparedStatement.RETURN_GENERATED_KEYS 옵션은 방금 입력된 데이터의 키값을 기억하고 있음
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId);
	System.out.println(boardStmt + " <--addBoardAction boardStmt");
	int boardRow = boardStmt.executeUpdate(); //board입력 후 키값을 저장
	System.out.println(boardRow + " <--addBoardAction boardRow: DB에 저장성공");
	
	ResultSet keyRs = boardStmt.getGeneratedKeys(); //저장된 키값을 반환하는 메소드 
	int boardNo = 0; //boardFile테이블에 데이터를 저장하기 위해 필요한 boardNo
	if(keyRs.next()){ //keyRs에 저장된 데이터가 있으면 boardNo에 저장
		boardNo = keyRs.getInt(1);
	}
	
	//board_file테이블에 저장하기 위한 쿼리 실행
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) "
						+ "VALUES(?, ?, ?, ?, 'upload', NOW())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);
	System.out.println(fileStmt + " <--addBoardAction fileStmt");
	fileStmt.executeUpdate(); //board_file입력
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	
%>