<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%
    // 데이터베이스 연결 정보
    String dbUrl = "jdbc:mysql://localhost:3306/compare_mate?serverTimezone=UTC";
    String dbUser = "root";	
    String dbPassword = "0000";

    // 세션에서 user_id 가져오기
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        // 로그인되지 않은 경우 처리 (예: 로그인 페이지로 리다이렉트)
        response.sendRedirect("login.jsp");
        return;
    }

    // 요청 데이터 가져오기
    request.setCharacterEncoding("UTF-8");
    String category = request.getParameter("category");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String[] pollOptions = request.getParameterValues("pollOption[]");
    // 파일 업로드는 별도의 처리 필요 (현재는 이미지 URL로 가정)
    // String[] pollImages = request.getParameterValues("pollImage[]"); // 파일 업로드 구현 시 추가
    boolean multiSelect = request.getParameter("multiSelect") != null;
    boolean notify = request.getParameter("notify") != null;
    String endDate = request.getParameter("endDate");
    String endTime = request.getParameter("endTime");

    Connection conn = null;
    PreparedStatement postStmt = null;
    PreparedStatement pollStmt = null;

    java.sql.Date sqlEndDate = null;
    java.sql.Time sqlEndTime = null;

    try {
        if (endDate != null && !endDate.isEmpty()) {
            sqlEndDate = java.sql.Date.valueOf(endDate.trim());
        }
    } catch (IllegalArgumentException e) {
        throw new Exception("날짜 형식이 올바르지 않습니다. 형식: yyyy-MM-dd");
    }

    try {
        if (endTime != null && !endTime.isEmpty()) {
            sqlEndTime = java.sql.Time.valueOf(endTime.trim() + ":00");
        }
    } catch (IllegalArgumentException e) {
        throw new Exception("시간 형식이 올바르지 않습니다. 형식: HH:mm");
    }

    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // 트랜잭션 처리 시작
        conn.setAutoCommit(false);

        // `posts` 테이블에 데이터 삽입 (user_id 포함)
        String insertPostQuery = "INSERT INTO posts (user_id, category, title, content, multi_select, end_date, end_time, notify) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		postStmt = conn.prepareStatement(insertPostQuery, Statement.RETURN_GENERATED_KEYS);
        postStmt.setString(1, userId); // user_id 설정
        postStmt.setString(2, category);
        postStmt.setString(3, title);
        postStmt.setString(4, content);
        postStmt.setBoolean(5, multiSelect);
        postStmt.setDate(6, sqlEndDate != null ? sqlEndDate : null);
        postStmt.setTime(7, sqlEndTime != null ? sqlEndTime : null);
        postStmt.setBoolean(8, notify);

        if (sqlEndDate != null) {
            postStmt.setDate(6, sqlEndDate);
        } else {
            postStmt.setNull(6, java.sql.Types.DATE);
        }

        if (sqlEndTime != null) {
            postStmt.setTime(7, sqlEndTime);
        } else {
            postStmt.setNull(7, java.sql.Types.TIME);
        }

        postStmt.setBoolean(8, notify);
        postStmt.executeUpdate();

        // 생성된 게시글 ID 가져오기
        ResultSet generatedKeys = postStmt.getGeneratedKeys();
        int postId = 0;
        if (generatedKeys.next()) {
            postId = generatedKeys.getInt(1);
        } else {
            throw new SQLException("게시글 ID를 가져오지 못했습니다.");
        }

        // 투표 옵션 삽입
        if (pollOptions != null) {
            String insertPollQuery = "INSERT INTO poll_options (post_id, option_text, image_url) VALUES (?, ?, ?)";
            pollStmt = conn.prepareStatement(insertPollQuery);

            for (int i = 0; i < pollOptions.length; i++) {
                String optionText = pollOptions[i];
                // 이미지 업로드 처리 시 image_url 설정
                String optionImage = null; // 현재는 이미지 업로드 미구현

                if (optionText != null && !optionText.trim().isEmpty()) {
                    pollStmt.setInt(1, postId);
                    pollStmt.setString(2, optionText);
                    pollStmt.setString(3, optionImage);
                    pollStmt.addBatch();
                }
            }
            pollStmt.executeBatch();
        }

        // 트랜잭션 커밋
        conn.commit();

        // 성공 시 메인 페이지로 리다이렉트
        response.sendRedirect("main.jsp");
    } catch (Exception e) {
        if (conn != null) conn.rollback(); // 오류 발생 시 롤백
        out.println("오류 발생: " + e.getMessage());
    } finally {
        // 자원 정리
        if (pollStmt != null) try { pollStmt.close(); } catch (Exception e) {}
        if (postStmt != null) try { postStmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
