<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Compare Mate</title>
    <link rel="stylesheet" href="main.css" />
</head>
<style>
    /* 선택된 카테고리 스타일 */
    .side ul li a.active {
        font-weight: bold;
        color: #87ab69; /* 원하는 색상으로 변경 */
        /* 추가적인 스타일을 원하면 여기에 작성 */
    }

    /* 기타 기존 스타일들 */
    /* ... */
</style>
<body>
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
        <hr class="custom-hr" />
    </header>

    <%
        // 현재 선택된 카테고리를 가져옵니다. 기본값은 "전체 게시글"입니다.
        String selectedCategory = request.getParameter("category");
        if (selectedCategory == null || selectedCategory.equals("전체 게시글")) {
            selectedCategory = "전체 게시글";
        }
    %>

    <aside class="side">
        <ul>
            <li id="one"><b>카테고리</b></li>
            <li>
                <a href="main.jsp?category=전체 게시글" 
                   data-category="전체 게시글" 
                   class="<%= selectedCategory.equals("전체 게시글") ? "active" : "" %>">
                   전체 게시글
                </a>
            </li>
            <li>
                <a href="main.jsp?category=전자제품" 
                   data-category="전자제품" 
                   class="<%= selectedCategory.equals("전자제품") ? "active" : "" %>">
                   전자제품
                </a>
            </li>
            <li>
                <a href="main.jsp?category=패션/의류" 
                   data-category="패션/의류" 
                   class="<%= selectedCategory.equals("패션/의류") ? "active" : "" %>">
                   패션/의류
                </a>
            </li>
            <li>
                <a href="main.jsp?category=뷰티/건강" 
                   data-category="뷰티/건강" 
                   class="<%= selectedCategory.equals("뷰티/건강") ? "active" : "" %>">
                   뷰티/건강
                </a>
            </li>
            <li>
                <a href="main.jsp?category=식품/음료" 
                   data-category="식품/음료" 
                   class="<%= selectedCategory.equals("식품/음료") ? "active" : "" %>">
                   식품/음료
                </a>
            </li>
            <li>
                <a href="main.jsp?category=생활용품" 
                   data-category="생활용품" 
                   class="<%= selectedCategory.equals("생활용품") ? "active" : "" %>">
                   생활용품
                </a>
            </li>
            <li>
                <a href="main.jsp?category=취미/여가" 
                   data-category="취미/여가" 
                   class="<%= selectedCategory.equals("취미/여가") ? "active" : "" %>">
                   취미/여가
                </a>
            </li>
            <li>
                <a href="main.jsp?category=자동차/오토바이" 
                   data-category="자동차/오토바이" 
                   class="<%= selectedCategory.equals("자동차/오토바이") ? "active" : "" %>">
                   자동차/오토바이
                </a>
            </li>
            <li>
                <a href="main.jsp?category=기타" 
                   data-category="기타" 
                   class="<%= selectedCategory.equals("기타") ? "active" : "" %>">
                   기타
                </a>
            </li>
        </ul>
    </aside>

    <div class="floating-button">
        <a href="write.jsp">
            <img src="Plus.png" alt="플러스 버튼" />
        </a>
    </div>

    <div class="content">
        <h2><%= selectedCategory %></h2>
        <jsp:include page="posts.jsp" />
    </div>

    <!-- 로그인 상태를 JavaScript로 전달 -->
    <%
        boolean isLoggedIn = (session.getAttribute("userId") != null);
    %>
    <script>
        var isLoggedIn = <%= isLoggedIn ? "true" : "false" %>;
    </script>
    <script src="main.js"></script>
</body>
</html>
