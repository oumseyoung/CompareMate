<%@ page language="java" contentType="application/json; charset=UTF-8" 
    pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    // 응답 타입과 문자 인코딩 설정
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    // JSON 객체 생성
    JSONObject json = new JSONObject();

    // 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        json.put("status", "error");
        json.put("message", "로그인이 필요합니다.");
        out.print(json.toString());
        return; // 더 이상의 처리를 중단
    }

    // 요청 파라미터 가져오기
    String postIdStr = request.getParameter("post_id");
    String commentText = request.getParameter("comment_text");

    // 입력 검증
    if (postIdStr == null || commentText == null || commentText.trim().isEmpty()) {
        json.put("status", "error");
        json.put("message", "유효하지 않은 댓글입니다.");
        out.print(json.toString());
        return; // 더 이상의 처리를 중단
    }

    int postId;
    try {
        postId = Integer.parseInt(postIdStr.trim());
    } catch (NumberFormatException e) {
        json.put("status", "error");
        json.put("message", "유효하지 않은 게시글 ID입니다.");
        out.print(json.toString());
        return; // 더 이상의 처리를 중단
    }

    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement insertStmt = null;
    PreparedStatement userStmt = null;
    ResultSet userRs = null;

    try {
        // JDBC 드라이버 로드
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 댓글 삽입 쿼리
        String insertQuery = "INSERT INTO comments (post_id, user_id, comment_text, comment_date) VALUES (?, ?, ?, NOW())";
        insertStmt = conn.prepareStatement(insertQuery);
        insertStmt.setInt(1, postId);
        insertStmt.setString(2, userId);
        insertStmt.setString(3, commentText);
        int affectedRows = insertStmt.executeUpdate();

        if (affectedRows > 0) {
            // 사용자 닉네임 가져오기
            String userQuery = "SELECT nickname FROM users WHERE id = ?";
            userStmt = conn.prepareStatement(userQuery);
            userStmt.setString(1, userId);
            userRs = userStmt.executeQuery();

            String nickname = "익명";
            if (userRs.next()) {
                nickname = userRs.getString("nickname");
            }

            json.put("status", "success");
            json.put("commentText", commentText);
            json.put("nickname", nickname);
        } else {
            json.put("status", "error");
            json.put("message", "댓글을 추가할 수 없습니다.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        json.put("status", "error");
        json.put("message", "서버 오류가 발생했습니다.");
    } finally {
        // 리소스 정리
        if (userRs != null) try { userRs.close(); } catch (SQLException ignore) {}
        if (userStmt != null) try { userStmt.close(); } catch (SQLException ignore) {}
        if (insertStmt != null) try { insertStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    // JSON 응답 전송
    out.print(json.toString());
%>
