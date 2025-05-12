<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.sql.Date"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>CM Bookmark</title>
<link rel="stylesheet" href="mypage.css" />
</head>
<body>
<%
    // 로그인한 사용자의 userId를 세션에서 가져온다고 가정
    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        // 로그인이 안되어있을 경우 로그인 페이지로 리다이렉트
        response.sendRedirect("login.jsp");
        return;
    }
    // DB 연결 정보
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement postStmt = null;
    PreparedStatement optionStmt = null;
    PreparedStatement authorStmt = null;
    ResultSet postRs = null;
    ResultSet optionRs = null;
    ResultSet authorRs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 북마크한 게시글 조회 (bookmarks 테이블 JOIN)
        String postQuery = "SELECT p.* FROM posts p "
                         + "JOIN bookmarks b ON p.post_id = b.post_id "
                         + "WHERE b.user_id = ? "
                         + "ORDER BY p.reg_date DESC";
        postStmt = conn.prepareStatement(postQuery);
        postStmt.setString(1, userId);
        postRs = postStmt.executeQuery();
%>

<header>
    <a href="main.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
    <div class="up">
      <a href="main.jsp">게시판</a>
      <a href="mypage.jsp">마이페이지</a>
      <a href="logout.jsp">로그아웃</a>
    </div>
    <hr class="custom-hr" />
</header>

<aside class="side">
    <ul>
      <li id="one"><b>카테고리</b></li>
      <li><a href="#" data-category="전체 게시글">전체 게시글</a></li>
      <li><a href="#" data-category="전자제품">전자제품</a></li>
      <li><a href="#" data-category="패션/의류">패션/의류</a></li>
      <li><a href="#" data-category="뷰티/건강">뷰티/건강</a></li>
      <li><a href="#" data-category="식품/음료">식품/음료</a></li>
      <li><a href="#" data-category="생활용품">생활용품</a></li>
      <li><a href="#" data-category="취미/여가">취미/여가</a></li>
      <li><a href="#" data-category="자동차/오토바이">자동차/오토바이</a></li>
      <li><a href="#" data-category="기타">기타</a></li>
    </ul>
</aside>

<div class="content">
    <h2>북마크한 게시글</h2>
    <div class="box" id="bookmark-container">

<%
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

        // 현재 서버 시간
        Timestamp currentTime = new Timestamp(System.currentTimeMillis());

        // 투표 종료 시간 설정
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
        String optionQuery = "SELECT po.option_id, po.option_text, po.image_url, COUNT(v.option_id) AS cnt "
                           + "FROM poll_options po "
                           + "LEFT JOIN votes v ON po.option_id = v.option_id "
                           + "WHERE po.post_id = ? "
                           + "GROUP BY po.option_id, po.option_text, po.image_url";
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

        // 작성자 닉네임 및 프로필 이미지 조회
        String authorNickname = "Unknown";
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

<!-- 게시글 출력 -->
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
        <!-- 북마크 체크박스는 기본적으로 체크되어 있고, bookmark_filled.png 아이콘 표시 -->
        <input type="checkbox" id="bookmark-<%= postId %>" class="bookmark-checkbox" checked />
        <label for="bookmark-<%= postId %>">
            <img src="bookmark_filled.png" alt="북마크" class="bookmark-icon">
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
                 alt="항목 이미지" class="poll-option-image" style="cursor: pointer;" />
        </label>
        <% } %>
        <button class="vote-button" type="button" data-post-id="<%= postId %>" <%= isVotingOpen ? "" : "disabled" %>>투표하기</button>
    </div><br>
    <a href="#" class="comment-button" onclick="document.getElementById('comments-section-<%= postId %>').classList.toggle('hidden'); return false;">
        <img src="Message square.png" alt="댓글 아이콘">
    </a>

    <hr class="comment-hr">

    <!-- 댓글 섹션 -->
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

                        // Fetch comment author's nickname and profile image
                        String commentAuthorNickname = "Unknown";
                        String commentAuthorProfileImage = "circle.png"; // 기본 프로필 이미지
                        if (commentUserId != null) {
                            String commentAuthorQuery = "SELECT nickname, profile_image FROM users WHERE id = ?";
                            PreparedStatement commentAuthorStmt = conn.prepareStatement(commentAuthorQuery);
                            commentAuthorStmt.setString(1, commentUserId);
                            ResultSet commentAuthorRs = commentAuthorStmt.executeQuery();
                            if (commentAuthorRs.next()) {
                                commentAuthorNickname = commentAuthorRs.getString("nickname");
                                String dbCommentAuthorProfileImage = commentAuthorRs.getString("profile_image");
                                if (dbCommentAuthorProfileImage != null && !dbCommentAuthorProfileImage.isEmpty()) {
                                    commentAuthorProfileImage = dbCommentAuthorProfileImage;
                                }
                            }
                            commentAuthorRs.close();
                            commentAuthorStmt.close();
                        }
            %>
            <li>
                <div class="comment-header">
                    <a href="profile.jsp?user_id=<%= commentUserId %>">
                        <img src="<%= commentAuthorProfileImage %>" alt="프로필 이미지" class="profile-pic" />
                        <span style="font-size:10px;"><%= commentAuthorNickname %></span>
                    </a>
                </div>
                <p id="comment-text-<%= commentId %>"><%= commentText %></p>
                <% if (commentUserId.equals(userId)) { %>
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
    } // while문 끝

    postRs.close();
    postStmt.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (authorRs != null) try { authorRs.close(); } catch (SQLException ignore) {}
    if (authorStmt != null) try { authorStmt.close(); } catch (SQLException ignore) {}
    if (optionRs != null) try { optionRs.close(); } catch (SQLException ignore) {}
    if (optionStmt != null) try { optionStmt.close(); } catch (SQLException ignore) {}
    if (postRs != null) try { postRs.close(); } catch (SQLException ignore) {}
    if (postStmt != null) try { postStmt.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>
    </div>
</div>
<script src="main.js"></script>
</body>
</html>
