# JSP-2-MVC-
JSP 모델2 방식(MVC 패턴) 자료실형 게시판

* 기능
  * 목록 보기
  * 글쓰기(파일 업로드)
  * 상세 보기
  * 파일 다운로드
  * 수정하기
  * 삭제하기
* 활용 기술
  * 표현 언어(EL)
  * JSP 표준 태그 라이브러리(JSTL)
  * 파일 업로드/다운로드
  * 서블릿
  * 자바스크립트

*프로젝트 구상
  * 비회원제
    *회원인증 없이 누구나 글 작성
    *대신 글쓰기 시 비밀번호 입력 필수
    *비밀번호를 통해 수정,삭제 가능
  * 자료실
    * 글쓰기 시 파일 첨부
    * 파일 첨부 시 정해진 용량 이상 업로드 불가
    * 첨부된 파일 다운로드 


* 목록 보기
  - 테이블 생성
```

create table mvcboard(
    idx number primary key,
    name varchar2(50) not null,
    title varchar2(200) not null,
    content varchar2(2000) not null,
    postdate date default sysdate not null,
    ofile varchar2(200),
    sfile varchar2(20),
    downcount number(5) default 0 not null,
    pass varchar2(50) not null,
    visitcount number default 0 not null
);

insert into mvcboard(idx, name, title, content, pass) values(seq_board_num.nextval, '김유신', '자료실제목1', '내용', '1234');
insert into mvcboard(idx, name, title, content, pass) values(seq_board_num.nextval, '장보고', '자료실제목2', '내용', '1234');
insert into mvcboard(idx, name, title, content, pass) values(seq_board_num.nextval, '강감찬', '자료실제목3', '내용', '1234');

commit;

```

* DTO 및 DAO 클래스 생성
```
package model2.mvcboard;

import java.sql.Date;

public class MVCBoardDTO {
	private String idx;
	private String name;
	private String title;
	private String content;
	private Date postdate;
	private String ofile;
	private String sfile;
	private int downcount;
	private String pass;
	private int visitcount;
	public String getIdx() {
		return idx;
	}
	public void setIdx(String idx) {
		this.idx = idx;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public Date getPostdate() {
		return postdate;
	}
	public void setPostdate(Date postdate) {
		this.postdate = postdate;
	}
	public String getOfile() {
		return ofile;
	}
	public void setOfile(String ofile) {
		this.ofile = ofile;
	}
	public String getSfile() {
		return sfile;
	}
	public void setSfile(String sfile) {
		this.sfile = sfile;
	}
	public int getDowncount() {
		return downcount;
	}
	public void setDowncount(int downcount) {
		this.downcount = downcount;
	}
	public String getPass() {
		return pass;
	}
	public void setPass(String pass) {
		this.pass = pass;
	}
	public int getVisitcount() {
		return visitcount;
	}
	public void setVisitcount(int visitcount) {
		this.visitcount = visitcount;
	}
	
	
}
```

