<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="write.css">
    <title>게시글 수정</title>
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
    <%
    Connection connection = null;
    PreparedStatement postStmt = null;
    PreparedStatement pollStmt = null;
    ResultSet postResult = null;
    ResultSet pollResult = null;

    try {
        // JDBC 연결 설정
        Class.forName("com.mysql.cj.jdbc.Driver");
        String dbUrl = "jdbc:mysql://localhost:3306/practice_board?serverTimezone=UTC";
        String dbUser = "root";
        String dbPassword = "0000";
        connection = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // 게시글 ID 가져오기
        String postIdParam = request.getParameter("post_id");
        if (postIdParam == null || postIdParam.trim().isEmpty()) {
            throw new Exception("게시글 ID가 전달되지 않았습니다.");
        }
        int postId = Integer.parseInt(postIdParam);

        // 게시글 데이터 조회
        String postQuery = "SELECT * FROM posts WHERE post_id = ?";
        postStmt = connection.prepareStatement(postQuery);
        postStmt.setInt(1, postId);
        postResult = postStmt.executeQuery();

        if (postResult.next()) {
            // 게시글을 찾은 경우
            String category = postResult.getString("category");
            String title = postResult.getString("title");
            String content = postResult.getString("content");
            boolean multiSelect = postResult.getBoolean("multi_select");
            Timestamp endDate = postResult.getTimestamp("end_date");
            boolean notify = postResult.getBoolean("notify");

            // 투표 데이터 조회
            String pollQuery = "SELECT * FROM poll_options WHERE post_id = ?";
            pollStmt = connection.prepareStatement(pollQuery);
            pollStmt.setInt(1, postId);
            pollResult = pollStmt.executeQuery();
    %>
    <form action="post_modify_send.jsp" method="post">
    <h1>게시글 수정</h1>
        
        <div class="form-group-inline">
            <label for="category">카테고리</label>
            <select id="category" name="category" required>
                <option hidden><%=category %></option>
                <option>전자제품</option>
                <option>패션/의류</option>
                <option>뷰티/건강</option>
                <option>식품/음료</option>
                <option>생활용품</option>
                <option>취미/여가</option>
                <option>자동차/오토바이</option>
                <option>기타</option>
            </select>
        </div>

        <div class="form-group-inline">
            <label for="title">제목</label>
            <input type="text" id="title" name="title" value="<%=title %>" required>
        </div>

        <div class="poll">
            <div class="poll-header">
                <img src="vote.png" alt="투표 아이콘" />
                <span>투표</span>
            </div>
            <div class="poll-layout">
                <div class="poll-content">
                <div class="poll-options">
                <%
       while (pollResult.next()) {
        int optionId = pollResult.getInt("option_id");
        String optionText = pollResult.getString("option_text");
        String optionImage = pollResult.getString("image_url");
    %>
              <div class="poll-option">
                <input type="text" placeholder="항목 입력" name="pollOption[]" value="<%=optionText%>">
                <input type="file" accept="image/*" style="display: none;" id="file-input">
                <% if (optionImage != null && !optionImage.isEmpty()) { %>
                <img src="<%=optionImage %>" alt="이미지 추가" class="upload-trigger">
               <% } else{ %>
               <img src="image.png" alt="이미지 추가" class="upload-trigger">
               <% } %>
              </div>
            <% } %>
              <button type="button" class="add-option">+ 항목 추가</button>
            </div>         
                    <label>
                        <input type="checkbox" id="multi-select" name="multiSelect" <%=multiSelect ? "checked" : "" %>> 복수선택
                    </label>
                    <div class="poll-settings">
                        <label for="end-date">투표 종료시간 설정</label>
                        <div class="date-time-inputs">
                            <input type="date" id="end-date" name="endDate" value="<%=endDate != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(endDate) : "" %>">
                            <input type="time" id="end-time" name="endTime" value="<%=endDate != null ? new java.text.SimpleDateFormat("HH:mm").format(endDate) : "" %>">
                        </div>
                        <label><input type="checkbox" name="notify" <%=notify ? "checked" : "" %>> 투표 종료 전 알림 받음</label>
                    </div>
                </div>

            <textarea id="content" name="content" required><%=content %></textarea>
      </div>
      </div>
        <div class="form-actions">
            <button type="submit" id="upload" class="upload">수정</button>
            <button type="button" id="cancel" class="cancel" onclick="location.href='post_list.jsp'">목록으로</button>
        </div>
    </form>
    <%
        } else {
    %>
        <p>게시글을 찾을 수 없습니다.</p>
    <%
        }
    } catch (NumberFormatException ex) {
    %>
    <p>잘못된 게시글 ID 형식입니다.</p>
    <%
    } catch (Exception ex) {
    %>
    <p>오류 발생: <%= ex.getMessage() %></p>
    <%
    } finally {
        // 자원 정리
        if (pollResult != null) try { pollResult.close(); } catch (Exception e) {}
        if (postResult != null) try { postResult.close(); } catch (Exception e) {}
        if (pollStmt != null) try { pollStmt.close(); } catch (Exception e) {}
        if (postStmt != null) try { postStmt.close(); } catch (Exception e) {}
        if (connection != null) try { connection.close(); } catch (Exception e) {}
    }
    %>
  </main>
  <script src="write.js"></script>
</body>

</html>
