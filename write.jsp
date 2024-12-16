<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { 
%>
        <script>
            alert('로그인 후 이용해 주세요.');
            window.location.href = 'login.jsp';
        </script>
<%
        return; // Stop further processing of the page
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="write.css">
  <title>게시글 작성</title>
</head>

<body>
  <header>
    <div class="header-container">
      <img src="icon.png" alt="CM" id="CM" />
      <div class="up">
        <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()" />
        <div id="layer" class="hidden">
          <ul>
            <c:forEach var="alarm" items="${alarms}">
              <li><a href="#"><c:out value="${alarm}" /></a></li>
            </c:forEach>
          </ul>
        </div>
        <a href="main.jsp">게시판</a>
        <a href="mypage.jsp">마이페이지</a>
        <a href="logout.jsp">로그아웃</a>
      </div>
    </div>
    <hr class="custom-hr">
  </header>

  <main>
    <form action="post_new_send.jsp" method="post">
      <h1>게시글 작성</h1>
      <!-- Rest of your form elements -->
      <div class="form-actions">
        <button type="button" id="cancel" class="cancel" onclick="location.href='post_list.jsp'">취소</button>
        <button type="submit" id="upload" class="upload">업로드</button>
      </div>
    </form>
  </main>
  <script src="write.js"></script>
  <!-- Your existing script -->
</body>
</html>
