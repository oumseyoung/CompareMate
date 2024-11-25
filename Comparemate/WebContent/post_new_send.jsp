<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@ page import="java.sql.*" %>

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
    boolean multiSelect = request.getParameter("multiSelect") != null;
    boolean notify = request.getParameter("notify") != null;
    String endDate = request.getParameter("endDate");
    String endTime = request.getParameter("endTime");
    String endDateTime = endDate + " " + endTime;

    Connection conn = null;
    PreparedStatement postStmt = null;
    PreparedStatement pollStmt = null;

    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // `posts` 테이블에 데이터 삽입
        String postQuery = "INSERT INTO posts (category, title, content, multi_select, end_date, notify) VALUES (?, ?, ?, ?, ?, ?)";
        postStmt = conn.prepareStatement(postQuery, Statement.RETURN_GENERATED_KEYS);
        postStmt.setString(1, category);
        postStmt.setString(2, title);
        postStmt.setString(3, content);
        postStmt.setBoolean(4, multiSelect);
        postStmt.setString(5, endDateTime);
        postStmt.setBoolean(6, notify);

        int rowsAffected = postStmt.executeUpdate();

        // 삽입 성공 시 게시글 ID 가져오기
        if (rowsAffected > 0) {
            ResultSet rs = postStmt.getGeneratedKeys();
            int postId = 0;
            if (rs.next()) {
                postId = rs.getInt(1);
            }

            // `poll_options` 테이블에 투표 항목 삽입
            String pollQuery = "INSERT INTO poll_options (post_id, option_text) VALUES (?, ?)";
            pollStmt = conn.prepareStatement(pollQuery);
            for (String option : pollOptions) {
                pollStmt.setInt(1, postId);
                pollStmt.setString(2, option);
                pollStmt.executeUpdate();
            }

            // 성공 시 목록 페이지로 리다이렉트
            response.sendRedirect("post_list.jsp");
        } else {
            out.println("게시글 등록에 실패했습니다.");
        }
    } catch (Exception e) {
        out.println("오류 발생: " + e.getMessage());
    } finally {
        // 자원 정리
        if (pollStmt != null) pollStmt.close();
        if (postStmt != null) postStmt.close();
        if (conn != null) conn.close();
    }
%>