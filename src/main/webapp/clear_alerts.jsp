<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    String userId = (String) session.getAttribute("userId");
    boolean success = false;
    String message = "";

    if (userId != null) {
        Connection conn = null;
        PreparedStatement deleteStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

            // 알림 삭제 쿼리 실행
            String deleteAlertsQuery = "DELETE FROM alerts WHERE user_id = ?";
            deleteStmt = conn.prepareStatement(deleteAlertsQuery);
            deleteStmt.setString(1, userId);
            int rowsDeleted = deleteStmt.executeUpdate();

            success = true;
            message = rowsDeleted > 0 ? "알림이 삭제되었습니다." : "삭제할 알림이 없습니다.";
        } catch (Exception e) {
            e.printStackTrace();
            message = "오류 발생: " + e.getMessage();
        } finally {
            if (deleteStmt != null) deleteStmt.close();
            if (conn != null) conn.close();
        }
    } else {
        message = "로그인 상태가 아닙니다.";
    }

    out.print(String.format("{\"status\":\"%s\", \"message\":\"%s\"}", success ? "success" : "error", message));
%>
