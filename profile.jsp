<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${nickname}'s profile</title>
    <link rel="stylesheet" href="profile.css" />
  </head>
  <body>
    <header>
      <a href="main.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
      <div class="up">
        <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()" />
        <div id="layer" class="hidden">
          <img src="trash.png" alt="휴지통" id="trash" onclick="clearAlerts()" />
          <ul id="alert-list">
            <c:forEach var="alert" items="${alerts}">
              <a href="${alert.link}">
                <li class="alert-item">
                  <img src="${alert.image}" alt="프로필" />
                  <span>${alert.message}</span>
                </li>
              </a>
            </c:forEach>
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
          <img src="${profileImage}" class="profile-image" id="profile-image" />
          <div class="profile-details">
            <p>
              <b id="nickname">${nickname}(남의 프로필이니까)</b>
              <span><img src="germinal.png" alt="새싹" style="width: 30px; margin-left: 15px" /></span>
            </p>
            <p>
              <b>관심분야</b>
              <span id="interest-list" style="font-weight: 600; color: rgba(0, 0, 0, 0.47); margin-left: 15px;">
                ${interest}
              </span>
            </p>
            <div class="line">
              <b>내가 쓴 게시글 수:</b> ${postCount} &nbsp;&nbsp;&nbsp;&nbsp;
              <b>답변한 게시글 수:</b> ${replyCount} &nbsp;&nbsp;&nbsp;&nbsp;
            </div>
          </div>
        </div>
        <hr class="profile-hr" />
        <h3>${nickname}님이 쓴 게시글</h3>

        <!-- 게시글 리스트 -->
        <c:forEach var="post" items="${posts}">
          <div class="post" data-category="${post.category}" data-post-id="${post.id}">
            <a href="post.jsp?postId=${post.id}" class="post-link">
              <div class="bookmark">
                <input type="checkbox" id="bookmark-${post.id}" class="bookmark-checkbox" />
                <label for="bookmark-${post.id}">
                  <img src="bookmark.png" alt="북마크" class="bookmark-icon" />
                </label>
              </div>
              <h3 class="post-title">${post.title}</h3>
              <div class="post-header">
                <a href="profile.jsp?userId=${post.userId}">
                  <img src="${post.userProfileImage}" alt="프로필" class="profile-pic" />
                </a>
                <div>
                  <span class="username">${post.username}</span>
                  <span class="date">${post.date}</span>
                </div>
              </div>
              <p>${post.content}</p>
            </a>
            <div class="poll" data-post-id="${post.id}" data-multiple-choice="${post.multipleChoice}">
              <div class="poll-header">
                <img src="vote.png" alt="투표 아이콘" />
                <span>투표</span>
                <span id="multi-select" data-post-id="${post.id}">
                  <c:choose>
                    <c:when test="${post.multipleChoice}">
                      복수선택 가능
                    </c:when>
                    <c:otherwise>
                      복수선택 불가능
                    </c:otherwise>
                  </c:choose>
                </span>
              </div>
              <div id="image-popup" class="hidden">
                <div class="popup-content">
                  <img id="popup-image" src="" alt="팝업 이미지" />
                  <button id="close-popup" type="button">닫기</button>
                </div>
              </div>
              <c:forEach var="option" items="${post.options}">
                <label class="poll-option">
                  <input
                    type="${post.multipleChoice ? 'checkbox' : 'radio'}"
                    id="option-${option.id}-${post.id}"
                    name="vote-${post.id}"
                    value="${option.value}"
                    data-post-id="${post.id}"
                  />
                  <span>${option.value}</span>
                  <img src="${option.image}" alt="항목 이미지" />
                </label>
              </c:forEach>
              <button class="vote-button" type="button" data-post-id="${post.id}">투표하기</button>
            </div>
            <br />
            <a href="post.jsp?postId=${post.id}#comment-section" class="comment-button">
              <img src="Message square.png" alt="댓글 이미지" />
            </a>
          </div>
        </c:forEach>
      </div>
    </div>
    <script src="profile.js"></script>
  </body>
</html>
