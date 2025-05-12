<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String commentId = request.getParameter("comment_id");
    String userId = (String) session.getAttribute("userId");

    response.setContentType("application/json");
    if (commentId != null && userId != null) {
        String DB_URL = "jdbc:mysql://localhost:3306/compare_mate";
        String DB_USERNAME = "root";
        String DB_PASSWORD = "0000";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD)) {
            String query = "DELETE FROM comments WHERE comment_id = ? AND user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, Integer.parseInt(commentId));
                stmt.setString(2, userId);

                int deletedRows = stmt.executeUpdate();
                if (deletedRows > 0) {
                    out.print("{\"status\":\"success\"}");
                } else {
                    out.print("{\"status\":\"fail\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\"}");
        }
    } else {
        out.print("{\"status\":\"invalid\"}");
    }
%>
