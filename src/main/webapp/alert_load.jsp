<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.print("<ul id='alert-list'><li>로그인이 필요합니다.</li></ul>");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    List<String> alerts = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/compare_mate", "root", "0000");

        String sql = "SELECT message FROM alerts WHERE user_id = ? AND is_deleted = 0 ORDER BY created_at DESC";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, userId);
        rs = stmt.executeQuery();

        while (rs.next()) {
            alerts.add(rs.getString("message"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<ul id="alert-list">
    <% if (alerts.isEmpty()) { %>
        <li>알림이 없습니다.</li>
    <% } else { %>
        <% for (String message : alerts) { %>
            <li class="alert-item">
                <img src="circle.png" alt="프로필" />
                <span><%= message %></span>
            </li>
        <% } %>
    <% } %>
</ul>
