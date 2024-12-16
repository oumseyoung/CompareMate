@ -0,0 +1,86 @@
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

<body>
    <header>
        <a href="main.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
        <div class="up">
            <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()" />
            <div id="layer" class="hidden">
                <!--이부분 수정해야합니다!!!!!-->
                <img
                    src="trash.png"
                    alt="휴지통"
                    id="trash"
                    onclick="clearAlerts()"
                />
                <ul id="alert-list">
                    <a href="#">
                        <li class="alert-item">
                            <img src="circle.png" alt="프로필" />
                            <span>투표 내용 또는 댓글 내용<br />게시글 제목</span>
                        </li>
                    </a>
                </ul>
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
    <div class="floating-button">
        <a href="write.jsp">
            <img src="Plus.png" alt="플러스 버튼" />
        </a>
    </div>
    <div class="content">
        <h2>전체 게시글</h2>
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