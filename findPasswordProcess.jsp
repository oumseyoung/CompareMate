<%@ page contentType="text/plain; charset=UTF-8" language="java" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    // 불필요한 공백 제거
    String userId = request.getParameter("userId").trim();
    String email = request.getParameter("email").trim();

    // 데이터베이스 연결 정보
    String url = "jdbc:mysql://localhost:3306/compare_mate";
    String dbUser = "lee";
    String dbPassword = "lee1202";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
        PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM compare_mate WHERE id = ? AND email = ?");
        pstmt.setString(1, userId);
        pstmt.setString(2, email);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            // 인증 성공
            out.print("SUCCESS");
        } else {
            // 인증 실패
            out.print("입력하신 정보와 일치하는 계정이 없습니다.");
        }

        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.print("오류가 발생했습니다: " + e.getMessage());
    }
%>
