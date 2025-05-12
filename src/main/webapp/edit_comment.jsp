<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String commentId = request.getParameter("comment_id");
    String commentText = request.getParameter("comment_text");
    String userId = (String) session.getAttribute("userId");

    response.setContentType("application/json");
    if (commentId != null && commentText != null && userId != null) {
        String DB_URL = "jdbc:mysql://localhost:3306/compare_mate";
        String DB_USERNAME = "root";
        String DB_PASSWORD = "0000";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD)) {
            String query = "UPDATE comments SET comment_text = ? WHERE comment_id = ? AND user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, commentText);
                stmt.setInt(2, Integer.parseInt(commentId));
                stmt.setString(3, userId);

                int updatedRows = stmt.executeUpdate();
                if (updatedRows > 0) {
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
