<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 목록</title>
</head>
<body>
    <h1>게시글 목록</h1>
    <%
      Connection connection = null;
      PreparedStatement psmt = null;
      ResultSet result = null;
      
      try {
          // JDBC 드라이버 연결
          Class.forName("com.mysql.cj.jdbc.Driver");
          String db_address = "jdbc:mysql://localhost:3306/practice_board?serverTimezone=UTC";
          String db_username = "root";
          String db_pwd = "0000";

          connection = DriverManager.getConnection(db_address, db_username, db_pwd);
          
          // MySQL 쿼리 작성
          String selectQuery = "SELECT post_id, category, title, reg_date FROM posts ORDER BY post_id DESC";

          // PreparedStatement 생성 및 실행
          psmt = connection.prepareStatement(selectQuery);
          result = psmt.executeQuery();
    %>
    <table border="1">
        <tr>
            <td colspan="5"><h3>게시글 제목 클릭 시 상세 열람 가능</h3></td>
        </tr>
        <tr>
            <td colspan="5">
                <button type="button" onClick="location.href='write.jsp'">신규 글 작성</button>
            </td>
        </tr>
        <tr>
            <th>번호</th>
            <th>카테고리</th>
            <th>제목</th>
            <th>작성일</th>
            <th>관리</th>
        </tr>
        <%
            // 게시글 데이터를 출력
            while (result.next()) {
                int postId = result.getInt("post_id");
                String category = result.getString("category");
                String title = result.getString("title");
                Timestamp regDate = result.getTimestamp("reg_date");
        %>
        <tr>
            <td><%=postId %></td>
            <td><%=category %></td>
            <td>
                <a href="post_read.jsp?post_id=<%=postId %>">
                    <%=title %>
                </a>
            </td>
            <td><%=regDate %></td>
            <td>
                <button type="button" onClick="location.href='post_modify.jsp?post_id=<%=postId %>'">수정</button>
                <button type="button" onClick="location.href='post_delete_send.jsp?post_id=<%=postId %>'">삭제</button>
            </td>
        </tr>
        <%
            } // while 문 종료
        %>
    </table>
    <%
      } catch (Exception ex) {
          out.println("오류가 발생했습니다. 오류 메시지: " + ex.getMessage());
      } finally {
          // 리소스 닫기
          if (result != null) try { result.close(); } catch (Exception e) { }
          if (psmt != null) try { psmt.close(); } catch (Exception e) { }
          if (connection != null) try { connection.close(); } catch (Exception e) { }
      }
    %>
</body>
</html>