- DAO가 상속받아야 하는 DBConnPool (common 패키지 안에 만듦)
![image](https://user-images.githubusercontent.com/86938974/166174460-414cb13c-d9bc-4b14-94fb-c1f2c2a93b79.png)

```
package common;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class DBConnPool {
    public Connection con;
    public Statement stmt;
    public PreparedStatement psmt;
    public ResultSet rs;

    // 기본 생성자
    public DBConnPool() {
        try {
            // 커넥션 풀(DataSource) 얻기
            Context initCtx = new InitialContext();
            Context ctx = (Context)initCtx.lookup("java:comp/env");
            DataSource source = (DataSource)ctx.lookup("dbcp_myoracle");

            // 커넥션 풀을 통해 연결 얻기
            con = source.getConnection();

            System.out.println("DB 커넥션 풀 연결 성공");
        }
        catch (Exception e) {
            System.out.println("DB 커넥션 풀 연결 실패");
            e.printStackTrace();
        }
    }

    // 연결 해제(자원 반납)
    public void close() {
        try {            
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (psmt != null) psmt.close();
            if (con != null) con.close();  // 자동으로 커넥션 풀로 반납됨

            System.out.println("DB 커넥션 풀 자원 반납");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}

- CRUD를 담당하는 DAO 생성
```

package model2.mvcboard;

import java.util.List;
import java.util.Map;
import java.util.Vector;

import common.DBConnPool;

public class MVCBoardDAO extends DBConnPool {

	public MVCBoardDAO() {
		super();
	}
	
	public int selectCount(Map<String, Object> map) {
		int totalCount = 0;
		
		String query = "SELECT COUNT(*) FROM mvcboard";
		
		if(map.get("searchWord")!=null) {
			query += "WHERE" + map.get("searchField")+ " "
					+ " LIKE '%"+map.get("searchWord")+ "%'";
		}
		try {
			stmt = con.createStatement();
			rs = stmt.executeQuery(query); //쿼리문 실행
			rs.next();
			totalCount = rs.getInt(1); // 검색된 게시물 개수 저장
		}
		catch(Exception e) {
			System.out.println("게시물 카운트 중 예외 발생");
			e.printStackTrace();
		}
		return totalCount; // 게시물 개수를 서블릿으로 반환
	}
	
	//검색 조건에 맞는 게시물 목록 반환
	public List<MVCBoardDTO> selectListPage(Map<String, Object> map){
		List<MVCBoardDTO> board = new Vector<MVCBoardDTO>();
		
		//쿼리문 준비
		String query = ""
				+ " SELECT * FROM ("
				+ "		SELECT Tb.*, ROWNUM rNUM FROM ("
				+ "			SELECT * FROM mvcboard ";
		//검색 조건이 있다면 WHERE절로 추가
		if (map.get("searchWord")!= null) {
			query += "WHERE" + map.get("searchField")
					+ "LIKE '%" + map.get("searchWord") + "'%";
			
		}
		query += " ORDER BY idx DESC"
				+ " 	)Tb"
				+ ")"
				+ "WHERE rNUM BETWEEN ? AND ?";
		
		try {
			psmt = con.prepareStatement(query); //동적 쿼리문 생성
			psmt.setString(1, map.get("start").toString());
			psmt.setString(2, map.get("end").toString());
			rs = psmt.executeQuery(); //쿼리문 실행
			
			//반환된 게시물 목록을 List 컬렉션에 추가
			
			while(rs.next()) {
				MVCBoardDTO dto = new MVCBoardDTO();
				
				dto.setIdx(rs.getString(1));
				dto.setName(rs.getString(2));
				dto.setTitle(rs.getString(3));
				dto.setContent(rs.getString(4));
				dto.setPostdate(rs.getDate(5));
				dto.setOfile(rs.getString(6));
				dto.setSfile(rs.getString(7));
				dto.setDowncount(rs.getInt(8));
				dto.setPass(rs.getString(9));
				dto.setVisitcount(rs.getInt(10));
				
				board.add(dto);
			
			}
			
		}
		catch(Exception e) {
			System.out.println("게시물 조회 중 예외 발생");
			e.printStackTrace();
		}
		return board; 
					
		
	}
}

```

*진입 화면 작성
- 서블릿 게시판 목록으로 바로가기



	<%@ page language="java" contentType="text/html; charset=UTF-8"
	    pageEncoding="UTF-8"%>
	<!DOCTYPE html>
	<html>
	<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	</head>
	<body>
		<h2>파일첨부형 게시판</h2>
		<a href= "../mvcboard/List.do">게시판목록</a>
	</body>
	</html>

- 서블릿 매핑 (web.xml) (어노테이션 X)
```
<servlet>
    <servlet-name>MVCBoardList</servlet-name>
    <servlet-class>model2.mvcboard.ListController</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>MVCBoardList</servlet-name>
    <url-pattern>/mvcboard/list.do</url-pattern>
  </servlet-mapping>
  
```

- utils > BoardPage.java 생성

```
package utils;

public class BoardPage {
    public static String pagingStr(int totalCount, int pageSize, int blockPage,
            int pageNum, String reqUrl) {
        String pagingStr = "";

        // 단계 3 : 전체 페이지 수 계산
        int totalPages = (int) (Math.ceil(((double) totalCount / pageSize)));

        // 단계 4 : '이전 페이지 블록 바로가기' 출력
        int pageTemp = (((pageNum - 1) / blockPage) * blockPage) + 1;
        if (pageTemp != 1) {
            pagingStr += "<a href='" + reqUrl + "?pageNum=1'>[첫 페이지]</a>";
            pagingStr += "&nbsp;";
            pagingStr += "<a href='" + reqUrl + "?pageNum=" + (pageTemp - 1)
                         + "'>[이전 블록]</a>";
        }

        // 단계 5 : 각 페이지 번호 출력
        int blockCount = 1;
        while (blockCount <= blockPage && pageTemp <= totalPages) {
            if (pageTemp == pageNum) {
                // 현재 페이지는 링크를 걸지 않음
                pagingStr += "&nbsp;" + pageTemp + "&nbsp;";
            } else {
                pagingStr += "&nbsp;<a href='" + reqUrl + "?pageNum=" + pageTemp
                             + "'>" + pageTemp + "</a>&nbsp;";
            }
            pageTemp++;
            blockCount++;
        }

        // 단계 6 : '다음 페이지 블록 바로가기' 출력
        if (pageTemp <= totalPages) {
            pagingStr += "<a href='" + reqUrl + "?pageNum=" + pageTemp
                         + "'>[다음 블록]</a>";
            pagingStr += "&nbsp;";
            pagingStr += "<a href='" + reqUrl + "?pageNum=" + totalPages
                         + "'>[마지막 페이지]</a>";
        }

        return pagingStr;
    }
}



```

* 컨트롤러(서블릿)작성

```
protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		//DAO 생성
		MVCBoardDAO dao = new MVCBoardDAO();
		
		//뷰에 전달할 매개변수 저장용 맵 생성
		Map<String, Object> map = new HashMap<String, Object>();
		
		String searchField = req.getParameter("searchField");
		String searchWord = req.getParameter("searchWord");
		if(searchWord != null) {
			//쿼리스트링으로 전달받은 매개변수 중 검색어가 있다면 map에 저장
			map.put("searchField", searchField);
			map.put("searchWord", searchWord);
		}
		int totalCount = dao.selectCount(map); //게시물 개수
		
		
		/* 페이지 처리 start */
		
		ServletContext application = getServletContext();
		
		int pageSize = Integer.parseInt(application.getInitParameter("POSTS_PER_PAGE"));
		int blockPage = Integer.parseInt(application.getInitParameter("PAGES_PER_BLOCK"));
		
		//현재 페이지 확인
		int pageNum = 1; //기본값
		String pageTemp = req.getParameter("pageNum");
		if (pageTemp != null && !pageTemp.equals(""))
			pageNum = Integer.parseInt(pageTemp);
		
		// 목록에 출력할 게시물 범위 계산
		int start = (pageNum -1)*pageSize+1; //첫 게시물 번호
		int end = pageNum * pageSize; //마지막 게시물 번호
		map.put("start", start);
		map.put("end", end);
		/* 페이지 처리 end */
		
		List<MVCBoardDTO> boardLists = dao.selectListPage(map);
		//게시물 목록 받기
		dao.close();
		
		//뷰에 전달할 매개변수 추가
		String pagingImg = BoardPage.pagingStr(totalCount, pageSize, blockPage, pageNum, "../mvcboard/list.do");//바로가기 영역 HTML 문자열
		
		map.put("pagingImg", pagingImg);
		map.put("totalCount", totalCount);
		map.put("pageSize", pageSize);
		map.put("pageNum", pageNum);
		
		//전달할 데이터를 request 영역에 저장 후 List.jsp로 포워드
		req.setAttribute("boardLists", boardLists);
		req.setAttribute("map", map);
		req.getRequestDispatcher("/MVCBoard/List.jsp").forward(req, resp);

```
- HtpServlet상속, doGet()메서드 오버라이드
- DAO객체 생성
- 뷰로 전달할 데이터를 request영역에 저장 후 List.jsp로 포워드한다.

* 뷰(JSP) 만들기



	<%@ page language="java" contentType="text/html; charset=UTF-8"
	    pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
	<!DOCTYPE html>
	<html>
	<head>
	<meta charset="UTF-8">
	<title>파일 첨부형 게시판</title>
	<style>a{text-decoration:none;}</style>
	</head>
	<body>
	    <h2>파일 첨부형 게시판 - 목록 보기(List)</h2>

	    <!-- 검색 폼 -->
	    <form method="get">  
	    <table border="1" width="90%">
	    <tr>
		<td align="center">
		    <select name="searchField">
			<option value="title">제목</option>
			<option value="content">내용</option>
		    </select>
		    <input type="text" name="searchWord" />
		    <input type="submit" value="검색하기" />
		</td>
	    </tr>
	    </table>
	    </form>

	    <!-- 목록 테이블 -->
	    <table border="1" width="90%">
		<tr>
		    <th width="10%">번호</th>
		    <th width="*">제목</th>
		    <th width="15%">작성자</th>
		    <th width="10%">조회수</th>
		    <th width="15%">작성일</th>
		    <th width="8%">첨부</th>
		</tr>
	<c:choose>    
	    <c:when test="${ empty boardLists }">  <!-- 게시물이 없을 때 -->
		<tr>
		    <td colspan="6" align="center">
			등록된 게시물이 없습니다^^*
		    </td>
		</tr>
	    </c:when>
	    <c:otherwise>  <!-- 게시물이 있을 때 -->
		<c:forEach items="${ boardLists }" var="row" varStatus="loop">    
		<tr align="center">
		    <td>  <!-- 번호 -->
			${ map.totalCount - (((map.pageNum-1) * map.pageSize) + loop.index)}   
		    </td>
		    <td align="left">  <!-- 제목(링크) -->
			<a href="../mvcboard/view.do?idx=${ row.idx }">${ row.title }</a> 
		    </td> 
		    <td>${ row.name }</td>  <!-- 작성자 -->
		    <td>${ row.visitcount }</td>  <!-- 조회수 -->
		    <td>${ row.postdate }</td>  <!-- 작성일 -->
		    <td>  <!-- 첨부 파일 -->
		    <c:if test="${ not empty row.ofile }">
			<a href="../mvcboard/download.do?ofile=${ row.ofile }&sfile=${ row.sfile }&idx=${ row.idx }">[Down]</a>
		    </c:if>
		    </td>
		</tr>
		</c:forEach>        
	    </c:otherwise>    
	</c:choose>
	    </table>

	    <!-- 하단 메뉴(바로가기, 글쓰기) -->
	    <table border="1" width="90%">
		<tr align="center">
		    <td>
			${ map.pagingImg }
		    </td>
		    <td width="100"><button type="button"
			onclick="location.href='../mvcboard/write.do';">글쓰기</button></td>
		</tr>
	    </table>
	</body>
	</html>



- 여기서 입력된 검색어는 ListController 서블릿으로 전송된다. 그 후 MVCBoardDAO클래스의 selectCount()와 selectListPage()의 인수로 전달된다.
- EL의 empty연산자로 출력할 게시물이 없는지 확인한다. boardLists는 ListController에서 request영역에 저장한 값이다.
- 출력할 게시물이 있다면 <c:forEach>태그를 통해 반복 출력한다.

* 글쓰기
	- 서블릿 매핑(다음 부터는 애너테이션 사용), 첨부 파일 최대 용량 설정 > web.xml

	<servlet>
	    <servlet-name>MVCBoardWrite</servlet-name>
	    <servlet-class>model2.mvcboard.WriteController</servlet-class>
	  </servlet>
	  <servlet-mapping>
	    <servlet-name>MVCBoardWrite</servlet-name>
	    <url-pattern>/mvcboard/write.do</url-pattern>
	  </servlet-mapping>


	  <context-param>
	    <param-name>maxPostSize</param-name>
	    <param-value>1024000</param-value>
	  </context-param>
  

* 컨트롤러 작성 1 - 작성폼으로 진입
![화면 캡처 2022-05-03 101111](https://user-images.githubusercontent.com/86938974/166391098-7e2aa903-3322-478c-816d-df24b2686b9d.png)



	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			req.getRequestDispatcher("/MVCBoard/Write.jsp").forward(req, resp);


		}


- 작성폼으로 진입하기 위해 doGet()메서드 사용, 단순히 글쓰기 페이지로 포워드만 해준다.

* 뷰 작성
```
	<%@ page language="java" contentType="text/html; charset=UTF-8"
	    pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
	<!DOCTYPE html>
	<html>
	<head>
	<meta charset="UTF-8">
	<title>파일 첨부형 게시판</title>
	<script type="text/javascript">
	    function validateForm(form) {  // 필수 항목 입력 확인
		if (form.name.value == "") {
		    alert("작성자를 입력하세요.");
		    form.name.focus();
		    return false;
		}
		if (form.title.value == "") {
		    alert("제목을 입력하세요.");
		    form.title.focus();
		    return false;
		}
		if (form.content.value == "") {
		    alert("내용을 입력하세요.");
		    form.content.focus();
		    return false;
		}
		if (form.pass.value == "") {
		    alert("비밀번호를 입력하세요.");
		    form.pass.focus();
		    return false;
		}
	    }
	</script>
	</head>
	<h2>파일 첨부형 게시판 - 글쓰기(Write)</h2>
	<form name="writeFrm" method="post" enctype="multipart/form-data"
	      action="../mvcboard/write.do" onsubmit="return validateForm(this);">
	<table border="1" width="90%">
	    <tr>
		<td>작성자</td>
		<td>
		    <input type="text" name="name" style="width:150px;" />
		</td>
	    </tr>
	    <tr>
		<td>제목</td>
		<td>
		    <input type="text" name="title" style="width:90%;" />
		</td>
	    </tr>
	    <tr>
		<td>내용</td>
		<td>
		    <textarea name="content" style="width:90%;height:100px;"></textarea>
		</td>
	    </tr>
	    <tr>
		<td>첨부 파일</td>
		<td>
		    <input type="file" name="ofile" />
		</td>
	    </tr>
	    <tr>
		<td>비밀번호</td>
		<td>
		    <input type="password" name="pass" style="width:100px;" />
		</td>
	    </tr>
	    <tr>
		<td colspan="2" align="center">
		    <button type="submit">작성 완료</button>
		    <button type="reset">RESET</button>
		    <button type="button" onclick="location.href='../mvcboard/list.do';">
			목록 바로가기
		    </button>
		</td>
	    </tr>
	</table>    
	</form>
	</body>
	</html>

- 폼값을 서버로 전송하기 전에 필수 항목 중 빈 값이 있는지를 확인하는 자바스크립트 함수 삽입


* 모델 작성(DAO에 기능 추가) - 글쓰기 처리 메서드 추가


// 게시글 데이터를 받아 DB에 추가합니다.(파일 업로드 지원)
	public int insertWrite(MVCBoardDTO dto) {
		int result = 0;
		try {
			String query = "INSERT INTO mvcboard("
					+ "idx, name, title, content, ofile, sfile, pass)"
					+ "VALUES("
					+ "seq_board_num.NEXTVAL,?,?,?,?,?,?)";
			psmt = con.prepareStatement(query);
			psmt.setString(1, dto.getName());
			psmt.setString(2, dto.getTitle());
			psmt.setString(3, dto.getContent());
			psmt.setString(4, dto.getOfile());
			psmt.setString(5, dto.getSfile());
			psmt.setString(6, dto.getPass());
		}
		catch(Exception e) {
			System.out.println("게시물 입력 중 예외 발생");
			e.printStackTrace();
		}
		return result;
		
	}

```
- 웹페이지(Write.jsp)에서 전송한 폼값을 서블릿이 받아 DTO에 저장 후 이 DAO로 전달
- INSERT쿼리문 작성

* 컨트롤러 작성2 - 폼값 처리
![화면 캡처 2022-05-03 101303](https://user-images.githubusercontent.com/86938974/166391203-f6179b9c-4b12-4793-946f-ca021a1ce7be.png)

```
package fileUpload;

import javax.servlet.http.HttpServletRequest;

import com.oreilly.servlet.MultipartRequest;

public class FileUtil {
	//파일 업로드(multipart/form-data 요청) 처리
	public static MultipartRequest uploadFile(HttpServletRequest req,
			String saveDirectory, int maxPostSize) {
		try {
			//파일 업로드
			return new MultipartRequest(req, saveDirectory, maxPostSize, "UTF-8");
		}
		catch(Exception e) {
			//업로드 실패
			e.printStackTrace();
			return null;
		}
	}
}

```
- 컨트롤러에 글쓰기 메서드 추가


```

package model2.mvcboard;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.oreilly.servlet.MultipartRequest;

import fileUpload.FileUtil;
import utils.JSFunction;

/**
 * Servlet implementation class WriteController
 */
@WebServlet("/WriteController")
public class WriteController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public WriteController() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.getRequestDispatcher("/Write.jsp").forward(req, resp);
		
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// 1.파일 업로드 처리
		// 업로드 디렉터리의 물리적 경로 확인
		String saveDirectory = req.getServletContext().getRealPath("/Uploads");
		
		//초기화 매개변수로 설정한 첨부 파일 최대 용량 확인
		ServletContext application = getServletContext();
		int maxPostSize = Integer.parseInt(application.getInitParameter("maxPostSize"));
		
		//파일 업로드
		MultipartRequest mr = FileUtil.uploadFile(req, saveDirectory, maxPostSize);
		if(mr == null) {
			JSFunction.alertLocation(resp, "첨부 파일이 제한 용량을 초과합니다.", "../write.do");
			return;
		}
		
		//2.파일 업로드 외 처리
		//폼값을 DTO에 저장
		MVCBoardDTO dto = new MVCBoardDTO();
		
		dto.setName(mr.getParameter("name"));
		dto.setTitle(mr.getParameter("title"));
		dto.setContent(mr.getParameter("content"));
		dto.setPass(mr.getParameter("pass"));
		
		//원본 파일명과 저장된 파일 이름 설정
		String fileName = mr.getFilesystemName("ofile");
		if(fileName != null) {
			//첨부파일이 있을 경우 파일명 변경
			// 새로운 파일명 생성
			String now = new SimpleDateFormat("yyyyMMdd_HmsS").format(new Date());
			String ext = fileName.substring(fileName.lastIndexOf("."));
			String newFileName = now + ext;
			
			//파일명 변경
			File oldFile = new File(saveDirectory + File.separator + fileName);
			File newFile = new File(saveDirectory + File.separator + newFileName);
			oldFile.renameTo(newFile);
			
			dto.setOfile(fileName); //원래 파일 이름
			dto.setSfile(newFileName); //서버에 저장된 파일 이름
			
		}
		
		//DAO를 통해 DB에 게시 내용 저장
		MVCBoardDAO dao = new MVCBoardDAO();
		int result = dao.insertWrite(dto);
		dao.close();
		
		if(result ==1 ) {
			resp.sendRedirect("../list.do");
		}
		else {
			resp.sendRedirect("../write.do");
		}
		
		
	
	}

}


