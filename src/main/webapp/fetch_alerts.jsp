<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    if (userId == null) {
        out.print("{\"status\": \"error\", \"message\": \"로그인이 필요합니다.\"}");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/compare_mate", "root", "0000");

        // 필요한 데이터만 가져오는 쿼리
        String sql = "SELECT title, message, type, post_id FROM alerts WHERE user_id = ? AND is_deleted = 0 ORDER BY created_at DESC";
		stmt = conn.prepareStatement(sql);
		stmt.setString(1, userId);

		rs = stmt.executeQuery();
		StringBuilder json = new StringBuilder();
		json.append("{\"alerts\": [");

		boolean first = true;
		while (rs.next()) {
		    if (!first) json.append(",");
		    json.append(String.format(
		        "{\"title\": \"%s\", \"message\": \"%s\", \"type\": \"%s\", \"postId\": %d}",
		        rs.getString("title").replace("\"", "\\\""),
		        rs.getString("message").replace("\"", "\\\""),
		        rs.getString("type"),
		        rs.getInt("post_id")
		    ));
		    first = false;
		}
		json.append("]}");

        out.print(json.toString());
    } catch (Exception e) {
        e.printStackTrace();
        out.print(String.format("{\"status\": \"error\", \"message\": \"서버 오류 발생: %s\"}", e.getMessage().replace("\"", "\\\"")));
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
