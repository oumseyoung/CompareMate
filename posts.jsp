<%@page import="java.sql.Date"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement postStmt = null;
    PreparedStatement optionStmt = null;
    ResultSet postRs = null;
    ResultSet optionRs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 모든 게시글을 가져오는 쿼리
        String postQuery = "SELECT * FROM posts ORDER BY reg_date DESC";
        postStmt = conn.prepareStatement(postQuery);
        postRs = postStmt.executeQuery();

        while (postRs.next()) {
            int postId = postRs.getInt("post_id");
            String userIdFromDB = postRs.getString("user_id");
            String title = postRs.getString("title");
            String content = postRs.getString("content");
            String category = postRs.getString("category");
            boolean multiSelect = postRs.getBoolean("multi_select");
            Timestamp regDate = postRs.getTimestamp("reg_date");
            Date endDate = postRs.getDate("end_date");
            Time endTime = postRs.getTime("end_time");

            // 현재 서버 시간 가져오기
            Timestamp currentTime = new Timestamp(System.currentTimeMillis());

            // 투표 종료 시간 결합
            Timestamp votingEndTimestamp = null;
            if (endDate != null && endTime != null) {
                Calendar cal = Calendar.getInstance();
                cal.setTime(endDate);
                cal.set(Calendar.HOUR_OF_DAY, endTime.getHours());
                cal.set(Calendar.MINUTE, endTime.getMinutes());
                cal.set(Calendar.SECOND, endTime.getSeconds());
                cal.set(Calendar.MILLISECOND, 0);
                votingEndTimestamp = new Timestamp(cal.getTimeInMillis());
            }

            // 투표 가능 여부 결정
            boolean isVotingOpen = true;
            if (votingEndTimestamp != null && currentTime.after(votingEndTimestamp)) {
                isVotingOpen = false;
            }

            // 옵션 데이터를 리스트에 저장
            String optionQuery = "SELECT po.option_id, po.option_text, po.image_url, COUNT(v.option_id) AS cnt " +
                                 "FROM poll_options po " +
                                 "LEFT JOIN votes v ON po.option_id = v.option_id " +
                                 "WHERE po.post_id = ? " +
                                 "GROUP BY po.option_id, po.option_text, po.image_url";

            optionStmt = conn.prepareStatement(optionQuery);
            optionStmt.setInt(1, postId);
            optionRs = optionStmt.executeQuery();

            // 옵션 리스트 생성
            List<Map<String, String>> options = new ArrayList<>();
            while (optionRs.next()) {
                Map<String, String> option = new HashMap<>();
                option.put("optionId", String.valueOf(optionRs.getInt("option_id")));
                option.put("optionText", optionRs.getString("option_text"));
                option.put("imageUrl", optionRs.getString("image_url"));
                option.put("voteCount", String.valueOf(optionRs.getInt("cnt")));
                options.add(option);
            }
            optionRs.close();
            optionStmt.close();
%>

<!-- 게시글 -->
<div class="post" data-category="<%= category %>" data-post-id="<%= postId %>">
    <script>
        var postData_<%= postId %> = {
            postId: <%= postId %>,
            endDate: "<%= (endDate != null) ? endDate.toString() : "" %>",
            endTime: "<%= (endTime != null) ? endTime.toString() : "" %>",
            multiSelect: <%= multiSelect %>,
            isVotingOpen: <%= isVotingOpen %>
        };
    </script>
    <a href="#" class="post-link">
        <div class="bookmark">
            <input type="checkbox" id="bookmark-<%= postId %>" class="bookmark-checkbox" />
            <label for="bookmark-<%= postId %>">
                <img src="bookmark.png" alt="북마크" class="bookmark-icon">
            </label>
        </div>
        <h3 class="post-title">
            <%= title %>
            <% if (!isVotingOpen) { %>
                <span class="voting-closed-text">(종료된 투표)</span>
            <% } %>
        </h3>
        <div class="post-header">
            <a href="profilepage.jsp?user_id=<%= userIdFromDB %>">
                <img src="circle.png" alt="프로필" class="profile-pic">
            </a>
            <div>
                <span class="username"><%= userIdFromDB %></span>
                <span class="date"><%= regDate.toString() %></span>
            </div>
        </div>
        <p><%= content %></p>
    </a>
    <div class="poll" data-post-id="<%= postId %>" data-multiple-choice="<%= multiSelect %>">
        <div class="poll-header">
            <img src="vote.png" alt="투표 아이콘" />
            <span>투표</span>
            <span><%= multiSelect ? "복수선택 가능" : "복수선택 불가능" %></span>
        </div>
        <div class="image-popup hidden" id="image-popup-<%= postId %>">
            <div class="popup-content">
                <img class="popup-image" src="" alt="팝업 이미지" />
                <button class="close-popup" type="button">닫기</button>
            </div>
        </div>
        <%
            for (Map<String, String> option : options) {
                String inputType = multiSelect ? "checkbox" : "radio";
        %>
        <label class="poll-option <%= isVotingOpen ? "" : "disabled" %>">
            <input
                type="<%= inputType %>"
                id="option<%= option.get("optionId") %>-<%= postId %>"
                name="vote-<%= postId %>"
                value="<%= option.get("optionId") %>"
                data-post-id="<%= postId %>"
                <%= isVotingOpen ? "" : "disabled" %>
            />
            <span><%= option.get("optionText") %></span>
            <span class="vote-count">(<%= option.get("voteCount") %>표)</span>
            <img src="<%= (option.get("imageUrl") != null && !option.get("imageUrl").isEmpty()) ? option.get("imageUrl") : "image.png" %>" 
                 alt="항목 이미지" class="poll-option-image" />
        </label>
        <% } %>
        <button class="vote-button" type="button" data-post-id="<%= postId %>" <%= isVotingOpen ? "" : "disabled" %>>투표하기</button>
    </div><br>
    <a href="#" class="comment-button" data-post-id="<%= postId %>">
        <img src="Message square.png" alt="댓글 이미지" />
    </a>
    <hr class="comment-hr">

    <!-- Comments Section (Initially Hidden) -->
    <div class="comments-section hidden" id="comments-section-<%= postId %>">
        <h3 class="comment-count">댓글 0</h3>
        <ul id="comment-list-<%= postId %>">
            <!-- Existing comments will be loaded here dynamically -->
        </ul>
        <textarea id="comment-input-<%= postId %>" placeholder="댓글을 입력하세요"></textarea>
        <button class="add-comment-button" data-post-id="<%= postId %>">댓글 추가</button>
    </div>
</div>
<%
        } // 게시글 반복 끝
        postRs.close();
        postStmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (optionRs != null) try { optionRs.close(); } catch (SQLException ignore) {}
        if (optionStmt != null) try { optionStmt.close(); } catch (SQLException ignore) {}
        if (postRs != null) try { postRs.close(); } catch (SQLException ignore) {}
        if (postStmt != null) try { postStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