```
- 파일이 업로드될 Uploads 디렉터리의 물리적 경로와 web.xml에 컨텍스트 초기화 매개변수로 설정해둔 업로드 제한 용량을 얻어온 후, 앞에서 만든 FileUtil.uploadFile()메서드 호출
- 폼값을 DTO에 저장해 DAO를 통해 데이터베이스에 기록

- 유틸리티 메서드 추가 ( utils.JSFunction.java )

```
 // 메시지 알림창을 띄운 후 이전 페이지로 돌아갑니다.
    public static void alertBack(String msg, JspWriter out) {
        try {
            String script = ""
                          + "<script>"
                          + "    alert('" + msg + "');"
                          + "    history.back();"
                          + "</script>";
            out.println(script);
        }
        catch (Exception e) {}
    }

    // 메시지 알림창을 띄운 후 명시한 URL로 이동합니다.
    public static void alertLocation(HttpServletResponse resp, String msg, String url) {
        try {
            resp.setContentType("text/html;charset=UTF-8");
            PrintWriter writer = resp.getWriter();
            String script = ""
                          + "<script>"
                          + "    alert('" + msg + "');"
                          + "    location.href='" + url + "';"
                          + "</script>";
            writer.print(script);
        }
        catch (Exception e) {}
    }

    // 메시지 알림창을 띄운 후 이전 페이지로 돌아갑니다.
    public static void alertBack(HttpServletResponse resp, String msg) {
        try {
            resp.setContentType("text/html;charset=UTF-8");
            PrintWriter writer = resp.getWriter();
            String script = ""
                          + "<script>"
                          + "    alert('" + msg + "');"
                          + "    history.back();"
                          + "</script>";
            writer.print(script);
        }
        catch (Exception e) {}
    }
