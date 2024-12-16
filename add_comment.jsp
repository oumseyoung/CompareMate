<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    String postId = request.getParameter("post_id");
    String commentText = request.getParameter("comment_text");
    String userId = (String) session.getAttribute("userId");

    boolean success = false;
    String message = "";
    String newCommentJSON = "";

    if (postId != null && commentText != null && userId != null) {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD)) {
            String query = "INSERT INTO comments (post_id, user_id, comment_text, comment_date) VALUES (?, ?, ?, NOW())";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, Integer.parseInt(postId));
                stmt.setString(2, userId);
                stmt.setString(3, commentText);
                int rowsInserted = stmt.executeUpdate();

                if (rowsInserted > 0) {
                    success = true;
                    message = "댓글이 추가되었습니다.";
                    String commentDate = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
                    newCommentJSON = String.format(
                        "{\"userId\":\"%s\", \"commentText\":\"%s\", \"commentDate\":\"%s\"}",
                        userId, commentText, commentDate
                    );
                } else {
                    message = "댓글 추가에 실패했습니다.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
        }
    } else {
        message = "유효하지 않은 요청입니다.";
    }

    // JSON 응답 생성
    String jsonResponse = String.format(
        "{\"status\":\"%s\", \"message\":\"%s\", \"comment\":%s}",
        success ? "success" : "error",
        message,
        success ? newCommentJSON : "null"
    );

    out.print(jsonResponse);
%>
