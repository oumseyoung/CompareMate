// PostNewSendServlet.java
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
//필요한 import 추가
import java.util.Arrays;
import java.util.List;

//...

@WebServlet("/post_new_send")
@MultipartConfig(
 fileSizeThreshold = 1024 * 1024, // 1MB
 maxFileSize = 5 * 1024 * 1024,   // 5MB
 maxRequestSize = 25 * 1024 * 1024 // 25MB
)
public class PostNewSendServlet extends HttpServlet {
 private static final long serialVersionUID = 1L;

 // 데이터베이스 연결 정보
 private String dbUrl = "jdbc:mysql://localhost:3306/compare_mate?serverTimezone=UTC&useSSL=false&useUnicode=true&characterEncoding=UTF-8";
 private String dbUser = "root";	
 private String dbPassword = "0000";

 protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
     // 세션에서 user_id 가져오기
     HttpSession session = request.getSession();
     String userId = (String) session.getAttribute("userId");
     if (userId == null) {
         response.sendRedirect("login.jsp");
         return;
     }

     // 요청 데이터 가져오기
     request.setCharacterEncoding("UTF-8");
     
     String category = request.getParameter("category");
     String title = request.getParameter("title");
     String content = request.getParameter("content");
     String[] pollOptions = request.getParameterValues("pollOption[]");
     boolean multiSelect = "on".equals(request.getParameter("multiSelect"));
     boolean notify = "on".equals(request.getParameter("notify"));
     String endDate = request.getParameter("endDate");
     String endTime = request.getParameter("endTime");

     List<String> pollOptionImageUrls = new ArrayList<>();

     // 이미지 저장 폴더 설정
     String uploadPath = getServletContext().getRealPath("/uploads/poll_options");
     File uploadDir = new File(uploadPath);
     if (!uploadDir.exists()) {
         uploadDir.mkdirs(); // 폴더가 없으면 생성
     }

     // 파일 업로드 처리
     for (Part part : request.getParts()) {
         String fieldName = part.getName();
         if ("pollOptionImage[]".equals(fieldName)) {
             String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
             if (fileName != null && !fileName.isEmpty()) {
                 // 파일 확장자 검증
                 String fileExt = "";
                 int dotIndex = fileName.lastIndexOf('.');
                 if (dotIndex >= 0 && dotIndex < fileName.length() - 1) {
                     fileExt = fileName.substring(dotIndex + 1).toLowerCase();
                 }

                 // Java 8 이하에서는 Arrays.asList 사용
                 List<String> allowedExtensions = Arrays.asList("png", "jpg", "jpeg");
                 if (!allowedExtensions.contains(fileExt)) {
                     request.setAttribute("error", "허용되지 않은 이미지 형식입니다: " + fileExt);
                     request.getRequestDispatcher("write.jsp").forward(request, response);
                     return;
                 }

                 // 고유 파일명 생성
                 String uniqueFileName = "post" + System.currentTimeMillis() + "_" + fileName;
                 String filePath = uploadPath + File.separator + uniqueFileName;
                 part.write(filePath);

                 // 이미지 URL 저장
                 String optionImageUrl = "uploads/poll_options/" + uniqueFileName;
                 pollOptionImageUrls.add(optionImageUrl);
             } else {
                 pollOptionImageUrls.add(null);
             }
         }
     }

     // pollOptionImageUrls 리스트를 pollOptions와 동일한 크기로 맞추기
     while (pollOptionImageUrls.size() < pollOptions.length) {
         pollOptionImageUrls.add(null);
     }

     // 데이터베이스 연결 및 삽입
     try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
         // 트랜잭션 시작
         conn.setAutoCommit(false);

         // 게시글 삽입
         String insertPostQuery = "INSERT INTO posts (user_id, category, title, content, multi_select, end_date, end_time, notify) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
         try (PreparedStatement postStmt = conn.prepareStatement(insertPostQuery, Statement.RETURN_GENERATED_KEYS)) {
             postStmt.setString(1, userId);
             postStmt.setString(2, category);
             postStmt.setString(3, title);
             postStmt.setString(4, content);
             postStmt.setBoolean(5, multiSelect);

             if (endDate != null && !endDate.isEmpty()) {
                 postStmt.setDate(6, Date.valueOf(endDate.trim()));
             } else {
                 postStmt.setNull(6, Types.DATE);
             }

             if (endTime != null && !endTime.isEmpty()) {
                 postStmt.setTime(7, Time.valueOf(endTime.trim() + ":00"));
             } else {
                 postStmt.setNull(7, Types.TIME);
             }

             postStmt.setBoolean(8, notify);
             postStmt.executeUpdate();

             // 생성된 게시글 ID 가져오기
             try (ResultSet generatedKeys = postStmt.getGeneratedKeys()) {
                 if (generatedKeys.next()) {
                     int postId = generatedKeys.getInt(1);

                     // 투표 옵션 삽입
                     if (pollOptions != null && pollOptions.length > 0) {
                         String insertPollQuery = "INSERT INTO poll_options (post_id, option_text, image_url) VALUES (?, ?, ?)";
                         try (PreparedStatement pollStmt = conn.prepareStatement(insertPollQuery)) {
                             for (int i = 0; i < pollOptions.length; i++) {
                                 String optionText = pollOptions[i];
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
                     }

                     // 트랜잭션 커밋
                     conn.commit();

                     // 성공 시 메인 페이지로 리다이렉트
                     response.sendRedirect("main.jsp");
                     return;
                 } else {
                     throw new SQLException("게시글 ID를 가져오지 못했습니다.");
                 }
             }
         } catch (Exception e) {
             conn.rollback(); // 오류 발생 시 롤백
             e.printStackTrace();
             request.setAttribute("error", "오류 발생: " + e.getMessage());
             request.getRequestDispatcher("write.jsp").forward(request, response);
             return;
         }
     } catch (Exception e) {
         e.printStackTrace();
         request.setAttribute("error", "데이터베이스 연결 오류: " + e.getMessage());
         request.getRequestDispatcher("write.jsp").forward(request, response);
     }
 }
}

