<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.* %>
<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // 응답 타입 설정
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    // 기본 JSON 구조
    StringBuilder json = new StringBuilder();
    json.append("{");

    // 요청 파라미터 및 세션 정보 가져오기
    String userId = (String) session.getAttribute("userId"); // 로그인된 사용자의 ID를 세션에서 가져옵니다.
    String postIdParam = request.getParameter("post_id");
    String commentText = request.getParameter("comment_text");

    // 로그인 여부 확인
    if (userId == null || userId.isEmpty()) {
        json.append("\"status\":\"error\",");
        json.append("\"message\":\"로그인이 필요합니다.\"");
        json.append("}");
        out.print(json.toString());
        return;
    }

    // 요청 파라미터 검증
    if (postIdParam == null || postIdParam.isEmpty() || commentText == null || commentText.trim().isEmpty()) {
        json.append("\"status\":\"error\",");
        json.append("\"message\":\"유효하지 않은 요청입니다.\"");
        json.append("}");
        out.print(json.toString());
        return;
    }

    int postId;
    try {
        postId = Integer.parseInt(postIdParam);
    } catch (NumberFormatException e) {
        json.append("\"status\":\"error\",");
        json.append("\"message\":\"유효하지 않은 게시글 ID입니다.\"");
        json.append("}");
        out.print(json.toString());
        return;
    }

    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        // JDBC 드라이버 로드
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 댓글 삽입 쿼리
        String insertQuery = "INSERT INTO comments (post_id, user_id, comment_text, comment_date) VALUES (?, ?, ?, NOW())";
        stmt = conn.prepareStatement(insertQuery);
        stmt.setInt(1, postId);
        stmt.setString(2, userId);
        stmt.setString(3, commentText.trim());

        int rowsAffected = stmt.executeUpdate();
        if (rowsAffected > 0) {
            json.append("\"status\":\"success\",");
            json.append("\"message\":\"댓글이 추가되었습니다.\",");
            json.append("\"commentText\":\"").append(escapeJson(commentText.trim())).append("\"");
        } else {
            json.append("\"status\":\"error\",");
            json.append("\"message\":\"댓글 추가에 실패했습니다.\"");
        }
    } catch (Exception e) {
        e.printStackTrace();
        json.append("\"status\":\"error\",");
        json.append("\"message\":\"서버 오류가 발생했습니다.\"");
    } finally {
        // 리소스 정리
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    json.append("}");

    // JSON 출력
    out.print(json.toString());

    // JSON 이스케이프 함수 (XSS 방지)
    String escapeJson(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("/", "\\/")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
%>
