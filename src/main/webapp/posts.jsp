<%@page import="java.sql.Date"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String userIdSession = (String)session.getAttribute("userId");
    String profileImage = (String) session.getAttribute("profileImage");
    String nickname = (String) session.getAttribute("nickname");
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement postStmt = null;
    PreparedStatement optionStmt = null;
    PreparedStatement bookmarkCheckStmt = null;
    PreparedStatement hasVotedStmt = null;
    ResultSet postRs = null;
    ResultSet optionRs = null;
    PreparedStatement authorStmt = null;
    ResultSet authorRs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        String category = request.getParameter("category");
        String postQuery;
        if (category == null || category.equals("전체 게시글")) {
            postQuery = "SELECT * FROM posts ORDER BY reg_date DESC";
            postStmt = conn.prepareStatement(postQuery);
        } else {
            postQuery = "SELECT * FROM posts WHERE category = ? ORDER BY reg_date DESC";
            postStmt = conn.prepareStatement(postQuery);
            postStmt.setString(1, category);
        }

        postRs = postStmt.executeQuery();

        while (postRs.next()) {
            int postId = postRs.getInt("post_id");
            String userIdFromDB = postRs.getString("user_id");
            String title = postRs.getString("title");
            String content = postRs.getString("content");
            String categoryDB = postRs.getString("category");
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

            // 옵션 조회
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

            // 북마크 여부 확인
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

            // 댓글 개수 구하기
            int commentCount = 0;
            String commentCountQuery = "SELECT COUNT(*) AS cnt FROM comments WHERE post_id = ?";
            try (PreparedStatement countStmt = conn.prepareStatement(commentCountQuery)) {
                countStmt.setInt(1, postId);
                try (ResultSet cRs = countStmt.executeQuery()) {
                    if (cRs.next()) {
                        commentCount = cRs.getInt("cnt");
                    }
                }
            }

            // 사용자가 이 게시물에 대해 이미 투표했는지 확인
            boolean hasVoted = false;
            if (userIdSession != null) {
                String hasVotedQuery = "SELECT COUNT(*) AS vote_count FROM votes WHERE user_id = ? AND post_id = ?";
                hasVotedStmt = conn.prepareStatement(hasVotedQuery);
                hasVotedStmt.setString(1, userIdSession);
                hasVotedStmt.setInt(2, postId);
                try (ResultSet hasVotedRs = hasVotedStmt.executeQuery()) {
                    if (hasVotedRs.next()) {
                        hasVoted = hasVotedRs.getInt("vote_count") > 0;
                    }
                }
                hasVotedStmt.close();
            }

            // 작성자 닉네임 및 프로필 이미지 조회
            String authorNickname = "";
            String authorProfileImage = "circle.png"; // 기본 프로필 이미지
            if (userIdFromDB != null) {
                String authorQuery = "SELECT nickname, profile_image FROM users WHERE id = ?";
                authorStmt = conn.prepareStatement(authorQuery);
                authorStmt.setString(1, userIdFromDB);
                authorRs = authorStmt.executeQuery();
                if (authorRs.next()) {
                    authorNickname = authorRs.getString("nickname");
                    String dbAuthorProfileImage = authorRs.getString("profile_image");
                    if (dbAuthorProfileImage != null && !dbAuthorProfileImage.isEmpty()) {
                        authorProfileImage = dbAuthorProfileImage;
                    }
                }
                authorRs.close();
                authorStmt.close();
            }
%>

<!-- 게시글 -->
<div class="post" data-category="<%= categoryDB %>" data-post-id="<%= postId %>">
    <script>
        var postData_<%= postId %> = {
            postId: <%= postId %>,
            endDate: "<%= (endDate != null) ? endDate.toString() : "" %>",
            endTime: "<%= (endTime != null) ? endTime.toString() : "" %>",
            multiSelect: <%= multiSelect %>,
            isVotingOpen: <%= isVotingOpen %>,
            hasVoted: <%= hasVoted %> // 이 줄 추가
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
            <a href="profile.jsp?user_id=<%= userIdFromDB %>">
                <img src="<%= authorProfileImage %>" alt="프로필 이미지" class="profile-pic" />
                <span style="font-size:20px;"><%= authorNickname %></span>
            </a>
            <div>
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
        <button class="vote-button" type="button" data-post-id="<%= postId %>" <%= (isVotingOpen && !hasVoted) ? "" : "disabled" %>>투표하기</button>
    </div>
    <br />
    <a href="#" class="comment-button" data-post-id="<%= postId %>">
        <img src="Message square.png" alt="댓글 아이콘">
    </a>
    <hr class="comment-hr">

    <div class="comments-section hidden" id="comments-section-<%= postId %>">
        <h3 class="comment-count">댓글 <%= commentCount %></h3>
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

                // 댓글 작성자의 닉네임과 프로필 이미지 조회
                String commentNickname = "";
                String commentProfileImage = "circle.png"; // 기본 프로필 이미지

                if (commentUserId != null && !commentUserId.isEmpty()) {
                    String userInfoQuery = "SELECT nickname, profile_image FROM users WHERE id = ?";
                    try (PreparedStatement userInfoStmt = conn.prepareStatement(userInfoQuery)) {
                        userInfoStmt.setString(1, commentUserId);
                        try (ResultSet userInfoRs = userInfoStmt.executeQuery()) {
                            if (userInfoRs.next()) {
                                commentNickname = userInfoRs.getString("nickname");
                                String dbCommentProfileImage = userInfoRs.getString("profile_image");
                                if (dbCommentProfileImage != null && !dbCommentProfileImage.isEmpty()) {
                                    commentProfileImage = dbCommentProfileImage;
                                }
                            }
                        }
                    }
                }
    %>
    <li>
        <div class="comment-header">
            <img src="<%= commentProfileImage %>" alt="프로필 이미지" class="profile-pic" />
            <span style="font-size:10px;"><%= (commentNickname != null && !commentNickname.isEmpty()) ? commentNickname : commentUserId %></span>
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
            <!-- 인라인 스타일 추가 예: 배경색 지정 -->
            <button type="button" class="add-comment-button" data-post-id="<%= postId %>" style="background-color: #87ab69;">댓글 추가</button>
        </form>
    </div>
</div>
<%
        } // end while
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (authorRs != null) try { authorRs.close(); } catch (SQLException ignore) {}
        if (authorStmt != null) try { authorStmt.close(); } catch (SQLException ignore) {}
        if (optionRs != null) try { optionRs.close(); } catch (SQLException ignore) {}
        if (optionStmt != null) try { optionStmt.close(); } catch (SQLException ignore) {}
        if (postRs != null) try { postRs.close(); } catch (SQLException ignore) {}
        if (postStmt != null) try { postStmt.close(); } catch (SQLException ignore) {}
        if (bookmarkCheckStmt != null) try { bookmarkCheckStmt.close(); } catch (SQLException ignore) {}
        if (hasVotedStmt != null) try { hasVotedStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>