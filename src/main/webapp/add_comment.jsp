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
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD)) {
                // 댓글 추가 쿼리
                String insertQuery = "INSERT INTO comments (post_id, user_id, comment_text, comment_date) VALUES (?, ?, ?, NOW())";
                try (PreparedStatement stmt = conn.prepareStatement(insertQuery)) {
                    stmt.setInt(1, Integer.parseInt(postId));
                    stmt.setString(2, userId);
                    stmt.setString(3, commentText);
                    int rowsInserted = stmt.executeUpdate();

                    if (rowsInserted > 0) {
                    	// 게시글 작성자와 제목 가져오기
                        String getPostOwner = "SELECT user_id, title FROM posts WHERE post_id = ?";
try (PreparedStatement postStmt = conn.prepareStatement(getPostOwner)) {
    postStmt.setInt(1, Integer.parseInt(postId));
    try (ResultSet rs = postStmt.executeQuery()) {
        if (rs.next()) {
            String postOwner = rs.getString("user_id");
            String postTitle = rs.getString("title");

            // 본인이 작성한 게시글에 댓글을 다는 경우 알림 생성 제외
            if (!postOwner.equals(userId)) {
                // 알림 메시지 구성
                String alertMessage = String.format("%s 게시물에 댓글이 달렸습니다.", postTitle);

                // 알림 추가
                String insertAlert = "INSERT INTO alerts (user_id, message, post_id, title, type, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
try (PreparedStatement alertStmt = conn.prepareStatement(insertAlert)) {
    alertStmt.setString(1, postOwner);       // 게시글 작성자 ID
    alertStmt.setString(2, alertMessage);   // 알림 메시지
    alertStmt.setInt(3, Integer.parseInt(postId)); // 게시글 ID
    alertStmt.setString(4, postTitle);      // 게시글 제목
    alertStmt.setString(5, "comment");      // 알림 타입
    alertStmt.executeUpdate();
}
            }
        }
    }
}

                        // 댓글 개수 조회
                        String countQuery = "SELECT COUNT(*) AS cnt FROM comments WHERE post_id = ?";
                        try (PreparedStatement countStmt = conn.prepareStatement(countQuery)) {
                            countStmt.setInt(1, Integer.parseInt(postId));
                            try (ResultSet countRs = countStmt.executeQuery()) {
                                int newCount = 0;
                                if (countRs.next()) {
                                    newCount = countRs.getInt("cnt");
                                }

                                success = true;
                                message = "댓글이 추가되었습니다.";
                                String commentDate = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
                                newCommentJSON = String.format(
                                    "{\"userId\":\"%s\", \"commentText\":\"%s\", \"commentDate\":\"%s\", \"count\":%d}",
                                    userId, commentText, commentDate, newCount
                                );
                            }
                        }
                    } else {
                        message = "댓글 추가에 실패했습니다.";
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
        }
    } else {
        message = "유효하지 않은 요청입니다.";
    }
    response.setContentType("application/json; charset=UTF-8");
    String jsonResponse = String.format(
    	    "{\"status\":\"%s\", \"message\":\"%s\", \"comment\":%s}",
    	    success ? "success" : "error",
    	    message,
    	    success ? newCommentJSON : "null"
    	);

    out.print(jsonResponse);
%>