```
-실행화면(Write.jsp)

#사진 첨부할 것(509)

![image](https://user-images.githubusercontent.com/86938974/166390756-01d3b26a-64d2-4c1a-949e-9fd3a12b9949.png)

![image](https://user-images.githubusercontent.com/86938974/166390773-35d6816c-deaf-4dca-a003-2f0d09117373.png)
	- 파일이 첨부되는 것을 알 수 있다.

파일의 용량이 1MB를 초과하면 다음과 같이 경고창이 뜬 후 화면으로 돌아간다.
![image](https://user-images.githubusercontent.com/86938974/166206034-8d8d9d16-5f3a-43eb-bdf4-4f7f52f0438f.png)

* 모델 작성
	- 주어진 일련번호에 해당하는 게시물을 DTO로 반환하는 메소드와 조회수를 증가시키는 메소드를 작성
```
 //주어진 일련번호에 해당하는 게시물을 DTO에 담아 반환한다.
    public MVCBoardDTO selectView(String idx) {
    	MVCBoardDTO dto = new MVCBoardDTO();
    	String query = "SELECT * FROM mvcboard WHERE idx=?";
    	try {
    		psmt = con.prepareStatement(query);
    		psmt.setString(1, idx);
    		rs = psmt.executeQuery();
    		
    		if (rs.next()) {  // 결과를 DTO 객체에 저장
                dto.setIdx(rs.getString(1));
                dto.setName(rs.getString(2));
                dto.setTitle(rs.getString(3));
                dto.setContent(rs.getString(4));
                dto.setPostdate(rs.getDate(5));
                dto.setOfile(rs.getString(6));
                dto.setSfile(rs.getString(7));
                dto.setDowncount(rs.getInt(8));
                dto.setPass(rs.getString(9));
                dto.setVisitcount(rs.getInt(10));
            }
        }
        catch (Exception e) {
            System.out.println("게시물 상세보기 중 예외 발생");
            e.printStackTrace();
    	}
    	return dto;
    }
    // 주어진 일련번호에 해당하는 게시물의 조회수 1 증가
    public void updateVisitCount(String idx) {
    	String query = "UPDATE mvcboard SET "
    			+ "visitcount = visitcount+1"
    			+ "WHERE idx=?";
    	try {
    		psmt = con.prepareStatement(query);
    		psmt.setString(1, idx);
    		psmt.executeQuery();
    	}
    	catch(Exception e) {
    		System.out.println("게시물 조회 수 증가 중 예외 발생");
    		e.printStackTrace();
    	}
    }
```
*컨트롤러 작성
	- 상세 보기를 위한 서블릿 작성
	- 매핑은 애너테이션 사용

```

public class ViewController extends HttpServlet {
	
	@Override
	protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		//게시물 불러오기
		MVCBoardDAO dao = new MVCBoardDAO();
		String idx = req.getParameter("idx");
		dao.updateVisitCount(idx);
		MVCBoardDTO dto = dao.selectView(idx);
		dao.close();
		
		//줄바꿈 처리
		dto.setContent(dto.getContent().replaceAll("\r\n", "<br/>"));
		
		//게시물 (dto) 저장 후 뷰로 포워드
		req.setAttribute("dto", dto);
		req.getRequestDispatcher("/View.jsp").forward(req, resp);
		
	}

```
- 게시물 조회 요청이 오면 DAO객체 생성, 조회수 증가 후 게시물 내용을 가져온다.
- 줄바꿈 처리
- DTO객체를 request 영역에 저장 후 뷰로 포워드한다.

* 뷰 작성
	- 게시물 내용을 출력해줄 뷰 작성




