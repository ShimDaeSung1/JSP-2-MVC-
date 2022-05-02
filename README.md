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

![image](https://user-images.githubusercontent.com/86938974/166175817-29d47810-ecc1-4ad7-a467-9de72125622c.png)



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



