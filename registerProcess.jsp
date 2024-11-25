<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
    // 파라미터 가져오기
    String id = request.getParameter("id");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirm_password");
    String nickname = request.getParameter("nickname");

    String jsonResponse = "";

    // 입력 값 검증
    if (id == null || email == null || password == null || confirmPassword == null || nickname == null ||
        id.isEmpty() || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty() || nickname.isEmpty()) {
        jsonResponse = "{\"status\":\"error\",\"message\":\"모든 필드를 입력해주세요.\"}";
    } else if (!password.equals(confirmPassword)) {
        jsonResponse = "{\"status\":\"error\",\"message\":\"비밀번호가 일치하지 않습니다.\"}";
    } else {
        try {
            // JDBC 드라이버 로드
            Class.forName("com.mysql.cj.jdbc.Driver");
            // 데이터베이스 연결
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/compare_mate", "lee", "lee1202");
            
            // 아이디 중복 확인
            String checkSql = "SELECT COUNT(*) FROM compare_mate WHERE id = ?";
            PreparedStatement checkPstmt = conn.prepareStatement(checkSql);
            checkPstmt.setString(1, id);
            ResultSet rs = checkPstmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                jsonResponse = "{\"status\":\"error\",\"message\":\"이미 사용 중인 아이디입니다.\"}";
            } else {
                // 사용자 정보 삽입
                String insertSql = "INSERT INTO compare_mate (id, email, password, nickname) VALUES (?, ?, ?, ?)";
                PreparedStatement insertPstmt = conn.prepareStatement(insertSql);
                insertPstmt.setString(1, id);
                insertPstmt.setString(2, email);
                insertPstmt.setString(3, password);
                insertPstmt.setString(4, nickname);

                int rows = insertPstmt.executeUpdate();
                if (rows > 0) {
                    jsonResponse = "{\"status\":\"success\",\"message\":\"회원가입이 완료되었습니다.\"}";
                } else {
                    jsonResponse = "{\"status\":\"error\",\"message\":\"회원가입에 실패했습니다. 다시 시도해주세요.\"}";
                }

                insertPstmt.close();
            }

            // 리소스 정리
            rs.close();
            checkPstmt.close();
            conn.close();
        } catch (Exception e) {
            // 따옴표 이스케이프 처리
            String errorMsg = e.getMessage().replace("\"", "\\\"");
            jsonResponse = "{\"status\":\"error\",\"message\":\"오류가 발생했습니다: " + errorMsg + "\"}";
        }
    }

    // JSON 응답 반환
    out.print(jsonResponse);
    out.flush();
%>
