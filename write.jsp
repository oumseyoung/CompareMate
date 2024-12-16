<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

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
      <div class="form-group-inline">
        <label for="category">카테고리</label>
        <select id="category" name="category" required>
          <option hidden>카테고리 선택</option>
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
        <input type="text" id="title" name="title" placeholder="게시글 제목을 작성하세요" required>
      </div>

      <div class="poll">
        <div class="poll-header">
          <img src="vote.png" alt="투표 아이콘" />
          <span>투표</span>
        </div>
        <div class="poll-layout">
          <div class="poll-content">
            <div class="poll-options">
              <div class="poll-option">
                <input type="text" placeholder="항목 입력" name="pollOption[]">
                <input type="file" accept="image/*" style="display: none;" id="file-input">
                <img src="image.png" alt="이미지 추가" class="upload-trigger">
              </div>
              <div class="poll-option">
                <input type="text" placeholder="항목 입력" name="pollOption[]">
                <input type="file" accept="image/*" style="display: none;" id="file-input">
                <img src="image.png" alt="이미지 추가" class="upload-trigger">
              </div>
              <button type="button" class="add-option">+ 항목 추가</button>
            </div>
            <label>
              <input type="checkbox" id="multi-select" name="multiSelect"> 복수선택
            </label>

            <div class="poll-settings">
    <label for="end-date">투표 종료시간 설정</label>
    <div class="date-time-inputs">
      <input type="date" id="end-date" name="endDate" value="">
      <input type="time" id="end-time" name="endTime" value="">
    </div>
    <label><input type="checkbox" name="notify"> 투표 종료 알림 받음</label>
            </div>
          </div>

          <textarea placeholder="게시글을 작성하세요." name="content"></textarea>
        </div>
      </div>
      <div class="form-actions">
        <button type="button" id="cancel" class="cancel" onclick="location.href='post_list.jsp">취소</button>
        <button type="submit" id="upload" class="upload">업로드</button>
      </div>
      </form>
  </main>
  <script src="write.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      var dateInput = document.getElementById('end-date');
      var timeInput = document.getElementById('end-time');

      var today = new Date();
      var yyyy = today.getFullYear();
      var mm = ('0' + (today.getMonth() + 1)).slice(-2); // 월은 0부터 시작하므로 +1 필요
      var dd = ('0' + today.getDate()).slice(-2);
      var hh = ('0' + today.getHours()).slice(-2);
      var mi = ('0' + today.getMinutes()).slice(-2);

      var minDate = yyyy + '-' + mm + '-' + dd;
      dateInput.setAttribute('min', minDate);

      dateInput.addEventListener('change', function() {
        if (dateInput.value === minDate) {
          // 선택한 날짜가 오늘인 경우
          var minTime = hh + ':' + mi;
          timeInput.setAttribute('min', minTime);
        } else {
          // 선택한 날짜가 미래인 경우
          timeInput.removeAttribute('min');
        }
      });

      // 페이지 로드 시 날짜가 이미 선택되어 있는 경우를 대비
      if (dateInput.value === minDate) {
        var minTime = hh + ':' + mi;
        timeInput.setAttribute('min', minTime);
      }
    });
  </script>
</body>
</html>