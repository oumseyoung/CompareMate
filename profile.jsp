<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@page import="java.sql.Date"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>프로필</title>
    <link rel="stylesheet" href="profile.css" />
</head>
<body>
<%
    String userIdSession = (String)session.getAttribute("userId");
    if (userIdSession == null) {
        userIdSession = ""; // 비로그인 상태일 경우 빈 문자열
    }

    String targetUserId = request.getParameter("user_id");
    if (targetUserId == null || targetUserId.trim().isEmpty()) {
        // user_id 파라미터가 없거나 빈값인 경우 메인 페이지로 리다이렉트
        response.sendRedirect("main.jsp");
        return;
    }

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement userStmt = null;
    PreparedStatement postCountStmt = null;
    PreparedStatement answeredCountStmt = null;
    ResultSet userRs = null;
    ResultSet postCountRs = null;
    ResultSet answeredCountRs = null;

    String nickname = "알 수 없는 사용자";
    String profileImage = "circle.png"; 
    int postCount = 0;     
    int answeredCount = 0; 

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 유저 닉네임
        String userQuery = "SELECT nickname FROM users WHERE id = ?";
        userStmt = conn.prepareStatement(userQuery);
        userStmt.setString(1, targetUserId);
        userRs = userStmt.executeQuery();
        if (userRs.next()) {
            nickname = userRs.getString("nickname");
        }

        // 게시글 수
        String postCountQuery = "SELECT COUNT(*) AS post_count FROM posts WHERE user_id = ?";
        postCountStmt = conn.prepareStatement(postCountQuery);
        postCountStmt.setString(1, targetUserId);
        postCountRs = postCountStmt.executeQuery();
        if (postCountRs.next()) {
            postCount = postCountRs.getInt("post_count");
        }

        // 답변한 게시글 수
        String answeredCountQuery = "SELECT COUNT(DISTINCT post_id) AS answered_count FROM comments WHERE user_id = ?";
        answeredCountStmt = conn.prepareStatement(answeredCountQuery);
        answeredCountStmt.setString(1, targetUserId);
        answeredCountRs = answeredCountStmt.executeQuery();
        if (answeredCountRs.next()) {
            answeredCount = answeredCountRs.getInt("answered_count");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (answeredCountRs != null) try { answeredCountRs.close(); } catch (SQLException ignore) {}
        if (answeredCountStmt != null) try { answeredCountStmt.close(); } catch (SQLException ignore) {}
        if (postCountRs != null) try { postCountRs.close(); } catch (SQLException ignore) {}
        if (postCountStmt != null) try { postCountStmt.close(); } catch (SQLException ignore) {}
        if (userRs != null) try { userRs.close(); } catch (SQLException ignore) {}
        if (userStmt != null) try { userStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    // 이미지 변경 로직
    String badgeImage = "germinal.png";
    if (postCount >= 30 && answeredCount >= 100) {
        badgeImage = "gold.png";
    } else if (postCount >= 10 && answeredCount >= 50) {
        badgeImage = "silver.png";
    } else if (postCount >= 1 && answeredCount >= 5) {
        badgeImage = "bronze.png";
    }
%>

<header>
    <a href="main.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
    <div class="up">
      <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()" />
      <div id="layer" class="hidden">
        <img src="trash.png" alt="휴지통" id="trash" onclick="clearAlerts()" />
        <ul id="alert-list">
          <a href="#">
            <li class="alert-item">
              <img src="circle.png" alt="프로필" /><span>투표 내용 또는 댓글 내용<br />게시글 제목</span>
            </li>
          </a>
        </ul>
      </div>
      <a href="main.jsp">게시판</a>
      <a href="mypage.jsp">마이페이지</a>
      <a href="logout.jsp">로그아웃</a>
    </div>
    <hr class="custom-hr" />
</header>
<aside class="side">
    <ul>
      <li id="one"><b>카테고리</b></li>
      <li><a href="#" data-category="all">전체 게시글</a></li>
      <li><a href="#" data-category="electronics">전자제품</a></li>
      <li><a href="#" data-category="fashion">패션/의류</a></li>
      <li><a href="#" data-category="beauty">뷰티/건강</a></li>
      <li><a href="#" data-category="food">식품/음료</a></li>
      <li><a href="#" data-category="household">생활용품</a></li>
      <li><a href="#" data-category="hobby">취미/여가</a></li>
      <li><a href="#" data-category="automotive">자동차/오토바이</a></li>
      <li><a href="#" data-category="others">기타</a></li>
    </ul>
</aside>
<div class="content">
    <h2>프로필</h2>
    <div class="box" id="post-container">
        <div class="profile-header">
            <img src="<%= profileImage %>" class="profile-image" id="profile-image" />
            <div class="profile-details">
                <p>
                    <b id="nickname"><%= nickname %></b>
                    <span>
                        <!-- 조건에 따라 변경된 badgeImage 표시 -->
                        <img src="<%= badgeImage %>" alt="등급 배지" style="width: 30px; margin-left: 15px" />
                    </span>
                </p>
                <!-- 관심분야 부분 고정 -->
                <p>
                    <b>관심분야</b>
                    <span id="interest-list" style="font-weight: 600; color: rgba(0, 0, 0, 0.47); margin-left: 15px;">전자제품</span>
                </p>
                <div class="line">
                    <b>게시글 수:</b> <%= postCount %> &nbsp;&nbsp;&nbsp;&nbsp;
                    <b>답변한 게시글 수:</b> <%= answeredCount %> &nbsp;&nbsp;&nbsp;&nbsp;
                </div>
            </div>
        </div>
        <hr class="profile-hr" />
        <h3><%= nickname %>님이 쓴 게시글</h3>
        <%
            Connection conn2 = null;
            PreparedStatement userPostsStmt = null;
            PreparedStatement optionStmt = null;
            PreparedStatement bookmarkCheckStmt = null;
            ResultSet userPostsRs = null;
            ResultSet optionRs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn2 = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

                String userPostsQuery = "SELECT * FROM posts WHERE user_id = ? ORDER BY reg_date DESC";
                userPostsStmt = conn2.prepareStatement(userPostsQuery);
                userPostsStmt.setString(1, targetUserId);
                userPostsRs = userPostsStmt.executeQuery();

                while (userPostsRs.next()) {
                    int postId = userPostsRs.getInt("post_id");
                    String userIdFromDB = userPostsRs.getString("user_id");
                    String title = userPostsRs.getString("title");
                    String content = userPostsRs.getString("content");
                    String category = userPostsRs.getString("category");
                    boolean multiSelect = userPostsRs.getBoolean("multi_select");
                    Timestamp regDate = userPostsRs.getTimestamp("reg_date");
                    Date endDate = userPostsRs.getDate("end_date");
                    Time endTime = userPostsRs.getTime("end_time");

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
                    optionStmt = conn2.prepareStatement(optionQuery);
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
                    if (!userIdSession.isEmpty()) {
                        String bookmarkCheckQuery = "SELECT * FROM bookmarks WHERE user_id = ? AND post_id = ?";
                        bookmarkCheckStmt = conn2.prepareStatement(bookmarkCheckQuery);
                        bookmarkCheckStmt.setString(1, userIdSession);
                        bookmarkCheckStmt.setInt(2, postId);
                        try (ResultSet bRs = bookmarkCheckStmt.executeQuery()) {
                            isBookmarked = bRs.next();
                        }
                        bookmarkCheckStmt.close();
                    }
        %>

        <!-- 게시글 표시 -->
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
            <a href="post.jsp?post_id=<%= postId %>" class="post-link">
                <h3 class="post-title">
                    <%= title %>
                    <% if (!isVotingOpen) { %>
                        <span class="voting-closed-text">(종료된 투표)</span>
                    <% } %>
                </h3>
                <div class="post-header">
                    <a href="profile.jsp?user_id=<%= userIdFromDB %>">
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
            <a href="post.jsp?post_id=<%= postId %>#comment-section" class="comment-button" data-post-id="<%= postId %>">
                <img src="Message square.png" alt="댓글 아이콘">
            </a>
            <hr class="comment-hr">

            <div class="comments-section hidden" id="comments-section-<%= postId %>">
                <h3 class="comment-count">댓글</h3>
                <ul id="comment-list-<%= postId %>">
                    <%
                    String commentQuery = "SELECT * FROM comments WHERE post_id = ? ORDER BY comment_date ASC";
                    try (PreparedStatement commentStmt = conn2.prepareStatement(commentQuery)) {
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
                            <img src="circle.png" alt="프로필" class="profile-pic">
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
                } // end while
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (optionRs != null) try { optionRs.close(); } catch (SQLException ignore) {}
                if (optionStmt != null) try { optionStmt.close(); } catch (SQLException ignore) {}
                if (userPostsRs != null) try { userPostsRs.close(); } catch (SQLException ignore) {}
                if (userPostsStmt != null) try { userPostsStmt.close(); } catch (SQLException ignore) {}
                if (bookmarkCheckStmt != null) try { bookmarkCheckStmt.close(); } catch (SQLException ignore) {}
                if (conn2 != null) try { conn2.close(); } catch (SQLException ignore) {}
            }
        %>
    </div>
</div>
<script src="main.js"></script>
</body>
</html>
