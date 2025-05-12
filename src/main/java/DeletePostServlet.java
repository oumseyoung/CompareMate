// DeletePostServlet.java


import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/delete_post")
public class DeletePostServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 데이터베이스 연결 정보
    private static final String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USERNAME = "root";
    private static final String DB_PASSWORD = "0000";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 응답 타입을 JSON으로 설정
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 세션에서 사용자 정보 가져오기
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            String jsonResponse = "{\"status\":\"error\",\"message\":\"로그인이 필요합니다.\"}";
            out.write(jsonResponse);
            return;
        }

        String userId = (String) session.getAttribute("userId");

        // 요청 파라미터에서 post_id 가져오기
        String postIdParam = request.getParameter("post_id");
        if (postIdParam == null || postIdParam.isEmpty()) {
            String jsonResponse = "{\"status\":\"error\",\"message\":\"유효하지 않은 게시글 ID입니다.\"}";
            out.write(jsonResponse);
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(postIdParam);
        } catch (NumberFormatException e) {
            String jsonResponse = "{\"status\":\"error\",\"message\":\"유효하지 않은 게시글 ID 형식입니다.\"}";
            out.write(jsonResponse);
            return;
        }

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement deleteCommentsStmt = null;
        PreparedStatement deleteVotesStmt = null;
        PreparedStatement deletePollOptionsStmt = null;
        PreparedStatement deleteBookmarksStmt = null;
        PreparedStatement deleteAlertsStmt = null;
        PreparedStatement deletePostStmt = null;

        try {
            // JDBC 드라이버 로드
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

            // 자동 커밋 비활성화 (트랜잭션 시작)
            conn.setAutoCommit(false);

            // 1. 게시글 소유자 확인
            String checkQuery = "SELECT user_id FROM posts WHERE post_id = ?";
            checkStmt = conn.prepareStatement(checkQuery);
            checkStmt.setInt(1, postId);
            ResultSet rs = checkStmt.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                String jsonResponse = "{\"status\":\"error\",\"message\":\"존재하지 않는 게시글입니다.\"}";
                out.write(jsonResponse);
                return;
            }

            String postOwnerId = rs.getString("user_id");
            if (!userId.equals(postOwnerId)) {
                conn.rollback();
                String jsonResponse = "{\"status\":\"error\",\"message\":\"본인의 게시글만 삭제할 수 있습니다.\"}";
                out.write(jsonResponse);
                return;
            }

            rs.close();
            checkStmt.close();

            // 2. 관련 데이터 삭제
            // 2.1 댓글 삭제
            String deleteCommentsQuery = "DELETE FROM comments WHERE post_id = ?";
            deleteCommentsStmt = conn.prepareStatement(deleteCommentsQuery);
            deleteCommentsStmt.setInt(1, postId);
            deleteCommentsStmt.executeUpdate();
            deleteCommentsStmt.close();

            // 2.2 투표 삭제
            String deleteVotesQuery = "DELETE FROM votes WHERE post_id = ?";
            deleteVotesStmt = conn.prepareStatement(deleteVotesQuery);
            deleteVotesStmt.setInt(1, postId);
            deleteVotesStmt.executeUpdate();
            deleteVotesStmt.close();

            // 2.3 투표 옵션 삭제
            String deletePollOptionsQuery = "DELETE FROM poll_options WHERE post_id = ?";
            deletePollOptionsStmt = conn.prepareStatement(deletePollOptionsQuery);
            deletePollOptionsStmt.setInt(1, postId);
            deletePollOptionsStmt.executeUpdate();
            deletePollOptionsStmt.close();

            // 2.4 북마크 삭제
            String deleteBookmarksQuery = "DELETE FROM bookmarks WHERE post_id = ?";
            deleteBookmarksStmt = conn.prepareStatement(deleteBookmarksQuery);
            deleteBookmarksStmt.setInt(1, postId);
            deleteBookmarksStmt.executeUpdate();
            deleteBookmarksStmt.close();

            // 2.5 알림 삭제
            String deleteAlertsQuery = "DELETE FROM alerts WHERE post_id = ?";
            deleteAlertsStmt = conn.prepareStatement(deleteAlertsQuery);
            deleteAlertsStmt.setInt(1, postId);
            deleteAlertsStmt.executeUpdate();
            deleteAlertsStmt.close();

            // 3. 게시글 삭제
            String deletePostQuery = "DELETE FROM posts WHERE post_id = ?";
            deletePostStmt = conn.prepareStatement(deletePostQuery);
            deletePostStmt.setInt(1, postId);
            deletePostStmt.executeUpdate();
            deletePostStmt.close();

            // 트랜잭션 커밋
            conn.commit();

            // 성공 응답
            String jsonResponse = "{\"status\":\"success\",\"message\":\"게시글이 성공적으로 삭제되었습니다.\"}";
            out.write(jsonResponse);

        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 트랜잭션 롤백
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            String jsonResponse = "{\"status\":\"error\",\"message\":\"게시글 삭제 중 오류가 발생했습니다.\"}";
            out.write(jsonResponse);
        } finally {
            // 자원 정리
            try { if (deleteAlertsStmt != null) deleteAlertsStmt.close(); } catch (SQLException ignore) {}
            try { if (deleteBookmarksStmt != null) deleteBookmarksStmt.close(); } catch (SQLException ignore) {}
            try { if (deletePollOptionsStmt != null) deletePollOptionsStmt.close(); } catch (SQLException ignore) {}
            try { if (deleteVotesStmt != null) deleteVotesStmt.close(); } catch (SQLException ignore) {}
            try { if (deleteCommentsStmt != null) deleteCommentsStmt.close(); } catch (SQLException ignore) {}
            try { if (checkStmt != null) checkStmt.close(); } catch (SQLException ignore) {}
            try { if (deletePostStmt != null) deletePostStmt.close(); } catch (SQLException ignore) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true); 
                    conn.close(); 
                }
            } catch (SQLException ignore) {}
        }
    }
}
