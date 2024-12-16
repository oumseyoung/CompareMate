<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@page import="java.sql.Date"%>
<!DOCTYPE html>
<html>

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CM mypage</title>
  <link rel="stylesheet" href="mypage.css" />
</head>

<body>
<%
    // 로그인한 사용자의 ID 가져오기
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

    String nickname = "본인 닉네임(마이페이지니까)";
    String profileImage = "circle.png";
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
        <div class="camera hidden" id="camera">
          <img src="camera.png" alt="수정" id="camera-icon" />
          <input type="file" id="file-input" class="hidden" accept=".png, .jpg, .jpeg" />
        </div>
        <div class="profile-details">
          <p>
            <b id="nickname"><%= nickname %></b>
            <input type="text" id="nickname-input" class="hidden" value="<%= nickname %>" />
            <span><img src="germinal.png" alt="새싹" style="width: 30px; margin-left: 15px" /></span>
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
    ResultSet postsRs = null;
    ResultSet optionRs = null;

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
        <a href="post.jsp?post_id=<%= postId %>" class="post-link">
          <h3 class="post-title"><%= title %><% if(!isVotingOpen){ %> <span class="voting-closed-text">(종료된 투표)</span><% } %></h3>
          <div class="post-header">
            <a href="profile.jsp?user_id=<%= userIdFromDB %>">
              <img src="circle.png" alt="프로필" class="profile-pic" />
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
          <button class="vote-button" type="button" data-post-id="<%= postId %>" <%= isVotingOpen ? "" : "disabled" %>>투표하기</button>
        </div>
        <br />
        <a href="post.jsp?post_id=<%= postId %>#comment-section" class="comment-button">
          <img src="Message square.png" alt="댓글 이미지" />
        </a>
      </div>
<%
        } // end while
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (optionRs != null) try { optionRs.close(); } catch (SQLException ignore){}
        if (optionStmt != null) try { optionStmt.close(); } catch (SQLException ignore){}
        if (postsRs != null) try { postsRs.close(); } catch (SQLException ignore){}
        if (postsStmt != null) try { postsStmt.close(); } catch (SQLException ignore){}
        if (bookmarkCheckStmt != null) try { bookmarkCheckStmt.close(); } catch (SQLException ignore){}
        if (conn2 != null) try { conn2.close(); } catch (SQLException ignore){}
    }
%>
    </div>
  </div>
  <script src="mypage.js"></script>
</body>

</html>
