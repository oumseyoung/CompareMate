<%@ page import="java.sql.*, java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    String userId = (String) session.getAttribute("userId");

    List<Map<String, String>> alerts = new ArrayList<>();

    if (userId != null) {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD)) {
            String alertQuery = "SELECT alert_id, message, post_id, created_at FROM alerts WHERE user_id = ? AND is_deleted = FALSE ORDER BY created_at DESC";
            try (PreparedStatement stmt = conn.prepareStatement(alertQuery)) {
                stmt.setString(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> alert = new HashMap<>();
                        alert.put("alertId", String.valueOf(rs.getInt("alert_id")));
                        alert.put("message", rs.getString("message"));
                        alert.put("postId", String.valueOf(rs.getInt("post_id")));
                        alert.put("createdAt", rs.getTimestamp("created_at").toString());
                        alerts.add(alert);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // JSON 응답 생성
    StringBuilder jsonResponse = new StringBuilder("[");
    for (int i = 0; i < alerts.size(); i++) {
        Map<String, String> alert = alerts.get(i);
        jsonResponse.append("{")
                    .append("\"alertId\":\"").append(alert.get("alertId")).append("\",")
                    .append("\"message\":\"").append(alert.get("message")).append("\",")
                    .append("\"postId\":\"").append(alert.get("postId")).append("\",")
                    .append("\"createdAt\":\"").append(alert.get("createdAt")).append("\"")
                    .append("}");
        if (i < alerts.size() - 1) {
            jsonResponse.append(",");
        }
    }
    jsonResponse.append("]");
    out.print(jsonResponse.toString());
%>