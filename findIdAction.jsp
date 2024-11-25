<%@ page contentType="text/plain; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String email = request.getParameter("email");
    String id = "";

    // 데이터베이스 연결 정보
    String url = "jdbc:mysql://localhost:3306/compare_mate";
    String dbUser = "lee";
    String dbPassword = "lee1202";

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
        PreparedStatement pstmt = conn.prepareStatement("SELECT id FROM compare_mate WHERE email = ?");
        pstmt.setString(1, email);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            id = rs.getString("id");
            out.print("회원님의 아이디는 '" + id + "' 입니다.");
        } else {
            out.print("입력하신 이메일로 가입된 아이디가 없습니다.");
        }

        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.print("오류가 발생했습니다: " + e.getMessage());
    }
%>
