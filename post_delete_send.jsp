<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.sql.*" %>

<%
Connection connection = null;
try {
    // JDBC 드라이버 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    String db_address = "jdbc:mysql://localhost:3306/practice_board?serverTimezone=UTC";
    String db_username = "root";
    String db_pwd = "0000";
    connection = DriverManager.getConnection(db_address, db_username, db_pwd);

    // 요청 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 요청 파라미터에서 게시글 ID를 가져옴
    String postId = request.getParameter("post_id");

    if (postId != null && !postId.isEmpty()) {
        // SQL DELETE 쿼리 작성 (PreparedStatement를 사용해 SQL Injection 방지)
        String deleteQuery = "DELETE FROM posts WHERE post_id = ?";
        PreparedStatement psmt = connection.prepareStatement(deleteQuery);

        // 쿼리에 게시글 ID 바인딩
        psmt.setInt(1, Integer.parseInt(postId));

        // DELETE 실행 및 결과 확인
        int rowsAffected = psmt.executeUpdate();
        if (rowsAffected > 0) {
            // 성공적으로 삭제되면 목록 페이지로 이동
            response.sendRedirect("post_list.jsp");
        } else {
            out.println("<script>alert('삭제할 게시글을 찾을 수 없습니다.'); history.back();</script>");
        }

        // 자원 정리
        psmt.close();
    } else {
        // 게시글 ID가 비어있거나 null인 경우 처리
        out.println("<script>alert('유효하지 않은 게시글 ID입니다.'); history.back();</script>");
    }
} catch (Exception ex) {
    // 오류 처리
    out.println("<script>alert('오류가 발생했습니다. 오류 메시지: " + ex.getMessage() + "'); history.back();</script>");
} finally {
    if (connection != null) {
        try {
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
%>
