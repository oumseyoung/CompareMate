<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.sql.Date"%>
<!DOCTYPE html>
<html>

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CM mypage</title>
  <link rel="stylesheet" href="mypage.css" />
</head>
<style>
   
#comment-section {
  margin-top: 30px;
  padding: 20px;
  background-color: #ddead1; /* 연한 녹색 */
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  font-family: Arial, sans-serif;
}

.comment-count {
  font-size: 18px;
  margin-bottom: 15px;
}

#comment-list li {
  display: flex;
  flex-direction: column; /* 세로 정렬 */
  align-items: flex-start; /* 왼쪽 정렬 */
  margin-bottom: 15px;
  padding: 10px;
  background-color: #e8f5e9; /* 연한 녹색 */
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

#comment-list li .comment-header {
  display: flex;
  align-items: center; /* 이미지와 이름 가로 정렬 */
  margin-bottom: 5px; /* 내용과의 간격 */
}

#comment-list li b {
  font-size: 16px;
}

#comment-list li p {
  margin: 0;
  font-size: 14px;
  color: #333;
  margin-left: 50px; /* 내용이 이름 밑으로 정렬되도록 여백 추가 */
}

#comment-input {
  width: calc(100% - 20px);
  padding: 10px;
  margin-top: 15px;
  border: 1px solid #ccc;
  border-radius: 10px;
  font-size: 14px;
  background-color: #f9f9f9;
}

.add-comment-button {
  margin-top: 5px;
  padding: 10px 20px;
  background-color: #658354;
  color: white;
  border: 1px solid #658354;
  border-radius: 10px;
  cursor: pointer;
  display: block;
  margin-bottom: 15px;
}

.add-comment-button:hover {
  background-color: #87ab69;
}

/* 기존 스타일들... */

/* 댓글 섹션 스타일 */
.comments-section {
    display: block; /* 기본 상태 */
    margin-top: 20px;
    background-color: #f9f9f9;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.comments-section.hidden {
    display: none; /* hidden 클래스가 있으면 숨김 */
}

.comment-header {
    display: flex; /* 가로 정렬 */
    align-items: center; /* 세로 중앙 정렬 */
    gap: 10px; /* 요소 간격 */
}

.comment-user-id {
    font-weight: bold; /* 사용자 ID 강조 */
    color: #333; /* 글자 색 */
    margin-right: 10px; /* 날짜와의 간격 */
}

.comment-date {
    color: gray;
    font-size: 12px; /* 날짜 글자 크기 */
}

.comment-header .profile-pic {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    margin-right: 10px;
}

.comment-count {
    margin-bottom: 10px;
    font-weight: bold;
    font-size: 16px;
}

[id^="comment-input-"] {
    width: 90%;
    padding: 10px;
    margin-top: 10px;
    border: 1px solid #ddd;
    border-radius: 5px;
}

.add-comment-button {
  margin-top: 5px;
  padding: 10px 20px;
  background-color: #658354;
  color: white;
  border: 1px solid #658354;
  border-radius: 10px;
  cursor: pointer;
  display: block;
  margin-bottom: 15px;
}

.add-comment-button:hover {
  background-color: #87ab69;
}

#alert-list li {
    display: flex;
    align-items: center;
    padding: 10px;
    border-bottom: 1px solid #ddd;
}

#alert-list li img {
    width: 30px;
    height: 30px;
    margin-right: 10px;
    border-radius: 50%;
}

#alert-list li span {
    font-size: 14px;
}


/* 댓글 버튼 스타일 */
.comment-button img {
    width: 20px;
    height: 24px;
    cursor: pointer;
}
.comment-actions {
    margin-top: 5px;
    font-size: 12px;
    color: gray;
}

.comment-actions a {
    text-decoration: none; /* 밑줄 제거 */
    color:  #87ab69; /* 링크 색상 */
    cursor: pointer; /* 마우스 포인터 변경 */
    margin-right: 10px;
}

.comment-actions a:hover {
    text-decoration: underline; /* 호버 시 밑줄 표시 */
    color: rgb(0, 179, 0);
}

.comment-hr {
  height: 1px; /* 선의 두께 설정 */
  border: none; /* 기본 테두리 제거 */
  background-color: #B3B3B3; /* 선의 색상 설정 */
}
</style>

