<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.TimeZone" %>
<!DOCTYPE html>
<html lang="ko">
<head>
 <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 목록</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 10px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        a {
            text-decoration: none;
            color: blue;
        }
        a:hover {
            text-decoration: underline;
        }
        .button-group button {
            margin: 2px;
            padding: 5px 10px;
            cursor: pointer;
        }
        .button-group button:hover {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
     <h1>게시글 목록</h1>
    <%
        Connection connection = null;
        PreparedStatement psmt = null;
        ResultSet result = null;

        try {
            // JDBC 연결 설정
            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = "jdbc:mysql://localhost:3306/practice_board?serverTimezone=UTC"; // 또는 Asia/Seoul
            String dbUser = "root";
            String dbPassword = "0000";

            connection = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

            // MySQL 쿼리
            String selectQuery = "SELECT p.post_id, p.category, p.title, " +
                                 "       (SELECT GROUP_CONCAT(po.option_text SEPARATOR ', ') " +
                                 "        FROM poll_options po WHERE po.post_id = p.post_id) AS poll_summary, " +
                                 "       p.reg_date " +
                                 "FROM posts p " +
                                 "ORDER BY p.post_id DESC";

            psmt = connection.prepareStatement(selectQuery);
            result = psmt.executeQuery();

            // SimpleDateFormat 인스턴스 생성 및 시간대 설정
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            sdf.setTimeZone(TimeZone.getTimeZone("UTC")); // 데이터베이스 시간대에 맞게 설정
    %>
    <table>
        <tr>
    <td colspan="6">
    <h3>게시글 제목 클릭시 상세 열람 가능</h3>
    </td>
    </tr>
    <tr>
    <td colspan="6">
    <button type="button" value="신규 글 작성" onClick="location.href='write.jsp'">신규 글 작성</button>
    </td>
    </tr>
        <tr>
            <th>번호</th>
            <th>카테고리</th>
            <th>제목</th>
            <th>투표 항목</th>
            <th>작성일</th>
            <th>관리</th>
        </tr>
        <%
            while (result.next()) {
                int postId = result.getInt("post_id");
                String category = result.getString("category");
                String title = result.getString("title");
                String pollSummary = result.getString("poll_summary");
                Timestamp regDate = result.getTimestamp("reg_date");
        %>
        <tr>
            <td><%= postId %></td>
            <td><%= category %></td>
            <td><a href="post_read.jsp?post_id=<%= postId %>"><%= title %></a></td>
            <td><%= (pollSummary != null && !pollSummary.isEmpty()) ? pollSummary : "투표 없음" %></td>
            <td><%= sdf.format(regDate) %></td>
            <td class="button-group">
                <button type="button" onClick="location.href='post_modify.jsp?post_id=<%= postId %>'">수정</button>
                <button type="button" onClick="if(confirm('정말 삭제하시겠습니까?')) location.href='post_delete_send.jsp?post_id=<%= postId %>';">삭제</button>
            </td>
        </tr>
        <% } %>
    </table>
    <%
        } catch (Exception ex) {
            out.println("<p>오류가 발생했습니다. 오류 메시지: " + ex.getMessage() + "</p>");
        } finally {
            if (result != null) try { result.close(); } catch (Exception e) { }
            if (psmt != null) try { psmt.close(); } catch (Exception e) { }
            if (connection != null) try { connection.close(); } catch (Exception e) { }
        }
    %>
</body>
</html>
