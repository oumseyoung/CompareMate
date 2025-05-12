<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Base64, java.io.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.print("{\"status\":\"error\", \"message\":\"로그인이 필요합니다.\"}");
        return;
    }

    String nickname = request.getParameter("nickname");
    String interests = request.getParameter("interests");
    String profileImageBase64 = request.getParameter("profileImage");

    if (nickname == null || nickname.trim().isEmpty()) {
        out.print("{\"status\":\"error\", \"message\":\"닉네임은 필수입니다.\"}");
        return;
    }
    if (interests == null) interests = "";

    String profileImagePath = "circle.png"; // 기본 프로필 이미지
    if (profileImageBase64 != null && !profileImageBase64.isEmpty()) {
        try {
            // Base64 헤더 검사 및 확장자 추출
            String base64Header = profileImageBase64.split(",")[0];
            String fileExtension = "";
            if (base64Header.contains("image/png")) {
                fileExtension = "png";
            } else if (base64Header.contains("image/jpg")) {
                fileExtension = "jpg";
            } else if (base64Header.contains("image/jpeg")) {
                fileExtension = "jpeg";
            } else {
                throw new Exception("유효하지 않은 이미지 형식입니다.");
            }

            // Base64 데이터 디코딩
            byte[] imageBytes = Base64.getDecoder().decode(profileImageBase64.split(",")[1]);

            // 업로드 폴더 생성 확인
            String uploadDir = application.getRealPath("/uploads");
            File uploadFolder = new File(uploadDir);
            if (!uploadFolder.exists()) {
                uploadFolder.mkdirs(); // 폴더가 없으면 생성
            }

            // 파일 저장
            String fileName = "profile_" + userId + "." + fileExtension;
            String filePath = uploadDir + File.separator + fileName;
            try (FileOutputStream fos = new FileOutputStream(filePath)) {
                fos.write(imageBytes);
            }
            profileImagePath = "uploads/" + fileName;
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"이미지 저장 실패: " + e.getMessage() + "\"}");
            return;
        }
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8", "root", "0000");

        String sql = "UPDATE users SET nickname = ?, interests = ?, profile_image = ? WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, nickname);
        pstmt.setString(2, interests);
        pstmt.setString(3, profileImagePath);
        pstmt.setString(4, userId);

        int result = pstmt.executeUpdate();
        if (result > 0) {
            session.setAttribute("nickname", nickname);
            session.setAttribute("profileImage", profileImagePath);
            out.print("{\"status\":\"success\", \"message\":\"정보가 업데이트되었습니다.\"}");
        } else {
            out.print("{\"status\":\"error\", \"message\":\"업데이트 실패.\"}");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"status\":\"error\", \"message\":\"서버 오류 발생.\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>