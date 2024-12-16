<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    String userId = (String) session.getAttribute("userId");

    boolean success = false;
    String message = "";

    if (userId != null) {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD)) {
            // is_deleted를 TRUE로 설정
            String deleteQuery = "UPDATE alerts SET is_deleted = TRUE WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteQuery)) {
                stmt.setString(1, userId);
                int rowsUpdated = stmt.executeUpdate();
                if (rowsUpdated > 0) {
                    success = true;
                    message = "알림이 성공적으로 삭제되었습니다.";
                } else {
                    message = "삭제할 알림이 없습니다.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "오류 발생: " + e.getMessage();
        }
    } else {
        message = "로그인이 필요합니다.";
    }

    // JSON 응답 생성
    String jsonResponse = String.format(
        "{\"status\":\"%s\", \"message\":\"%s\"}",
        success ? "success" : "error",
        message
    );

    out.print(jsonResponse);
%>
