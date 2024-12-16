<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // 사용자 세션 확인
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement postStmt = null, alertStmt = null;
    ResultSet postRs = null, alertRs = null;
    List<Map<String, String>> posts = new ArrayList<>();
    List<Map<String, String>> alerts = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        // 게시글 데이터 가져오기
        String postQuery = "SELECT post_id, title, content, reg_date, category FROM posts WHERE user_id = ? ORDER BY reg_date DESC";
        postStmt = conn.prepareStatement(postQuery);
        postStmt.setString(1, userId);
        postRs = postStmt.executeQuery();

        while (postRs.next()) {
            Map<String, String> post = new HashMap<>();
            post.put("postId", String.valueOf(postRs.getInt("post_id")));
            post.put("title", postRs.getString("title"));
            post.put("content", postRs.getString("content"));
            post.put("regDate", postRs.getTimestamp("reg_date").toString());
            post.put("category", postRs.getString("category"));
            posts.add(post);
        }

        // 알림 데이터 가져오기
        String alertQuery = "SELECT message, post_id FROM alerts WHERE user_id = ? ORDER BY created_at DESC";
        alertStmt = conn.prepareStatement(alertQuery);
        alertStmt.setString(1, userId);
        alertRs = alertStmt.executeQuery();

        while (alertRs.next()) {
            Map<String, String> alert = new HashMap<>();
            alert.put("message", alertRs.getString("message"));
            alert.put("postId", String.valueOf(alertRs.getInt("post_id")));
            alerts.add(alert);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (postRs != null) try { postRs.close(); } catch (SQLException e) {}
        if (alertRs != null) try { alertRs.close(); } catch (SQLException e) {}
        if (postStmt != null) try { postStmt.close(); } catch (SQLException e) {}
        if (alertStmt != null) try { alertStmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CM 마이페이지</title>
    <link rel="stylesheet" href="mypage.css" />
</head>
<body>
    <header>
        <a href="main.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
        <div class="up">
            <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()" />
            <div id="layer" class="hidden">
                <img src="trash.png" alt="휴지통" id="trash" onclick="clearAlerts()" />
                <ul id="alert-list">
                    <% if (!alerts.isEmpty()) { 
                           for (Map<String, String> alert : alerts) { 
                               String message = alert.get("message");
                               String postId = alert.get("postId");
                    %>
                        <li class="alert-item">
                            <a href="post_details.jsp?post_id=<%= postId %>" style="text-decoration: none;">
                                <img src="circle.png" alt="프로필" />
                                <span><%= message %></span>
                            </a>
                        </li>
                    <% } 
                       } else { %>
                        <li>알림이 없습니다.</li>
                    <% } %>
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
                <img src="circle.png" class="profile-image" />
                <div class="profile-details">
                    <p><b id="nickname"><%= userId %></b></p>
                    <div class="line">
                        <b>내가 쓴 게시글 수:</b> <%= posts.size() %>
                        <button id="bookmark" type="button" onclick="location.href='bookmarkpage.jsp'">
                            <img src="blackmark.png" alt="북마크" />북마크
                        </button>
                    </div>
                </div>
            </div>
            <hr class="profile-hr" />
            <h3><%= userId %>님이 쓴 게시글</h3>

            <% for (Map<String, String> post : posts) { %>
                <div class="post" data-category="<%= post.get("category") %>" data-post-id="<%= post.get("postId") %>">
                    <a href="post_details.jsp?post_id=<%= post.get("postId") %>" class="post-link">
                        <h3 class="post-title"><%= post.get("title") %></h3>
                        <div class="post-header">
                            <span class="date"><%= post.get("regDate") %></span>
                        </div>
                        <p><%= post.get("content") %></p>
                    </a>
                </div>
            <% } %>
        </div>
    </div>
    <script src="mypage.js"></script>
</body>
</html>
