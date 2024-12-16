<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    response.setContentType("application/json; charset=UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.print("{\"status\":\"error\",\"message\":\"로그인이 필요합니다.\"}");
        return;
    }

    String nickname = request.getParameter("nickname");
    String interests = request.getParameter("interests");
    if (nickname == null || nickname.trim().isEmpty()) {
        out.print("{\"status\":\"error\",\"message\":\"닉네임은 필수입니다.\"}");
        return;
    }
    if (interests == null) interests = "";

    // DB 업데이트
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        String updateQuery = "UPDATE users SET nickname = ?, interests = ? WHERE id = ?";
        pstmt = conn.prepareStatement(updateQuery);
        pstmt.setString(1, nickname);
        pstmt.setString(2, interests);
        pstmt.setString(3, userId);

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
            out.print("{\"status\":\"success\",\"message\":\"업데이트 완료\"}");
        } else {
            out.print("{\"status\":\"error\",\"message\":\"업데이트 실패\"}");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"status\":\"error\",\"message\":\"서버 오류 발생\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore){}
        if (conn != null) try { conn.close(); } catch (SQLException ignore){}
    }
%>
