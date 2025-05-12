<%@ page contentType="text/plain; charset=UTF-8" language="java" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    String userId = request.getParameter("userId").trim();
    String newPassword = request.getParameter("newPassword").trim();

    // 데이터베이스 연결 정보
    String url = "jdbc:mysql://localhost:3306/compare_mate";
    String dbUser = "root";
    String dbPassword = "0000";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);

        PreparedStatement pstmt = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?");
        pstmt.setString(1, newPassword); // 비밀번호 해싱 시 hashedPassword 사용
        pstmt.setString(2, userId);

        int updatedRows = pstmt.executeUpdate();

        if (updatedRows > 0) {
            out.print("비밀번호가 성공적으로 변경되었습니다.");
        } else {
            out.print("비밀번호 변경에 실패했습니다.");
        }

        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.print("오류가 발생했습니다: " + e.getMessage());
    }
%>
