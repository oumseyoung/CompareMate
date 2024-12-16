<%@page import="java.sql.Date"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String userIdSession = (String)session.getAttribute("userId");
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement postStmt = null;
    PreparedStatement optionStmt = null;
    PreparedStatement bookmarkCheckStmt = null;
    ResultSet postRs = null;
    ResultSet optionRs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

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

            Timestamp currentTime = new Timestamp(System.currentTimeMillis());
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

            boolean isVotingOpen = true;
            if (votingEndTimestamp != null && currentTime.after(votingEndTimestamp)) {
                isVotingOpen = false;
            }

            String optionQuery = "SELECT po.option_id, po.option_text, po.image_url, COUNT(v.option_id) AS cnt " +
                                 "FROM poll_options po " +
                                 "LEFT JOIN votes v ON po.option_id = v.option_id " +
                                 "WHERE po.post_id = ? " +
                                 "GROUP BY po.option_id, po.option_text, po.image_url";

            optionStmt = conn.prepareStatement(optionQuery);
            optionStmt.setInt(1, postId);
            optionRs = optionStmt.executeQuery();

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

            boolean isBookmarked = false;
            if (userIdSession != null) {
                String bookmarkCheckQuery = "SELECT * FROM bookmarks WHERE user_id = ? AND post_id = ?";
                bookmarkCheckStmt = conn.prepareStatement(bookmarkCheckQuery);
                bookmarkCheckStmt.setString(1, userIdSession);
                bookmarkCheckStmt.setInt(2, postId);
                try (ResultSet bRs = bookmarkCheckStmt.executeQuery()) {
                    isBookmarked = bRs.next();
                }
                bookmarkCheckStmt.close();
            }
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
    <div class="bookmark">
        <input type="checkbox" id="bookmark-<%= postId %>" class="bookmark-checkbox" <%= isBookmarked ? "checked" : "" %> />
        <label for="bookmark-<%= postId %>">
            <img src="<%= isBookmarked ? "bookmark_filled.png" : "bookmark.png" %>" alt="북마크" class="bookmark-icon">
        </label>
    </div>
    <a href="#" class="post-link">
        <h3 class="post-title">
            <%= title %>
            <% if (!isVotingOpen) { %>
                <span class="voting-closed-text">(종료된 투표)</span>
            <% } %>
        </h3>
        <div class="post-header">
            <a href="댓글.jsp?user_id=<%= userIdFromDB %>">
                <img src="circle.png" alt="프로필" class="댓글-pic">
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
        <img src="Message square.png" alt="댓글 아이콘">
    </a>
    <hr class="comment-hr">

    <div class="comments-section hidden" id="comments-section-<%= postId %>">
        <h3 class="comment-count">댓글</h3>
        <ul id="comment-list-<%= postId %>">
            <%
            String commentQuery = "SELECT * FROM comments WHERE post_id = ? ORDER BY comment_date ASC";
            try (PreparedStatement commentStmt = conn.prepareStatement(commentQuery)) {
                commentStmt.setInt(1, postId);
                try (ResultSet commentRs = commentStmt.executeQuery()) {
                    while (commentRs.next()) {
                        String commentUserId = commentRs.getString("user_id");
                        String commentText = commentRs.getString("comment_text");
                        Timestamp commentDate = commentRs.getTimestamp("comment_date");
                        int commentId = commentRs.getInt("comment_id");
            %>
            <li>
                <div class="comment-header">
                    <img src="circle.png" alt="프로필" class="댓글-pic">
                    <span class="comment-user-id"><%= commentUserId %></span>
                    <span class="comment-date"><%= commentDate %></span>
                </div>
                <p id="comment-text-<%= commentId %>"><%= commentText %></p>
                <% if (commentUserId.equals(userIdSession)) { %>
                <div class="comment-actions">
                    <a href="#" class="edit-comment" data-comment-id="<%= commentId %>">수정</a> |
                    <a href="#" class="delete-comment" data-comment-id="<%= commentId %>">삭제</a>
                </div>
                <% } %>
            </li>
            <%
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            %>
        </ul>
        <form>
            <textarea id="comment-input-<%= postId %>" placeholder="댓글을 입력하세요"></textarea>
            <button type="button" class="add-comment-button" data-post-id="<%= postId %>">댓글 추가</button>
        </form>
    </div>
</div>
<%
        }
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
        if (bookmarkCheckStmt != null) try { bookmarkCheckStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
