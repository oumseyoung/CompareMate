<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    Connection connection = null;
    PreparedStatement psmt = null;

    try {
        // JDBC 연결 설정
        Class.forName("com.mysql.cj.jdbc.Driver");
        String db_address = "jdbc:mysql://localhost:3306/compare_mate?serverTimezone=UTC";
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

        // 게시글 업데이트 쿼리
        String updateQuery = "UPDATE posts SET category = ?, title = ?, content = ?, multi_select = ?, end_date = ?, notify = ? WHERE post_id = ?";
        psmt = connection.prepareStatement(updateQuery);
        psmt.setString(1, category);
        psmt.setString(2, title);
        psmt.setString(3, content);
        psmt.setBoolean(4, multiSelect);
        psmt.setTimestamp(5, endDateTime); // 합쳐진 Timestamp 사용
        psmt.setBoolean(6, notify);
        psmt.setInt(7, postId);

        // 게시글 업데이트 실행
        int rowsUpdated = psmt.executeUpdate();
        psmt.close();

        // 폼에서 전달된 투표 옵션 데이터 가져오기
        String[] optionIds = request.getParameterValues("optionId[]");
        String[] pollOptions = request.getParameterValues("pollOption[]");

        // 투표 옵션 업데이트 및 삽입
        if (pollOptions != null && optionIds != null) {
            for (int i = 0; i < pollOptions.length; i++) {
                String optionIdStr = optionIds[i];
                String optionText = pollOptions[i];

                if (optionIdStr != null && !optionIdStr.trim().isEmpty()) {
                    // 기존 항목 업데이트
                    int optionId = Integer.parseInt(optionIdStr);
                    String updateOptionQuery = "UPDATE poll_options SET option_text = ? WHERE option_id = ?";
                    psmt = connection.prepareStatement(updateOptionQuery);
                    psmt.setString(1, optionText);
                    psmt.setInt(2, optionId);
                    psmt.executeUpdate();
                    psmt.close();
                } else {
                    // 새 항목 삽입
                    String insertOptionQuery = "INSERT INTO poll_options (post_id, option_text) VALUES (?, ?)";
                    psmt = connection.prepareStatement(insertOptionQuery);
                    psmt.setInt(1, postId);
                    psmt.setString(2, optionText);
                    psmt.executeUpdate();
                    psmt.close();
                }
            }
        }

        // 수정 완료 후 리디렉션
        response.sendRedirect("post_list.jsp");
    } catch (Exception ex) {
        out.println("오류 발생: " + ex.getMessage());
    } finally {
        if (psmt != null) try { psmt.close(); } catch (Exception e) {}
        if (connection != null) try { connection.close(); } catch (Exception e) {}
    }
%>
