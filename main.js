// 알람 레이어의 표시/숨김
function toggleLayer() {
    const layer = document.getElementById("layer");
    layer.classList.toggle("hidden");
}

// 알람 추가 함수
function addAlert(message, imageUrl) {
    const alertList = document.getElementById("alert-list");

    const newAlert = document.createElement("li");
    newAlert.innerHTML = `
        <a href="#" style="display: flex; align-items: center; text-decoration: none; padding: 10px;">
            <img src="${imageUrl}" alt="프로필" style="width: 30px; height: 30px; border-radius: 50%; margin-left: 5px;" />
            <div style="margin-left: 10px;">
                <span style="font-size: 15px; font-weight: bold; display: block;">${message}</span>
                <span style="color: gray; font-size: 12px;">투표 종료 알림</span>
            </div>
        </a>
    `;

    alertList.insertBefore(newAlert, alertList.firstChild);
}

// 알람 비우기
function clearAlerts() {
    const alertList = document.getElementById("alert-list");

    // 서버에 알림 삭제 요청
    fetch("clear_alerts.jsp", {
        method: "POST",
    })
        .then((response) => response.json())
        .then((data) => {
            if (data.status === "success") {
                alertList.innerHTML = ""; // 클라이언트에서 알림 목록 비우기
                console.log(data.message);
            } else {
                console.error(data.message);
            }
        })
        .catch((error) => {
            console.error("알림 삭제 중 오류 발생:", error);
        });
}

// 카테고리 필터링
const categoryLinks = document.querySelectorAll('.side ul li a');

categoryLinks.forEach(link => {
    link.addEventListener('click', (event) => {
        event.preventDefault();
        const category = link.getAttribute('data-category');
        filterPosts(category);
        window.history.pushState(null, '', `?category=${encodeURIComponent(category)}`);
        updateContentTitle(category);
        highlightSelectedCategory(link);
    });
});

function filterPosts(category) {
    const posts = document.querySelectorAll('.post');

    posts.forEach(post => {
        if (category === '전체 게시글') {
            post.style.display = 'block';
        } else {
            const postCategory = post.getAttribute('data-category');
            if (postCategory === category) {
                post.style.display = 'block';
            } else {
                post.style.display = 'none';
            }
        }
    });
}

function updateContentTitle(category) {
    const contentTitle = document.querySelector('.content h2');
    const categoryNames = {
        "전체 게시글": '전체 게시글',
        "전자제품": '전자제품',
        "패션/의류": '패션/의류',
        "뷰티/건강": '뷰티/건강',
        "식품/음료": '식품/음료',
        "생활용품": '생활용품',
        "취미/여가": '취미/여가',
        "자동차/오토바이": '자동차/오토바이',
        "기타": '기타',
    };

    contentTitle.textContent = categoryNames[category] || '전체 게시글';
}

function getCategoryFromURL() {
    const params = new URLSearchParams(window.location.search);
    return params.get('category') || '전체 게시글';
}

window.addEventListener('load', () => {
    const selectedCategory = getCategoryFromURL();
    filterPosts(selectedCategory);
    updateContentTitle(selectedCategory);
    highlightSelectedCategoryByCategory(selectedCategory);

    // 투표 종료 상태에 따른 UI 업데이트
    const posts = document.querySelectorAll('.post');
    posts.forEach(post => {
        const postId = post.getAttribute('data-post-id');
        const postData = window[`postData_${postId}`];
        if (postData) {
            const isVotingOpen = postData.isVotingOpen;

            // 실시간 투표 종료 시간 확인 및 UI 업데이트 (선택 사항)
            if (postData.endDate && postData.endTime && isVotingOpen) {
                const endDateTime = new Date(`${postData.endDate}T${postData.endTime}`);
                const currentTime = new Date();

                if (currentTime >= endDateTime) {
                    // 투표가 종료되었을 때
                    appendVotingClosedText(post, postId);
                } else {
                    // 남은 시간에 맞춰 타이머 설정
                    const timeRemaining = endDateTime - currentTime;
                    setTimeout(() => {
                        appendVotingClosedText(post, postId);
                    }, timeRemaining);
                }
            }
        }
    });
});

// 투표 종료 텍스트 추가 함수
function appendVotingClosedText(post, postId) {
    // 제목 옆에 "(종료된 투표)" 텍스트 추가
    const titleElement = post.querySelector('.post-title');
    if (titleElement && !post.querySelector('.voting-closed-text')) {
        const votingClosedText = document.createElement('span');
        votingClosedText.className = 'voting-closed-text';
        votingClosedText.textContent = ' (종료된 투표)';
        titleElement.appendChild(votingClosedText);
    }

    // 투표 옵션 비활성화 (서버에서 이미 처리되었으므로 선택 사항)
    const poll = post.querySelector('.poll');
    const pollInputs = poll.querySelectorAll('.poll-option input');
    pollInputs.forEach(option => {
        option.disabled = true;
    });

    // "투표하기" 버튼 비활성화
    const voteButton = poll.querySelector('.vote-button');
    if (voteButton) {
        voteButton.disabled = true;
    }
}

// 하이라이트된 카테고리 표시
function highlightSelectedCategory(link) {
    categoryLinks.forEach(l => {
        l.classList.remove('selected-category');
    });
    link.classList.add('selected-category');
}

function highlightSelectedCategoryByCategory(category) {
    categoryLinks.forEach(l => {
        if (l.getAttribute('data-category') === category) {
            l.classList.add('selected-category');
        } else {
            l.classList.remove('selected-category');
        }
    });
}

// 댓글 버튼 클릭 시 댓글 섹션 토글
// 댓글 버튼(이미지) 클릭 시 댓글 섹션 토글
document.querySelectorAll('.comment-button').forEach(image => {
    image.addEventListener('click', () => {
        const postId = image.getAttribute('data-post-id');
        const commentsSection = document.getElementById(`comments-${postId}`);
        commentsSection.classList.toggle('hidden');
    });
});


// 댓글 추가 버튼 클릭 시 댓글을 서버에 전송하고 목록에 추가
document.querySelectorAll('.add-comment-button').forEach(button => {
    button.addEventListener('click', () => {
        const postId = button.getAttribute('data-post-id');
        const commentInput = document.getElementById(`comment-input-${postId}`);
        const commentText = commentInput.value.trim();

        if (!isLoggedIn) {
            alert("댓글을 작성하려면 로그인하세요.");
            return;
        }

        if (commentText === "") {
            alert("댓글을 입력하세요.");
            return;
        }

        // AJAX 요청을 통해 댓글 추가
        fetch('add_comment.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `post_id=${encodeURIComponent(postId)}&comment_text=${encodeURIComponent(commentText)}`,
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                // 댓글 목록에 새 댓글 추가
                const commentList = document.getElementById(`comment-list-${postId}`);
                const newComment = document.createElement('li');
                newComment.innerHTML = `
                    <div class="comment-header">
                        <img src="circle.png" alt="프로필" class="profile-pic">
                        <span class="nickname">${data.nickname}</span>
                    </div>
                    <p>${data.commentText}</p>
                `;
                commentList.appendChild(newComment);

                // 댓글 카운트 업데이트
                const commentCount = document.getElementById(`comment-count-${postId}`);
                commentCount.textContent = parseInt(commentCount.textContent) + 1;

                // 입력 필드 초기화
                commentInput.value = '';
            } else {
                alert(data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('댓글 추가 중 오류가 발생했습니다.');
        });
    });
});
