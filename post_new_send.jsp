<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%
    // 데이터베이스 연결 정보
    String dbUrl = "jdbc:mysql://localhost:3306/practice_board?serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = "0000";

    // 요청 데이터 가져오기
    request.setCharacterEncoding("UTF-8");
    String category = request.getParameter("category");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String[] pollOptions = request.getParameterValues("pollOption[]");
    String[] pollImages = request.getParameterValues("pollImage[]");
    boolean multiSelect = request.getParameter("multiSelect") != null;
    boolean notify = request.getParameter("notify") != null;
    String endDate = request.getParameter("endDate");
    String endTime = request.getParameter("endTime");

    Connection conn = null;
    PreparedStatement postStmt = null;
    PreparedStatement pollStmt = null;
    Timestamp endDateTime = null;
    try {
        if (endDate != null && !endDate.isEmpty() && endTime != null && !endTime.isEmpty()) {
            String formattedDateTime = endDate.trim() + " " + endTime.trim() + ":00";
            endDateTime = Timestamp.valueOf(formattedDateTime);
        }
    } catch (IllegalArgumentException e) {
        throw new Exception("날짜 및 시간 형식이 올바르지 않습니다. 형식: yyyy-MM-dd HH:mm");
    }

    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // 트랜잭션 처리 시작
        conn.setAutoCommit(false);

        // `posts` 테이블에 데이터 삽입
        String insertPostQuery = "INSERT INTO posts (category, title, content, multi_select, end_date, notify) VALUES (?, ?, ?, ?, ?, ?)";
        postStmt = conn.prepareStatement(insertPostQuery, Statement.RETURN_GENERATED_KEYS);
        postStmt.setString(1, category);
        postStmt.setString(2, title);
        postStmt.setString(3, content);
        postStmt.setBoolean(4, multiSelect);
        postStmt.setTimestamp(5, endDateTime);
        postStmt.setBoolean(6, notify);
        postStmt.executeUpdate();

        // 생성된 게시글 ID 가져오기
        ResultSet generatedKeys = postStmt.getGeneratedKeys();
        int postId = 0;
        if (generatedKeys.next()) {
            postId = generatedKeys.getInt(1);
        }

        // 투표 옵션 삽입
        if (pollOptions != null) {
            String insertPollQuery = "INSERT INTO poll_options (post_id, option_text, image_url) VALUES (?, ?, ?)";
            pollStmt = conn.prepareStatement(insertPollQuery);

            for (int i = 0; i < pollOptions.length; i++) {
                String optionText = pollOptions[i];
                String optionImage = (pollImages != null && pollImages.length > i) ? pollImages[i] : null;

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

        // 성공 시 목록 페이지로 리다이렉트
        response.sendRedirect("post_list.jsp");
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
