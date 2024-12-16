<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.DateTimeFormatter" %>
<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@page import="java.sql.Date"%>

<%
    request.setCharacterEncoding("UTF-8");

    // 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("userId");
    String postIdParam = request.getParameter("post_id");
    String[] optionIds = request.getParameterValues("options[]"); // option_id 사용

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement stmt = null;
    PreparedStatement insertStmt = null;
    PreparedStatement deleteStmt = null;
    ResultSet rs = null;
    ResultSet postRs = null;

    StringBuilder json = new StringBuilder();
    json.append("{");

    // 사용자 인증 확인
    if (userId == null) {
        json.append("\"status\":\"error\",");
        json.append("\"message\":\"로그인이 필요합니다.\"");
        json.append("}");
        out.print(json.toString());
        return;
    }

    // post_id와 options[] 유효성 확인
    if (postIdParam == null || optionIds == null || optionIds.length == 0) {
        json.append("\"status\":\"error\",");
        json.append("\"message\":\"유효하지 않은 요청입니다.\"");
        json.append("}");
        out.print(json.toString());
        return;
    }

    try {
        // post_id를 Integer로 변환
        int postId = Integer.parseInt(postIdParam);

        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 투표 종료 시간 가져오기
        String endTimeQuery = "SELECT end_date, end_time FROM posts WHERE post_id = ?";
        PreparedStatement endTimeStmt = conn.prepareStatement(endTimeQuery);
        endTimeStmt.setInt(1, postId);
        postRs = endTimeStmt.executeQuery();

        Timestamp votingEndTimestamp = null;
        if (postRs.next()) {
            Date endDate = postRs.getDate("end_date");
            Time endTime = postRs.getTime("end_time");
            if (endDate != null && endTime != null) {
                Calendar cal = Calendar.getInstance();
                cal.setTime(endDate);
                cal.set(Calendar.HOUR_OF_DAY, endTime.getHours());
                cal.set(Calendar.MINUTE, endTime.getMinutes());
                cal.set(Calendar.SECOND, endTime.getSeconds());
                cal.set(Calendar.MILLISECOND, 0);
                votingEndTimestamp = new Timestamp(cal.getTimeInMillis());
            }
        }
        postRs.close();
        endTimeStmt.close();

        // 현재 시간과 투표 종료 시간 비교
        Timestamp currentTime = new Timestamp(System.currentTimeMillis());
        if (votingEndTimestamp != null && currentTime.after(votingEndTimestamp)) {
            json.append("\"status\":\"error\",");
            json.append("\"message\":\"투표가 이미 종료되었습니다.\"");
            json.append("}");
            out.print(json.toString());
            return;
        }

        // 기존 투표 삭제
        String deleteQuery = "DELETE FROM votes WHERE user_id = ? AND post_id = ?";
        deleteStmt = conn.prepareStatement(deleteQuery);
        deleteStmt.setString(1, userId);
        deleteStmt.setInt(2, postId);
        deleteStmt.executeUpdate();

        // 투표 옵션 유효성 검사 및 삽입
        String insertQuery = "INSERT INTO votes (user_id, post_id, option_id) VALUES (?, ?, ?)";
        insertStmt = conn.prepareStatement(insertQuery);

        for (String optionIdStr : optionIds) {
            try {
                int optionId = Integer.parseInt(optionIdStr);

                // option_id가 해당 post_id에 속하는지 확인
                String validateQuery = "SELECT option_id FROM poll_options WHERE post_id = ? AND option_id = ?";
                stmt = conn.prepareStatement(validateQuery);
                stmt.setInt(1, postId);
                stmt.setInt(2, optionId);
                rs = stmt.executeQuery();

                if (rs.next()) {
                    insertStmt.setString(1, userId);
                    insertStmt.setInt(2, postId);
                    insertStmt.setInt(3, optionId);
                    insertStmt.addBatch();
                } else {
                    json.append("\"status\":\"error\",");
                    json.append("\"message\":\"유효하지 않은 투표 옵션입니다: ").append(optionId).append("\"");
                    json.append("}");
                    out.print(json.toString());
                    return;
                }
                rs.close();
                stmt.close();
            } catch (NumberFormatException e) {
                json.append("\"status\":\"error\",");
                json.append("\"message\":\"잘못된 옵션 ID 형식입니다.\"");
                json.append("}");
                out.print(json.toString());
                return;
            }
        }

        insertStmt.executeBatch();

        // 투표 결과 조회
        String resultQuery = "SELECT po.option_id, po.option_text, COUNT(v.option_id) as cnt " +
                     "FROM poll_options po " +
                     "LEFT JOIN votes v ON po.option_id = v.option_id " +
                     "WHERE po.post_id = ? GROUP BY po.option_id, po.option_text ORDER BY po.option_id";
        stmt = conn.prepareStatement(resultQuery);
        stmt.setInt(1, postId);
        rs = stmt.executeQuery();

        // JSON 결과 반환
        json.append("\"status\":\"success\",");
        json.append("\"message\":\"투표가 완료되었습니다.\",");
        json.append("\"results\":[");
        boolean first = true;
        while (rs.next()) {
            if (!first) json.append(",");
            json.append("{\"option_text\":\"").append(rs.getString("option_text")).append("\",");
            json.append("\"count\":").append(rs.getInt("cnt")).append("}");
            first = false;
        }
        json.append("]}");

        out.print(json.toString());
    } catch (NumberFormatException e) {
        json.setLength(0);
        json.append("{\"status\":\"error\",\"message\":\"post_id가 올바르지 않습니다.\"}");
        out.print(json.toString());
    } catch (Exception e) {
        e.printStackTrace();
        json.setLength(0);
        json.append("{\"status\":\"error\",\"message\":\"서버 오류 발생: ").append(e.getMessage()).append("\"}");
        out.print(json.toString());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (postRs != null) try { postRs.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (insertStmt != null) try { insertStmt.close(); } catch (SQLException ignore) {}
        if (deleteStmt != null) try { deleteStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
