<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CM mypage</title>
  <link rel="stylesheet" href="mypage.css" />
</head>

<body>
  <header>
    <a href="main.html"><img src="icon.png" alt="CM" id="CM" /></a>
    <div class="up">
      <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()" />
      <div id="layer" class="hidden">
        <!--이부분 수정해야합니다!!!!!-->
        <img src="trash.png" alt="휴지통" id="trash" onclick="clearAlerts()" />
        <ul id="alert-list">
          <a href="#">
            <li class="alert-item">
              <img src="circle.png" alt="프로필" /><span>투표 내용 또는 댓글 내용<br />게시글 제목</span>
            </li>
          </a>
        </ul>
      </div>

      <a href="main.html">게시판</a>
      <a href="mypage.html">마이페이지</a>
      <a href="first.html">로그아웃</a>
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
        <img src="" class="profile-image" id="profile-image" />
        <div class="camera hidden" id="camera">
          <img src="camera.png" alt="수정" id="camera-icon" />
          <input type="file" id="file-input" class="hidden" accept=".png, .jpg, .jpeg" />
        </div>
        <div class="profile-details">
          <p>
            <b id="nickname">본인 닉네임(마이페이지니까)</b>
            <input type="text" id="nickname-input" class="hidden" value="본인 닉네임(마이페이지니까)" />
            <span><img src="germinal.png" alt="새싹" style="width: 30px; margin-left: 15px" /></span>
            <span><img src="edit.png" alt="수정" id="edit-profile" style="width: 25px; margin-left: 15px" /></span>
          </p>
          <p>
            <b>관심분야</b>
            <span id="interest-list" style="
                  font-weight: 600;
                  color: rgba(0, 0, 0, 0.47);
                  margin-left: 15px;
                ">
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
            <b>내가 쓴 게시글 수:</b> 7 &nbsp;&nbsp;&nbsp;&nbsp;
            <b>답변한 게시글 수:</b> 12 &nbsp;&nbsp;&nbsp;&nbsp;
            <button id="bookmark" type="button" onclick="location.href='bookmarkpage.html'">
              <img src="blackmark.png" alt="북마크" />북마크
            </button>
          </div>
        </div>
      </div>
      <hr class="profile-hr" />
      <h3>최홍서님이 쓴 게시글</h3>
      <!-- 게시글 1 -->
      <div class="post" data-category="electronics" data-post-id="1">

        <div class="menu-bookmark">
          <img src="menu.png" alt="메뉴" class="menu-icon" />
          <div class="menu-popup hidden">
            <button class="delete-post-btn">삭제</button>
          </div>
          <div class="bookmark">
            <input type="checkbox" id="bookmark-1" class="bookmark-checkbox" />
            <label for="bookmark-1">
              <img src="bookmark.png" alt="북마크" class="bookmark-icon" />
            </label>
          </div>
        </div>
        <a href="post.html" class="post-link">
          <h3 class="post-title">둘 중에 무엇을 살까요?</h3>
          <div class="post-header">
            <a href="profile.html">
              <img src="circle.png" alt="프로필" class="profile-pic" />
            </a>
            <div>
              <span class="username">이욱현</span>
              <span class="date">2024년 10월 17일 17:51</span>
            </div>
          </div>
          <p>개발용 노트북을 사려고 합니다.</p>
        </a>
        <div class="poll" data-post-id="1">
          <div class="poll-header">
            <img src="vote.png" alt="투표 아이콘" />
            <span>투표</span><span id="multi-select" data-post-id="1">복수선택 가능</span>
          </div>
          <div id="image-popup" class="hidden">
            <div class="popup-content">
              <img id="popup-image" src="" alt="팝업 이미지" />
              <button id="close-popup" type="button">닫기</button>
            </div>
          </div>
          <label class="poll-option">
            <input type="checkbox" id="option1-1" name="vote-1" value="항목 1" data-post-id="1" />
            <span>항목 1</span>
            <img src="image.png" alt="항목 이미지" />
          </label>
          <label class="poll-option">
            <input type="checkbox" id="option2-1" name="vote-1" value="항목 2" data-post-id="1" />
            <span>항목 2</span>
            <img src="image.png" alt="항목 이미지" />
          </label>
          <label class="poll-option">
            <input type="checkbox" id="option3-1" name="vote-1" value="항목 3" data-post-id="1" />
            <span>항목 3</span>
            <img src="image.png" alt="항목 이미지" />
          </label>
          <button class="vote-button" type="button" data-post-id="1">
            투표하기
          </button>
          <!-- 투표 버튼 -->
        </div>
        <br />
        <a href="post.html#comment-section" class="comment-button">
          <img src="Message square.png" alt="댓글 이미지" />
        </a>
      </div>

      <!-- 게시글 2 -->
      <div class="post" data-category="electronics" data-post-id="2">

        <div class="menu-bookmark">
          <img src="menu.png" alt="메뉴" class="menu-icon" />
          <div class="menu-popup hidden">
            <button class="delete-post-btn">삭제</button>
            <button class="share-post-btn">공유</button>
          </div>
          <div class="bookmark">
            <input type="checkbox" id="bookmark-2" class="bookmark-checkbox" />
            <label for="bookmark-2">
              <img src="bookmark.png" alt="북마크" class="bookmark-icon" />
            </label>
          </div>
        </div>
        <a href="post.html" class="post-link">
          <h3 class="post-title">둘 중에 무엇을 살까요?</h3>
          <div class="post-header">
            <a href="profile.html">
              <img src="circle.png" alt="프로필" class="profile-pic" />
            </a>
            <div>
              <span class="username">이욱현</span>
              <span class="date">2024년 10월 17일 17:51</span>
            </div>
          </div>
          <p>개발용 노트북을 사려고 합니다.</p>
        </a>
        <div class="poll" data-post-id="2" data-multiple-choice="false">
          <div class="poll-header">
            <img src="vote.png" alt="투표 아이콘" />
            <span>투표</span><span id="multi-select" data-post-id="2">복수선택 불가능</span>
          </div>
          <div id="image-popup" class="hidden">
            <div class="popup-content">
              <img id="popup-image" src="" alt="팝업 이미지" />
              <button id="close-popup" type="button">닫기</button>
            </div>
          </div>
          <label class="poll-option">
            <input type="radio" id="option1-2" name="vote-2" value="항목 1" data-post-id="2" />
            <span>항목 1</span>
            <img src="image.png" alt="항목 이미지" />
          </label>
          <label class="poll-option">
            <input type="radio" id="option2-2" name="vote-2" value="항목 2" data-post-id="2" />
            <span>항목 2</span>
            <img src="image.png" alt="항목 이미지" />
          </label>
          <label class="poll-option">
            <input type="radio" id="option3-2" name="vote-2" value="항목 3" data-post-id="2" />
            <span>항목 3</span>
            <img src="image.png" alt="항목 이미지" />
          </label>
          <button class="vote-button" type="button" data-post-id="2">
            투표하기
          </button>
        </div>
        <br />
        <a href="post.html#comment-section" class="comment-button">
          <img src="Message square.png" alt="댓글 이미지" />
        </a>
      </div>
    </div>
  </div>
  <script src="mypage.js"></script>
</body>

</html>