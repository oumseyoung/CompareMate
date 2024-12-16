<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.TimeZone" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 상세</title>
</head>
<body>
    <h1>게시글 상세</h1>
    <%
        // JDBC 드라이버 연결 및 설정
        Connection connection = null;
        PreparedStatement psmt = null;
        ResultSet result = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String db_address = "jdbc:mysql://localhost:3306/practice_board?serverTimezone=Asia/Seoul";
            String db_username = "root";
            String db_pwd = "0000";
            connection = DriverManager.getConnection(db_address, db_username, db_pwd);

            // `post_id` 파라미터 가져오기
            int postId = Integer.parseInt(request.getParameter("post_id"));

            // 게시글 조회 쿼리
            String selectQuery = "SELECT * FROM posts WHERE post_id = ?";
            psmt = connection.prepareStatement(selectQuery);
            psmt.setInt(1, postId);
            result = psmt.executeQuery();

            if (result.next()) {
                // 게시글 상세 정보 가져오기
                String category = result.getString("category");
                String title = result.getString("title");
                String content = result.getString("content");
                Timestamp regDate = result.getTimestamp("reg_date");
                boolean multiSelect = result.getBoolean("multi_select");
                boolean notify = result.getBoolean("notify");

                // 투표 종료일과 시간 가져오기
                Date endDate = result.getDate("end_date");
                Time endTime = result.getTime("end_time");

                // 날짜 및 시간 형식 지정
                SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm:ss");
                SimpleDateFormat sdfDateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

                // 작성일 포맷팅
                String formattedRegDate = sdfDateTime.format(regDate);

                // 투표 종료일시 포맷팅
                String formattedEndDateTime = "설정 없음";
                if (endDate != null && endTime != null) {
                    // endDate와 endTime을 결합하여 Timestamp 생성
                    String endDateTimeStr = sdfDate.format(endDate) + " " + sdfTime.format(endTime);
                    Timestamp endDateTime = Timestamp.valueOf(endDateTimeStr);
                    formattedEndDateTime = sdfDateTime.format(endDateTime);
                }

    %>
    <table border="1">
        <tr>
            <th>카테고리</th>
            <td><%= category %></td>
        </tr>
        <tr>
            <th>제목</th>
            <td><%= title %></td>
        </tr>
        <tr>
            <th>내용</th>
            <td><%= content %></td>
        </tr>
        <tr>
            <th>작성일</th>
            <td><%= formattedRegDate %></td>
        </tr>
        <tr>
            <th>복수 선택 여부</th>
            <td><%= multiSelect ? "허용" : "미허용" %></td>
        </tr>
        <tr>
            <th>투표 종료일시</th>
            <td><%= formattedEndDateTime %></td>
        </tr>
        <tr>
            <th>알림 설정</th>
            <td><%= notify ? "설정됨" : "설정 안 됨" %></td>
        </tr>
    </table>
    <button type="button" onClick="location.href='post_modify.jsp?post_id=<%= postId %>'">수정</button>
    <button type="button" onClick="location.href='post_delete_send.jsp?post_id=<%= postId %>'">삭제</button>
    <%
            } else {
                out.println("해당 게시글을 찾을 수 없습니다.");
            }
        } catch (Exception ex) {
            out.println("오류가 발생했습니다. 오류 메시지: " + ex.getMessage());
            ex.printStackTrace();
        } finally {
            // 리소스 닫기
            if (result != null) try { result.close(); } catch (Exception e) {}
            if (psmt != null) try { psmt.close(); } catch (Exception e) {}
            if (connection != null) try { connection.close(); } catch (Exception e) {}
        }
    %>
</body>
</html>
