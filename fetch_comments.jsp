<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";
    String postId = request.getParameter("post_id");

    if (postId != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

            String query = "SELECT * FROM comments WHERE post_id = ? ORDER BY comment_date ASC";
            stmt = conn.prepareStatement(query);
            stmt.setInt(1, Integer.parseInt(postId));
            rs = stmt.executeQuery();

            while (rs.next()) {
                String userId = rs.getString("user_id");
                String commentText = rs.getString("comment_text");
                Timestamp commentDate = rs.getTimestamp("comment_date");
%>
                <li>
                    <div class="comment-header">
                        <img src="circle.png" alt="프로필" class="profile-pic">
                        <span><%= userId %></span>
                        <span class="comment-date"><%= commentDate.toString() %></span>
                    </div>
                    <p><%= commentText %></p>
                </li>
<%
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    }
%>
