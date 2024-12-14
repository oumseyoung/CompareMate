<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=UTC";
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

            String optionQuery = "SELECT * FROM poll_options WHERE post_id = ?";
            optionStmt = conn.prepareStatement(optionQuery);
            optionStmt.setInt(1, postId);
            optionRs = optionStmt.executeQuery();
%>
<!-- 게시글 -->
<div class="post" data-category="<%= category %>" data-post-id="<%= postId %>">
    <script>
        var postData_<%=postId%> = {
            postId: <%= postId %>,
            endDate: "<%= (endDate != null) ? endDate.toString() : "" %>",
            endTime: "<%= (endTime != null) ? endTime.toString() : "" %>",
            multiSelect: <%= multiSelect %>
        };
    </script>
    <a href="post.jsp?post_id=<%= postId %>" class="post-link">
        <div class="bookmark">
            <input type="checkbox" id="bookmark-<%= postId %>" class="bookmark-checkbox" />
            <label for="bookmark-<%= postId %>">
                <img src="bookmark.png" alt="북마크" class="bookmark-icon" />
            </label>
        </div>
        <h3 class="post-title"><%= title %></h3>
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
            <span>투표</span>
            <span><%= multiSelect ? "복수선택 가능" : "복수선택 불가능" %></span>
            <span>투표 취소/변경 가능</span>
        </div>
        <div class="image-popup hidden" id="image-popup-<%= postId %>">
            <div class="popup-content">
                <img class="popup-image" src="" alt="팝업 이미지" />
                <button class="close-popup" type="button">닫기</button>
            </div>
        </div>
        <%
            while (optionRs.next()) {
                int optionId = optionRs.getInt("option_id");
                String optionText = optionRs.getString("option_text");
                String imageUrl = optionRs.getString("image_url");
        %>
        <label class="poll-option">
            <%
                String inputType = multiSelect ? "checkbox" : "radio";
            %>
            <input
                type="<%= inputType %>"
                id="option<%= optionId %>-<%= postId %>"
                name="vote-<%= postId %>"
                value="<%= optionText %>"
                data-post-id="<%= postId %>"
            />
            <span><%= optionText %></span>
            <img src="<%= (imageUrl != null && !imageUrl.isEmpty()) ? imageUrl : "image.png" %>" alt="항목 이미지" class="poll-option-image" />
        </label>
        <%
            }
            optionRs.close();
            optionStmt.close();
        %>
        <button class="vote-button" type="button" data-post-id="<%= postId %>">투표하기</button>
    </div>
    <br />
    <a href="post.jsp?post_id=<%= postId %>#comment-section" class="comment-button">
        <img src="Message square.png" alt="댓글 이미지" />
    </a>
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