<body>
<%
    // 로그인한 사용자의 ID 가져오기
    String nickname = (String) session.getAttribute("nickname");
    String profileImage = (String) session.getAttribute("profileImage");
    if (nickname == null) nickname = "닉네임 설정 필요";
    if (profileImage == null) profileImage = "circle.png";
    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        // 로그인 안되어있으면 로그인 페이지로 리다이렉트
        response.sendRedirect("login.jsp");
        return;
    }

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement userStmt = null;
    PreparedStatement postCountStmt = null;
    PreparedStatement answeredCountStmt = null;
    ResultSet userRs = null;
    
    String interests = "";
    int postCount = 0;
    int answeredCount = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 유저 정보 조회
        String userQuery = "SELECT nickname, profile_image, interests FROM users WHERE id = ?";
        userStmt = conn.prepareStatement(userQuery);
        userStmt.setString(1, userId);
        userRs = userStmt.executeQuery();
        if (userRs.next()) {
            nickname = userRs.getString("nickname");
            String dbProfileImage = userRs.getString("profile_image");
            if (dbProfileImage != null && !dbProfileImage.isEmpty()) {
                profileImage = dbProfileImage;
            }
            String dbInterests = userRs.getString("interests");
            if (dbInterests != null) {
                interests = dbInterests;
            }
        }
        userRs.close();
        userStmt.close();

        // 내가 쓴 게시글 수
        String postCountQuery = "SELECT COUNT(*) AS cnt FROM posts WHERE user_id = ?";
        postCountStmt = conn.prepareStatement(postCountQuery);
        postCountStmt.setString(1, userId);
        try (ResultSet pcRs = postCountStmt.executeQuery()) {
            if (pcRs.next()) {
                postCount = pcRs.getInt("cnt");
            }
        }
        postCountStmt.close();

        // 답변한 게시글 수(내가 댓글 단 게시글 수)
        String answeredCountQuery = "SELECT COUNT(DISTINCT post_id) AS cnt FROM comments WHERE user_id = ?";
        answeredCountStmt = conn.prepareStatement(answeredCountQuery);
        answeredCountStmt.setString(1, userId);
        try (ResultSet acRs = answeredCountStmt.executeQuery()) {
            if (acRs.next()) {
                answeredCount = acRs.getInt("cnt");
            }
        }
        answeredCountStmt.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (userRs != null) try { userRs.close(); } catch (SQLException ignore) {}
        if (userStmt != null) try { userStmt.close(); } catch (SQLException ignore) {}
        if (postCountStmt != null) try { postCountStmt.close(); } catch (SQLException ignore) {}
        if (answeredCountStmt != null) try { answeredCountStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
    
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
        <jsp:include page="alert_load.jsp" />
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
    <h1>프로필</h1>
    <div class="box" id="post-container">
      <div class="profile-header">
        <img src="<%= profileImage %>" class="profile-image" id="profile-image" />
        <div class="camera hidden" id="camera">
          <img src="camera.png" alt="수정" id="camera-icon" />
          <input type="file" id="file-input" class="hidden" accept=".png, .jpg, .jpeg" />
        </div>
        <div class="profile-details">
          <p>
            <b id="nickname"><%= nickname %></b>
            <input type="text" id="nickname-input" class="hidden" value="<%= nickname %>" />
            <img src="<%= badgeImage %>" alt="등급 배지" style="width: 30px; margin-left: 15px" />
            <span><img src="edit.png" alt="수정" id="edit-profile" style="width: 25px; margin-left: 15px" /></span>
          </p>
          <p>
            <b>관심분야</b>
            <span id="interest-list" style="font-weight:600; color:rgba(0,0,0,0.47); margin-left:15px;">
              <%= interests %>
            </span>
          </p>
          <div id="interest-edit" class="hidden">
            <form id="interest-form">
              <label><input type="checkbox" value="전자제품" />전자제품</label>
              <label><input type="checkbox" value="패션/의류" />패션/의류</label>
              <label><input type="checkbox" value="뷰티/건강" />뷰티/건강</label>
              <label><input type="checkbox" value="식품/음료" />식품/음료</label>
              <label><input type="checkbox" value="생활용품" />생활용품</label>
              <label><input type="checkbox" value="취미/여가" />취미/여가</label>
              <label><input type="checkbox" value="자동차/오토바이" />자동차/오토바이</label>
              <label><input type="checkbox" value="기타" />기타</label>
            </form>
            <button type="button" id="save-profile">확인</button>
          </div>
          <div class="line">
            <b>내가 쓴 게시글 수:</b> <%= postCount %> &nbsp;&nbsp;&nbsp;&nbsp;
            <b>답변한 게시글 수:</b> <%= answeredCount %> &nbsp;&nbsp;&nbsp;&nbsp;
            <button id="bookmark" type="button" onclick="location.href='bookmarkpage.jsp'">
              <img src="bookmark.png" alt="북마크" />북마크
            </button>
          </div>
        </div>
      </div>
      <hr class="profile-hr" />
      <h3><%= nickname %>님이 쓴 게시글</h3>
<%
    // 여기서 사용자가 쓴 게시글 목록 가져오기
    Connection conn2 = null;
    PreparedStatement postsStmt = null;
    PreparedStatement optionStmt = null;
    PreparedStatement bookmarkCheckStmt = null;
    PreparedStatement hasVotedStmt = null; // hasVoted 확인용
    PreparedStatement userInfoStmt = null; // 댓글 작성자 정보 조회용
    ResultSet postsRs = null;
    ResultSet optionRs = null;
    ResultSet userInfoRs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        String userPostsQuery = "SELECT * FROM posts WHERE user_id = ? ORDER BY reg_date DESC";
        postsStmt = conn2.prepareStatement(userPostsQuery);
        postsStmt.setString(1, userId);
        postsRs = postsStmt.executeQuery();

        while (postsRs.next()) {
            int postId = postsRs.getInt("post_id");
            String userIdFromDB = postsRs.getString("user_id");
            String title = postsRs.getString("title");
            String content = postsRs.getString("content");
            String category = postsRs.getString("category");
            boolean multiSelect = postsRs.getBoolean("multi_select");
            Timestamp regDate = postsRs.getTimestamp("reg_date");
            Date endDate = postsRs.getDate("end_date");
            Time endTime = postsRs.getTime("end_time");

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
            if (userId != null) {
                String bookmarkCheckQuery = "SELECT * FROM bookmarks WHERE user_id = ? AND post_id = ?";
                bookmarkCheckStmt = conn2.prepareStatement(bookmarkCheckQuery);
                bookmarkCheckStmt.setString(1, userId);
                bookmarkCheckStmt.setInt(2, postId);
                try (ResultSet bRs = bookmarkCheckStmt.executeQuery()) {
                    isBookmarked = bRs.next();
                }
                bookmarkCheckStmt.close();
            }

            // 사용자가 이 게시물에 대해 이미 투표했는지 확인
            boolean hasVoted = false;
            if (userId != null) {
                String hasVotedQuery = "SELECT COUNT(*) AS vote_count FROM votes WHERE user_id = ? AND post_id = ?";
                hasVotedStmt = conn2.prepareStatement(hasVotedQuery);
                hasVotedStmt.setString(1, userId);
                hasVotedStmt.setInt(2, postId);
                try (ResultSet hasVotedRs = hasVotedStmt.executeQuery()) {
                    if (hasVotedRs.next()) {
                        hasVoted = hasVotedRs.getInt("vote_count") > 0;
                    }
                }
                hasVotedStmt.close();
            }
%>
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
        <div class="menu-bookmark">
          <img src="menu.png" alt="메뉴" class="menu-icon" />
          <div class="menu-popup hidden">
            <button class="delete-post-btn">삭제</button>
          </div>
          <div class="bookmark">
            <input type="checkbox" id="bookmark-<%= postId %>" class="bookmark-checkbox" <%= isBookmarked ? "checked" : "" %> />
            <label for="bookmark-<%= postId %>">
              <img src="<%= isBookmarked ? "bookmark_filled.png" : "bookmark.png" %>" alt="북마크" class="bookmark-icon" />
            </label>
          </div>
        </div>
        <!-- 게시물 링크 제거: 기존 <a> 태그를 제거하고 내용을 div로 변경 -->
        <div class="post-link">
          <h3 class="post-title"><%= title %><% if(!isVotingOpen){ %> <span class="voting-closed-text">(종료된 투표)</span><% } %></h3>
          <div class="post-header">
            <a href="profile.jsp?user_id=<%= userIdFromDB %>">
              <img src="<%= profileImage %>" alt="프로필 이미지" class="profile-pic" />
              <span style="font-size:20px;"><%= nickname %></span>
            </a>
            <div>
              <span class="date"><%= regDate.toString() %></span>
            </div>
          </div>
          <p><%= content %></p>
        </div>
        <div class="poll" data-post-id="<%= postId %>" data-multiple-choice="<%= multiSelect %>">
          <div class="poll-header">
            <img src="vote.png" alt="투표 아이콘" />
            <span>투표</span><span id="multi-select" data-post-id="<%= postId %>"><%= multiSelect ? "복수선택 가능" : "복수선택 불가능" %></span>
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
        <a href="#" class="comment-button" onclick="toggleComments(<%= postId %>)">
          <img src="Message square.png" alt="댓글 이미지" />
        </a>

        <!-- Comments Section Similar to profile.jsp -->
        <hr class="comment-hr">
        <div class="comments-section hidden" id="comments-section-<%= postId %>">
          <h3 class="comment-count">댓글</h3>
          <ul id="comment-list-<%= postId %>">
            <%
                // 댓글 조회 쿼리 수정: users 테이블과 JOIN하지 않고 별도로 작성자 정보 조회
                String commentQuery = "SELECT * FROM comments WHERE post_id = ? ORDER BY comment_date ASC";
                try (PreparedStatement commentStmt = conn2.prepareStatement(commentQuery)) {
                    commentStmt.setInt(1, postId);
                    try (ResultSet commentRs = commentStmt.executeQuery()) {
                        while (commentRs.next()) {
                            String commentUserId = commentRs.getString("user_id");
                            String commentText = commentRs.getString("comment_text");
                            Timestamp commentDate = commentRs.getTimestamp("comment_date");
                            int commentId = commentRs.getInt("comment_id");

                            // 별도의 쿼리를 통해 댓글 작성자의 닉네임과 프로필 이미지 조회
                            String userInfoQuery = "SELECT nickname, profile_image FROM users WHERE id = ?";
                            userInfoStmt = conn2.prepareStatement(userInfoQuery);
                            userInfoStmt.setString(1, commentUserId);
                            userInfoRs = userInfoStmt.executeQuery();

                            String commentNickname = "";
                            String commentProfileImage = "circle.png"; // 기본 프로필 이미지

                            if (userInfoRs.next()) {
                                commentNickname = userInfoRs.getString("nickname");
                                String dbCommentProfileImage = userInfoRs.getString("profile_image");
                                if (dbCommentProfileImage != null && !dbCommentProfileImage.isEmpty()) {
                                    commentProfileImage = dbCommentProfileImage;
                                }
                            }

                            userInfoRs.close();
                            userInfoStmt.close();
            %>
            <li>
              <div class="comment-header">
                <img src="<%= (commentProfileImage != null && !commentProfileImage.isEmpty()) ? commentProfileImage : "circle.png" %>" alt="프로필 이미지" class="profile-pic">
                <span class="comment-user-id"><%= (commentNickname != null && !commentNickname.isEmpty()) ? commentNickname : commentUserId %></span>
                <span class="comment-date"><%= commentDate.toString() %></span>
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
        } // end while
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (userInfoRs != null) try { userInfoRs.close(); } catch (SQLException ignore) {}
        if (userInfoStmt != null) try { userInfoStmt.close(); } catch (SQLException ignore) {}
        if (optionRs != null) try { optionRs.close(); } catch (SQLException ignore) {}
        if (optionStmt != null) try { optionStmt.close(); } catch (SQLException ignore) {}
        if (postsRs != null) try { postsRs.close(); } catch (SQLException ignore) {}
        if (postsStmt != null) try { postsStmt.close(); } catch (SQLException ignore) {}
        if (bookmarkCheckStmt != null) try { bookmarkCheckStmt.close(); } catch (SQLException ignore) {}
        if (hasVotedStmt != null) try { hasVotedStmt.close(); } catch (SQLException ignore) {}
        if (conn2 != null) try { conn2.close(); } catch (SQLException ignore) {}
    }
%>
    </div>
  </div>
  <script src="mypage.js"></script>
  <script>
    // 댓글 섹션 토글 함수
    function toggleComments(postId) {
      var commentsSection = document.getElementById('comments-section-' + postId);
      if (commentsSection.classList.contains('hidden')) {
        commentsSection.classList.remove('hidden');
      } else {
        commentsSection.classList.add('hidden');
      }
    }
  </script>
</body>

</html>
