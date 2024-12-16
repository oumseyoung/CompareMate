<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // 기존 투표 종료 알림 확인 코드
%>

<%
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    try (Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD)) {
        Timestamp currentTime = new Timestamp(System.currentTimeMillis());

        // 종료된 투표 중 알림 설정된 게시글 조회
        String query = "SELECT post_id, user_id, title FROM posts " +
                       "WHERE notify = TRUE AND end_date <= CURDATE() AND end_time <= CURTIME()";
        try (PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                int postId = rs.getInt("post_id");
                String userId = rs.getString("user_id");
                String title = rs.getString("title");

                // 알림 중복 확인
                String checkQuery = "SELECT COUNT(*) FROM alerts WHERE user_id = ? AND post_id = ? AND message LIKE ?";
                boolean alertExists = false;

                try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                    checkStmt.setString(1, userId);
                    checkStmt.setInt(2, postId);
                    checkStmt.setString(3, "%투표가 종료되었습니다%");
                    try (ResultSet checkRs = checkStmt.executeQuery()) {
                        if (checkRs.next() && checkRs.getInt(1) > 0) {
                            alertExists = true; // 이미 알림이 존재함
                        }
                    }
                }

                // 알림이 없으면 추가
                if (!alertExists) {
                    String insertQuery = "INSERT INTO alerts (user_id, message, post_id, created_at) VALUES (?, ?, ?, NOW())";
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
                        String message = String.format("게시글 '%s'의 투표가 종료되었습니다.", title);
                        insertStmt.setString(1, userId);
                        insertStmt.setString(2, message);
                        insertStmt.setInt(3, postId);
                        insertStmt.executeUpdate();
                    }
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
