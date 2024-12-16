<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 상세보기</title>
    <link rel="stylesheet" href="main.css">
</head>

<body>
    <header>
        <a href="main.html">
            <img src="icon.png" alt="CM" id="CM" />
        </a>
        <div class="up">
            <img src="Bell.png" alt="알람" id="bell" onclick="toggleLayer()">
            <div id="layer" class="hidden">
                <img src="trash.png" alt="휴지통" id="trash" onclick="clearAlerts()">
                <ul id="alert-list"></ul>
            </div>
            <a href="main.html">게시판</a>
            <a href="mypage.html">마이페이지</a>
            <a href="first.html">로그아웃</a>
        </div>
        <hr class="custom-hr">
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
        <div class="post" data-category="electronics" data-post-id="1">
            <a href="post.html" class="post-link">
                <div class="bookmark">
                    <input type="checkbox" id="bookmark-1" class="bookmark-checkbox" />
                    <label for="bookmark-1">
                        <img src="bookmark.png" alt="북마크" class="bookmark-icon">
                    </label>
                </div>
                <h3 class="post-title">둘 중에 무엇을 살까요?</h3>
                <div class="post-header">
                    <a href="profilepage.html">
                        <img src="circle.png" alt="프로필" class="profile-pic">
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
                    <input type="checkbox" id="option1-1" name="vote-1" value="항목 1" data-post-id="1">
                    <span>항목 1</span>
                    <img src="image.png" alt="항목 이미지" />
                </label>
                <label class="poll-option">
                    <input type="checkbox" id="option2-1" name="vote-1" value="항목 2" data-post-id="1">
                    <span>항목 2</span>
                    <img src="image.png" alt="항목 이미지" />
                </label>
                <label class="poll-option">
                    <input type="checkbox" id="option3-1" name="vote-1" value="항목 3" data-post-id="1">
                    <span>항목 3</span>
                    <img src="image.png" alt="항목 이미지" />
                </label>
                <button class="vote-button" type="button" data-post-id="1">투표하기</button> <!-- 투표 버튼 -->
            </div><br>
            <a href="post.html#comment-section" class="comment-button">
                <img src="Message square.png" alt="댓글 이미지" />
            </a>
            <hr class="comment-hr">

            <h3 class="comment-count">댓글 2</h3>
            <ul id="comment-list">
                <li>
                    <div class="comment-header">
                        <img src="circle.png" alt="프로필" class="profile-pic">
                        엄세영
                    </div>
                    <p>항목 1이 키감이 좋아서 추천함.</p>
                </li>
                <li>
                    <div class="comment-header">
                        <img src="circle.png" alt="프로필" class="profile-pic">
                        최홍서
                    </div>
                    <p>항목 2가 화면이 깔끔해서 오랫동안 작업해도 편함.</p>
                </li>
            </ul>
            <textarea id="comment-input" placeholder="댓글을 입력하세요"></textarea>
            <button id="add-comment-button">댓글 추가</button>
        </div>
    </div>
    <script src="main.js"></script>
</body>

</html>