<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String dbUrl = "jdbc:mysql://localhost:3306/compare_mate?serverTimezone=UTC&useSSL=false&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "root";
    String dbPassword = "0000";

    Connection conn = null;
    PreparedStatement selectStmt = null;
    PreparedStatement insertAlertStmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // 종료 조건을 만족하는 게시글 가져오기
        String selectQuery = "SELECT post_id, user_id, title FROM posts WHERE notify = 1 AND CONCAT(end_date, ' ', end_time) <= NOW()";
		selectStmt = conn.prepareStatement(selectQuery);
		rs = selectStmt.executeQuery();

        while (rs.next()) {
            int postId = rs.getInt("post_id");
            String userId = rs.getString("user_id");
            String title = rs.getString("title");
            
            
            String checkAlertQuery = "SELECT COUNT(*) FROM alerts WHERE user_id = ? AND post_id = ? AND type = 'vote_end'";
            PreparedStatement checkStmt = conn.prepareStatement(checkAlertQuery);
            checkStmt.setString(1, userId);
            checkStmt.setInt(2, postId);
            ResultSet alertCheck = checkStmt.executeQuery();
            alertCheck.next();
            if (alertCheck.getInt(1) > 0) {
                System.out.println("알림 중복 방지: " + postId);
                continue; // 이미 알림이 있으면 건너뜀
            }

            // 알림 삽입
         // 알림 삽입
            String insertAlertQuery = "INSERT INTO alerts (user_id, message, post_id, title, type, created_at) VALUES (?, ?, ?, ?, 'vote_end', NOW())";
            insertAlertStmt = conn.prepareStatement(insertAlertQuery);
            insertAlertStmt.setString(1, userId);
            insertAlertStmt.setString(2, title + " 투표가 종료되었습니다.");
            insertAlertStmt.setInt(3, postId);
            insertAlertStmt.setString(4, title);
            insertAlertStmt.executeUpdate();

            System.out.println("투표 종료 알림 생성 성공: " + postId);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (selectStmt != null) try { selectStmt.close(); } catch (SQLException ignore) {}
        if (insertAlertStmt != null) try { insertAlertStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
