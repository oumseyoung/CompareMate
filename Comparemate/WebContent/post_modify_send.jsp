<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    Connection connection = null;
    PreparedStatement psmt = null;

    try {
        // JDBC 연결 설정
        Class.forName("com.mysql.cj.jdbc.Driver");
        String db_address = "jdbc:mysql://localhost:3306/practice_board?serverTimezone=UTC";
        String db_username = "root";
        String db_pwd = "0000";
        connection = DriverManager.getConnection(db_address, db_username, db_pwd);

        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");

        // 폼 데이터 가져오기
        int postId = Integer.parseInt(request.getParameter("post_id"));
        String category = request.getParameter("category");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        boolean multiSelect = request.getParameter("multiSelect") != null;
        String endDate = request.getParameter("endDate"); // YYYY-MM-DD 형식
        String endTime = request.getParameter("endTime"); // HH:mm 형식
        boolean notify = request.getParameter("notify") != null;
        
     // endDate와 endTime이 모두 입력되었는지 확인
        Timestamp endDateTime = null;
        if (endDate != null && !endDate.isEmpty() && endTime != null && !endTime.isEmpty()) {
            String dateTimeString = endDate + " " + endTime + ":00"; // YYYY-MM-DD HH:mm:ss 형식으로 합치기
            endDateTime = Timestamp.valueOf(dateTimeString);
        }

        // 업데이트 쿼리
        String updateQuery = "UPDATE posts SET category = ?, title = ?, content = ?, multi_select = ?, end_date = ?, notify = ? WHERE post_id = ?";
        psmt = connection.prepareStatement(updateQuery);
        psmt.setString(1, category);
        psmt.setString(2, title);
        psmt.setString(3, content);
        psmt.setBoolean(4, multiSelect);
        psmt.setTimestamp(5, endDateTime); // 합쳐진 Timestamp 사용
        psmt.setBoolean(6, notify);
        psmt.setInt(7, postId);


        // 쿼리 실행
        int rowsUpdated = psmt.executeUpdate();

        if (rowsUpdated > 0) {
            response.sendRedirect("post_list.jsp");
        } else {
            out.println("게시글 수정에 실패했습니다.");
        }
    } catch (Exception ex) {
        out.println("오류 발생: " + ex.getMessage());
    } finally {
        if (psmt != null) try { psmt.close(); } catch (Exception e) {}
        if (connection != null) try { connection.close(); } catch (Exception e) {}
    }
%>
