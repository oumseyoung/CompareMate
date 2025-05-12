<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.io.*, javax.servlet.*, javax.servlet.http.*, javax.servlet.annotation.*" %>
<%@ page import="java.nio.file.Paths" %>
<%
    // 데이터베이스 연결 정보
    String dbUrl = "jdbc:mysql://localhost:3306/compare_mate?serverTimezone=UTC&useSSL=false&useUnicode=true&characterEncoding=UTF-8";
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
    String boundary = null;
    String contentTypeHeader = request.getContentType();
    if (contentTypeHeader != null && contentTypeHeader.startsWith("multipart/form-data")) {
        int boundaryIndex = contentTypeHeader.indexOf("boundary=");
        if (boundaryIndex != -1) {
            boundary = contentTypeHeader.substring(boundaryIndex + 9);
            boundary = "--" + boundary;
        }
    }

    if (boundary == null) {
        out.println("Invalid multipart/form-data request.");
        return;
    }

    // Initialize variables
    String category = request.getParameter("category");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    List<String> pollOptions = new ArrayList<>();
    List<String> pollOptionImageUrls = new ArrayList<>();
    String multiSelect = request.getParameter("multiSelect");
    String notifyParam = request.getParameter("notify");
    boolean notifyFlag = notifyParam != null && notifyParam.equals("1");
    String endDate = request.getParameter("endDate");
    String endTime = request.getParameter("endTime");
    boolean multiSelectFlag = (multiSelect != null && multiSelect.equalsIgnoreCase("on"));

    Connection conn = null;
    PreparedStatement postStmt = null;

    // 이미지 저장 폴더 설정
    String uploadPath = application.getRealPath("/uploads/poll_options");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs(); // 폴더가 없으면 생성
    }

    // Read the input stream
    ServletInputStream inputStream = request.getInputStream();
    BufferedInputStream bis = new BufferedInputStream(inputStream);
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    byte[] buffer = new byte[1024];
    int bytesRead;
    while ((bytesRead = bis.read(buffer)) != -1) {
        baos.write(buffer, 0, bytesRead);
    }
    byte[] allBytes = baos.toByteArray();
    String allContent = new String(allBytes, "UTF-8"); // ISO-8859-1에서 UTF-8로 변경

    // Split the request by boundary
    String[] parts = allContent.split(boundary);
    for (String part : parts) {
        if (part.equals("--") || part.equals("--\r\n")) {
            continue; // End boundary
        }

        // Separate headers and body
        int headerEndIndex = part.indexOf("\r\n\r\n");
        if (headerEndIndex == -1) {
            continue; // Invalid part
        }

        String headers = part.substring(0, headerEndIndex);
        String body = part.substring(headerEndIndex + 4, part.length() - 2); // Remove trailing \r\n

        // Parse headers
        String[] headerLines = headers.split("\r\n");
        String partName = null;
        String fileName = null;

        for (String header : headerLines) {
            if (header.toLowerCase().startsWith("content-disposition:")) {
                // Example: Content-Disposition: form-data; name="pollOption[]"; filename="image1.png"
                String[] headerParts = header.split(";");
                for (String headerPart : headerParts) {
                    headerPart = headerPart.trim();
                    if (headerPart.startsWith("name=")) {
                        partName = headerPart.substring(5).replaceAll("\"", "");
                    } else if (headerPart.startsWith("filename=")) {
                        fileName = headerPart.substring(9).replaceAll("\"", "");
                    }
                }
            }
        }

        if (partName == null) {
            continue; // No name found
        }

        if (fileName != null && !fileName.isEmpty()) {
            // File field
            // Extract file extension
            String fileExt = "";
            int dotIndex = fileName.lastIndexOf('.');
            if (dotIndex >= 0 && dotIndex < fileName.length() - 1) {
                fileExt = fileName.substring(dotIndex + 1).toLowerCase();
            }

            // Validate file extension
            List<String> allowedExtensions = Arrays.asList("png", "jpg", "jpeg");
            if (!allowedExtensions.contains(fileExt)) {
                out.println("허용되지 않은 이미지 형식입니다: " + fileExt);
                return;
            }

            // Generate unique file name
            String uniqueFileName = "post" + System.currentTimeMillis() + "_" + fileName;
            String filePath = uploadPath + File.separator + uniqueFileName;
            File file = new File(filePath);

            // Write file bytes
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(body.getBytes("UTF-8")); // ISO-8859-1에서 UTF-8로 변경
            fos.close();

            // Save the image URL
            String optionImageUrl = "uploads/poll_options/" + uniqueFileName;
            pollOptionImageUrls.add(optionImageUrl);
        } else {
            // Text field
            String value = body.trim();
            switch (partName) {
                case "category":
                    category = value;
                    break;
                case "title":
                    title = value;
                    break;
                case "content":
                    content = value;
                    break;
                case "pollOption[]":
                    pollOptions.add(value);
                    break;
                case "multiSelect":
                    multiSelect = value; // 문자열로 저장
                    break;
                case "notify":
                    // value가 null인지 먼저 확인
                    if (value != null && value.equals("1")) {
                        notifyFlag = true; // 체크박스 선택 시 true로 설정
                    } else {
                        notifyFlag = false; // 선택되지 않은 경우 false로 설정
                    }
                    break;
                case "endDate":
                    endDate = value;
                    break;
                case "endTime":
                    endTime = value;
                    break;
                default:
                    // Ignore other fields
                    break;
            }
        }
    }

    // Ensure pollOptionImageUrls has the same size as pollOptions
    while (pollOptionImageUrls.size() < pollOptions.size()) {
        pollOptionImageUrls.add(null);
    }

    // 데이터베이스 연결 및 삽입
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
        
     // 데이터 검증
        if (category == null || title == null || content == null || category.isEmpty() || title.isEmpty() || content.isEmpty()) {
            throw new IllegalArgumentException("필수 입력 데이터가 누락되었습니다.");
        }
        System.out.println("입력 데이터 확인: " + category + ", " + title + ", " + content);

        // `posts` 테이블에 데이터 삽입 (user_id 포함)
        String insertPostQuery = "INSERT INTO posts (user_id, category, title, content, multi_select, end_date, end_time, notify) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		postStmt = conn.prepareStatement(insertPostQuery, Statement.RETURN_GENERATED_KEYS);
		postStmt.setString(1, userId);
		postStmt.setString(2, category);
		postStmt.setString(3, title);
		postStmt.setString(4, content);
		postStmt.setBoolean(5, multiSelectFlag);
		postStmt.setDate(6, sqlEndDate);
		postStmt.setTime(7, sqlEndTime);
		postStmt.setBoolean(8, notifyFlag); // notifyFlag 값 저장
        int rowsAffected = postStmt.executeUpdate();
        
        if (rowsAffected > 0) {
            // 데이터 삽입 성공
            conn.commit();
            response.sendRedirect("main.jsp");
        } else {
            throw new SQLException("게시글 데이터 삽입 실패");
        }

        // 생성된 게시글 ID 가져오기
        ResultSet generatedKeys = postStmt.getGeneratedKeys();
        int postId = 0;
        if (generatedKeys.next()) {
            postId = generatedKeys.getInt(1);
        } else {
            throw new SQLException("게시글 ID를 가져오지 못했습니다.");
        }
        
        if (notifyFlag && sqlEndDate != null && sqlEndTime != null) {
            String insertAlertQuery = "INSERT INTO alerts (user_id, message, post_id, title, type, created_at) VALUES (?, ?, ?, ?, 'vote_end', NOW())";
            PreparedStatement alertStmt = conn.prepareStatement(insertAlertQuery);
            alertStmt.setString(1, userId);
            alertStmt.setString(2, title + " 투표가 종료되었습니다.");
            alertStmt.setInt(3, postId);
            alertStmt.setString(4, title);
            alertStmt.executeUpdate();
            alertStmt.close();
        }

     // 투표 옵션 삽입
        if (!pollOptions.isEmpty()) {
            String insertPollQuery = "INSERT INTO poll_options (post_id, option_text, image_url) VALUES (?, ?, ?)";
            pollStmt = conn.prepareStatement(insertPollQuery);

            for (int i = 0; i < pollOptions.size(); i++) {
                String optionText = pollOptions.get(i);
                String optionImageUrl = (i < pollOptionImageUrls.size()) ? pollOptionImageUrls.get(i) : null;

                if (optionText != null && !optionText.trim().isEmpty()) {
                    pollStmt.setInt(1, postId);
                    pollStmt.setString(2, optionText);
                    pollStmt.setString(3, optionImageUrl);
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
        e.printStackTrace();
        out.println("오류 발생: " + e.getMessage());
    } finally {
        // 자원 정리
        if (pollStmt != null) try { pollStmt.close(); } catch (Exception e) {}
        if (postStmt != null) try { postStmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
