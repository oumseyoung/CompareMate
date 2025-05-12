<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    String postId = request.getParameter("postId");
    String userId = (String) session.getAttribute("userId");

    if (postId == null || userId == null) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("{\"status\":\"fail\",\"message\":\"Invalid parameters\"}");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        String deleteQuery = "DELETE FROM posts WHERE post_id = ? AND user_id = ?";
        stmt = conn.prepareStatement(deleteQuery);
        stmt.setInt(1, Integer.parseInt(postId));
        stmt.setString(2, userId);

        int rowsAffected = stmt.executeUpdate();
        if (rowsAffected > 0) {
            out.print("{\"status\":\"success\",\"message\":\"Post deleted successfully\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"status\":\"fail\",\"message\":\"You are not authorized to delete this post\"}");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("{\"status\":\"fail\",\"message\":\"Server error\"}");
    } finally {
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
