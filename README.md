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



