<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    response.setContentType("application/json; charset=UTF-8");
    // 세션에서 유저 아이디를 가져옴 (로그인 세션이 있다고 가정)
    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.print("{\"status\":\"error\",\"message\":\"로그인이 필요합니다.\"}");
        return;
    }

    String postIdStr = request.getParameter("post_id");
    String action = request.getParameter("action");

    if (postIdStr == null || action == null) {
        out.print("{\"status\":\"error\",\"message\":\"잘못된 요청입니다.\"}");
        return;
    }

    int postId = Integer.parseInt(postIdStr);

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        if ("add".equals(action)) {
            // 북마크 추가
            String insertQuery = "INSERT IGNORE INTO bookmarks(user_id, post_id) VALUES (?, ?)";
            pstmt = conn.prepareStatement(insertQuery);
            pstmt.setString(1, userId);
            pstmt.setInt(2, postId);
            int rows = pstmt.executeUpdate();
            pstmt.close();
            
            if (rows > 0) {
                out.print("{\"status\":\"success\",\"message\":\"북마크 추가 완료\"}");
            } else {
                out.print("{\"status\":\"error\",\"message\":\"이미 북마크가 존재합니다.\"}");
            }

        } else if ("remove".equals(action)) {
            // 북마크 제거
            String deleteQuery = "DELETE FROM bookmarks WHERE user_id = ? AND post_id = ?";
            pstmt = conn.prepareStatement(deleteQuery);
            pstmt.setString(1, userId);
            pstmt.setInt(2, postId);
            int rows = pstmt.executeUpdate();
            pstmt.close();
            
            if (rows > 0) {
                out.print("{\"status\":\"success\",\"message\":\"북마크 제거 완료\"}");
            } else {
                out.print("{\"status\":\"error\",\"message\":\"북마크가 존재하지 않습니다.\"}");
            }
        } else {
            out.print("{\"status\":\"error\",\"message\":\"알 수 없는 작업\"}");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"status\":\"error\",\"message\":\"서버 오류 발생\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
