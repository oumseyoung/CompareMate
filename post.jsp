<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 상세보기</title>
    <link rel="stylesheet" href="main.css">
</head>

<body>
    <header>
        <a href="main.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
        <div class="up">
            <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()">
            <div id="layer" class="hidden">
                <img src="trash.png" alt="휴지통" id="trash" onclick="clearAlerts()">
                <ul id="alert-list"></ul>
            </div>

            <a href="main.jsp">게시판</a>
            <a href="mypage.jsp">마이페이지</a>
            <% 
                String userId = (String) session.getAttribute("userId");
                if (userId != null) { 
            %>
                <a href="logout.jsp">로그아웃</a>
            <% 
                } else { 
            %>
                <a href="login.jsp">로그인</a>
            <% 
                } 
            %>
        </div>
        <hr class="custom-hr">
    </header>

    <aside class="side">
        <ul>
            <li id="one"><b>카테고리</b></li>
            <li><a href="main.jsp?category=전체 게시글" data-category="전체 게시글">전체 게시글</a></li>
            <li><a href="main.jsp?category=전자제품" data-category="전자제품">전자제품</a></li>
            <li><a href="main.jsp?category=패션/의류" data-category="패션/의류">패션/의류</a></li>
            <li><a href="main.jsp?category=뷰티/건강" data-category="뷰티/건강">뷰티/건강</a></li>
            <li><a href="main.jsp?category=식품/음료" data-category="식품/음료">식품/음료</a></li>
            <li><a href="main.jsp?category=생활용품" data-category="생활용품">생활용품</a></li>
            <li><a href="main.jsp?category=취미/여가" data-category="취미/여가">취미/여가</a></li>
            <li><a href="main.jsp?category=자동차/오토바이" data-category="자동차/오토바이">자동차/오토바이</a></li>
            <li><a href="main.jsp?category=기타" data-category="기타">기타</a></li>
        </ul>
    </aside>

    <div class="content">
        <%
            // 데이터베이스 연결 정보
            String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul";
            String DB_USERNAME = "root";
            String DB_PASSWORD = "0000";

            Connection conn = null;
            PreparedStatement postStmt = null;
            PreparedStatement optionStmt = null;
            PreparedStatement commentStmt = null;
            ResultSet postRs = null;
            ResultSet optionRs = null;
            ResultSet commentRs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

                // post_id 파라미터 가져오기
                String postIdParam = request.getParameter("post_id");
                if (postIdParam == null || postIdParam.isEmpty()) {
                    out.println("<p>유효하지 않은 게시글입니다.</p>");
                    return;
                }

                int postId = Integer.parseInt(postIdParam);

                // 게시글 정보 가져오기
                String postQuery = "SELECT * FROM posts WHERE post_id = ?";
                postStmt = conn.prepareStatement(postQuery);
                postStmt.setInt(1, postId);
                postRs = postStmt.executeQuery();

                if (!postRs.next()) {
                    out.println("<p>게시글을 찾을 수 없습니다.</p>");
                    return;
                }

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

                // 옵션 데이터 가져오기
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

                // 댓글 데이터 가져오기
                String commentQuery = "SELECT c.comment_id, c.user_id, c.comment_text, c.comment_date " +
                                      "FROM comments c " +
                                      "WHERE c.post_id = ? " +
                                      "ORDER BY c.comment_date ASC";
                commentStmt = conn.prepareStatement(commentQuery);
                commentStmt.setInt(1, postId);
                commentRs = commentStmt.executeQuery();

                List<Map<String, String>> comments = new ArrayList<>();
                while (commentRs.next()) {
                    Map<String, String> comment = new HashMap<>();
                    comment.put("commentId", String.valueOf(commentRs.getInt("comment_id")));
                    comment.put("userId", commentRs.getString("user_id"));
                    comment.put("commentText", commentRs.getString("comment_text"));
                    comment.put("commentDate", commentRs.getTimestamp("comment_date").toString());
                    comments.add(comment);
                }

                commentRs.close();
                commentStmt.close();

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
            <a href="#comment-section" class="comment-button">
                <img src="Message square.png" alt="댓글 이미지" />
            </a>
            <hr class="comment-hr">

            <h3 class="comment-count">댓글 <%= comments.size() %></h3>
            <ul id="comment-list">
                <% for (Map<String, String> comment : comments) { %>
                    <li>
                        <div class="comment-header">
                            <img src="circle.png" alt="프로필" class="profile-pic">
                            <%= comment.get("userId") %>
                        </div>
                        <p><%= comment.get("commentText") %></p>
                    </li>
                <% } %>
            </ul>
            <textarea id="comment-input" placeholder="댓글을 입력하세요"></textarea>
            <button id="add-comment-button" data-post-id="<%= postId %>">댓글 추가</button>
        </div>
    </div>

    <script>
        // 게시글의 post_id를 JavaScript 변수로 전달
        var currentPostId = <%=postId %>;
    </script>
    <script src="main.js"></script>
</body>

</html>
