<%@page import="java.sql.Date"%>
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
            // 알림 조회 쿼리
            String alertQuery = "SELECT alert_id, message, post_id, created_at FROM alerts WHERE user_id = ? AND is_deleted = FALSE ORDER BY created_at DESC";
            try (PreparedStatement stmt = conn.prepareStatement(alertQuery)) {
                stmt.setString(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> alert = new HashMap<>();
                        alert.put("alertId", String.valueOf(rs.getInt("alert_id")));
                        alert.put("message", rs.getString("message"));
                        alert.put("postId", String.valueOf(rs.getInt("post_id")));
                        alerts.add(alert);
                    }
                }
            }

            // 투표 종료 알림 생성
            String query = "SELECT post_id, title, end_date, end_time, notify FROM posts WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        int postId = rs.getInt("post_id");
                        String postTitle = rs.getString("title");
                        Date endDate = rs.getDate("end_date");
                        Time endTime = rs.getTime("end_time");
                        boolean notify = rs.getBoolean("notify");

                        if (!notify) continue; // "투표 종료 알림 받기" 체크되지 않은 게시글 무시

                        Timestamp currentTime = new Timestamp(System.currentTimeMillis());
                        Timestamp endTimestamp = (endDate != null && endTime != null)
                                ? Timestamp.valueOf(endDate.toString() + " " + endTime.toString())
                                : null;

                        if (endTimestamp != null && currentTime.after(endTimestamp)) {
                            // 알림 중복 확인
                            String checkAlertQuery = "SELECT COUNT(*) FROM alerts WHERE post_id = ? AND message = ?";
                            try (PreparedStatement checkStmt = conn.prepareStatement(checkAlertQuery)) {
                                checkStmt.setInt(1, postId);
                                checkStmt.setString(2, postTitle + " 투표가 종료되었습니다.");
                                try (ResultSet checkRs = checkStmt.executeQuery()) {
                                    if (checkRs.next() && checkRs.getInt(1) > 0) continue;
                                }
                            }

                            // 알림 삽입
                            String insertAlertQuery = "INSERT INTO alerts (user_id, message, post_id, created_at) VALUES (?, ?, ?, NOW())";
                            try (PreparedStatement alertStmt = conn.prepareStatement(insertAlertQuery)) {
                                alertStmt.setString(1, userId);
                                alertStmt.setString(2, postTitle + " 투표가 종료되었습니다.");
                                alertStmt.setInt(3, postId);
                                alertStmt.executeUpdate();
                            }
                        }
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
                .append("\"postId\":\"").append(alert.get("postId")).append("\"")
                .append("}");
        if (i < alerts.size() - 1) jsonResponse.append(",");
    }
    jsonResponse.append("]");
    out.print(jsonResponse.toString());
%>
