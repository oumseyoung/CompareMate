<%@page import="java.sql.Date"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
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
            String title = postRs.getString("title") != null ? postRs.getString("title") : "";
            String content = postRs.getString("content") != null ? postRs.getString("content") : "";
            String category = postRs.getString("category") != null ? postRs.getString("category") : "";
            boolean multiSelect = postRs.getBoolean("multi_select");
            Timestamp regDate = postRs.getTimestamp("reg_date");
            boolean notify = postRs.getBoolean("notify");
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
    // 투표 종료 알림
    if (postData_<%= postId %>.notify === "true" && postData_<%= postId %>.endDate && postData_<%= postId %>.endTime) {
        const endDateTime = new Date(postData_<%= postId %>.endDate + 'T' + postData_<%= postId %>.endTime);
        const currentTime = new Date();

        if (endDateTime > currentTime) {
            const timeDifference = endDateTime - currentTime;

            setTimeout(() => {
                addAlert("투표가 종료되었습니다!", "circle.png");
            }, timeDifference);
        }
    }

    // 댓글 추가 시 알림
    document.addEventListener("DOMContentLoaded", function() {
    const commentButton = document.querySelector(".add-comment-button[data-post-id='<%= postId %>']");

    if (commentButton) {
        commentButton.addEventListener("click", function() {
            const commentInput = document.getElementById("comment-input-<%= postId %>");
            const commentText = commentInput.value.trim();

            if (commentText) {
                // 서버에 댓글 추가 요청 (AJAX 요청으로 구현)
                const formData = new FormData();
                formData.append("postId", <%= postId %>);
                formData.append("comment", commentText);

                fetch("add_comment.jsp", {
                    method: "POST",
                    body: formData
                })
                .then(response => response.json())
                .then(result => {
                    if (result.status === "success") {
                        alert("댓글이 추가되었습니다.");
                        location.reload(); // 알림 및 댓글 새로고침
                    } else {
                        alert("댓글 추가에 실패했습니다.");
                    }
                });
            } else {
                alert("댓글을 입력하세요.");
            }
        });
    }
});

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
                <span class="date"><%= (regDate != null) ? regDate.toString() : "" %></span>
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
<a href="#" class="comment-button" onclick="document.getElementById('comments-section-<%= postId %>').classList.toggle('hidden'); return false;">
    <img src="Message square.png" alt="댓글 아이콘">
</a>

    <hr class="comment-hr">

<!-- 댓글 섹션 -->
<!-- 댓글 섹션 -->
<div class="comments-section hidden" id="comments-section-<%= postId %>">
    <h3 class="comment-count">댓글</h3>
    <ul id="comment-list-<%= postId %>">
        <%
        // 댓글 조회 쿼리 실행
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
        <img src="circle.png" alt="프로필" class="profile-pic">
        <span class="comment-user-id"><%= commentUserId %></span>
        <span class="comment-date"><%= commentDate %></span>
    </div>
    <p id="comment-text-<%= commentRs.getInt("comment_id") %>"><%= commentText %></p>

    <!-- 수정/삭제 링크: 본인 아이디만 보이게 설정 -->
<%
    String sessionUserId = (String) session.getAttribute("userId");
    if (sessionUserId != null && commentUserId.equals(sessionUserId)) { 
%>
        <div class="comment-actions">
            <a href="#" class="edit-comment" data-comment-id="<%= commentRs.getInt("comment_id") %>">수정</a> |
            <a href="#" class="delete-comment" data-comment-id="<%= commentRs.getInt("comment_id") %>">삭제</a>
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
        } // 게시글 반복 끝
        postRs.close();
        postStmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("데이터베이스 오류 발생: " + e.getMessage());
    } finally {
        if (optionRs != null) try { optionRs.close(); } catch (SQLException ignore) {}
        if (optionStmt != null) try { optionStmt.close(); } catch (SQLException ignore) {}
        if (postRs != null) try { postRs.close(); } catch (SQLException ignore) {}
        if (postStmt != null) try { postStmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>