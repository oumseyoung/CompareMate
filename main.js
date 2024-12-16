// 알람 레이어의 표시/숨김
function toggleLayer() {
    const layer = document.getElementById("layer");
    layer.classList.toggle("hidden"); // 'hidden' 클래스를 추가하거나 제거하여 표시/숨김 토글
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
                <span style="color: gray; font-size: 12px;">게시글 제목</span>
            </div>
        </a>
    `;

    alertList.insertBefore(newAlert, alertList.firstChild);
}

// 알람 비우기
function clearAlerts() {
    const alertList = document.getElementById("alert-list");
    alertList.innerHTML = ""; // 알람 목록을 비움
}

// 5초마다 무작위 알람 추가
setInterval(() => {
    const messages = [
        { text: "게시물에 댓글이 달렸습니다.", image: "circle.png" },
        { text: "투표가 종료되었습니다.", image: "circle.png" },
    ];

    const randomMessage = messages[Math.floor(Math.random() * messages.length)];
    addAlert(randomMessage.text, randomMessage.image);
}, 5000);

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

// 댓글 처리
const addCommentButton = document.getElementById('add-comment-button');
const commentInput = document.getElementById('comment-input');
const commentList = document.getElementById('comment-list');

if (addCommentButton && commentInput && commentList) {
    addCommentButton.addEventListener('click', () => {
        const commentText = commentInput.value.trim();
        if (commentText) {
            const newComment = document.createElement('li');
            newComment.innerHTML = `
                <div class="comment-header">
                    <img src="circle.png" alt="프로필" class="profile-pic">
                    익명
                </div>
                <p>${commentText}</p>
            `;
            commentList.appendChild(newComment);
            commentInput.value = '';
            updateCommentCount();
        } else {
            alert('댓글을 입력하세요.');
        }
    });
}

function updateCommentCount() {
    const commentList = document.getElementById('comment-list');
    const commentCountElement = document.querySelector('.comment-count');
    const commentCount = commentList ? commentList.children.length : 0;
    if (commentCountElement) {
        commentCountElement.textContent = `댓글 ${commentCount}`;
    }
}

window.addEventListener('load', () => {
    updateCommentCount();
});

// 투표 옵션 클릭 이벤트 처리
document.querySelectorAll('.poll-option').forEach(option => {
    const input = option.querySelector('input[type="checkbox"], input[type="radio"]');

    option.addEventListener('click', () => {
        if (input.type === 'radio') {
            // 라디오 버튼: 단일 선택
            const name = input.name;
            document.querySelectorAll(`input[name="${name}"]`).forEach(otherInput => {
                const otherOption = otherInput.closest('.poll-option');
                otherOption.classList.remove('checked');
            });
            input.checked = true;
            option.classList.add('checked');
        } else if (input.type === 'checkbox') {
            // 체크박스: 다중 선택
            input.checked = !input.checked;
            if (input.checked) {
                option.classList.add('checked');
            } else {
                option.classList.remove('checked');
            }
        }
    });
});

// 투표 처리
document.querySelectorAll('button.vote-button').forEach(voteButton => {
    voteButton.addEventListener('click', () => {
        // 버튼이 비활성화되어 있는 경우 아무 동작도 하지 않음
        if (voteButton.disabled) {
            return;
        }

        const postId = voteButton.getAttribute('data-post-id');
        const poll = voteButton.closest('.poll');
        const pollInputs = poll.querySelectorAll('input[type="checkbox"], input[type="radio"]');

        // 선택된 옵션 가져오기
        const selectedOptions = Array.from(pollInputs)
            .filter(input => input.checked)
            .map(input => input.value);

        if (selectedOptions.length > 0) {
            // FormData를 사용하여 데이터 준비
            const formData = new URLSearchParams();
            formData.append('post_id', postId);
            selectedOptions.forEach(option => formData.append('options[]', option));

            // 서버로 데이터 전송
            fetch('vote_process.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData.toString(),
            })
                .then(response => response.json())
                .then(data => {
                    if (data.status === 'success') {
                        alert('투표가 완료되었습니다!');
                        // 페이지 새로고침
                        window.location.reload();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('투표 처리 중 오류가 발생했습니다.');
                });
        } else {
            alert('항목을 선택해주세요.');
        }
    });
});

// 투표 UI 업데이트
function updateVoteUI(postId, results) {
    const poll = document.querySelector(`.poll[data-post-id="${postId}"]`);
    const pollOptions = poll.querySelectorAll('.poll-option');

    // 투표 옵션별 투표 수 업데이트
    pollOptions.forEach(option => {
        const input = option.querySelector('input[type="checkbox"], input[type="radio"]');
        const optionId = input.value; // 옵션 ID 가져오기
        const result = results.find(r => r.option_id == optionId);

        let voteCountSpan = option.querySelector('.vote-count');
        if (!voteCountSpan) {
            // 투표 수 표시를 위한 span 생성
            voteCountSpan = document.createElement('span');
            voteCountSpan.className = 'vote-count';
            option.appendChild(voteCountSpan);
        }
        // 서버에서 반환된 결과를 표시
        voteCountSpan.textContent = `(${result ? result.count : 0}표)`;
    });
}

// 기존 함수들...

// 댓글 섹션 토글 함수
function toggleComments(postId) {
    const commentsSection = document.getElementById(`comments-section-${postId}`);
    if (commentsSection.classList.contains('hidden')) {
        // 댓글 섹션 표시
        commentsSection.classList.remove('hidden');
        // 댓글 로드
        if (!commentsSection.getAttribute('data-loaded')) {
            fetchComments(postId);
        }
    } else {
        // 댓글 섹션 숨기기
        commentsSection.classList.add('hidden');
    }
}

// 댓글 가져오기 함수
function fetchComments(postId) {
    fetch(`fetch_comments.jsp?post_id=${postId}`)
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.status === 'success') {
                    const commentList = document.getElementById(`comment-list-${postId}`);
                    commentList.innerHTML = ''; // 기존 댓글 초기화
                    data.comments.forEach(comment => {
                        const commentItem = document.createElement('li');
                        commentItem.innerHTML = `
                            <div class="comment-header">
                                <img src="circle.png" alt="프로필" class="profile-pic">
                                <span>${escapeHtml(comment.userId)}</span>
                            </div>
                            <p>${escapeHtml(comment.commentText)}</p>
                        `;
                        commentList.appendChild(commentItem);
                    });
                    // 댓글 수 업데이트
                    const commentCount = data.commentCount;
                    const commentCountElement = document.querySelector(`#comments-section-${postId} .comment-count`);
                    commentCountElement.textContent = `댓글 ${commentCount}`;
                    // 데이터 로드 완료 표시
                    commentsSection.setAttribute('data-loaded', 'true');
                } else {
                    alert(data.message);
                }
            } catch (e) {
                console.error('JSON parsing error:', e);
                alert('댓글을 가져오는 중 오류가 발생했습니다.');
            }
        })
        .catch(error => {
            console.error('Error fetching comments:', error);
            alert('댓글을 가져오는 중 오류가 발생했습니다.');
        });
}

// 댓글 추가 함수
function addComment(postId) {
    const commentInput = document.getElementById(`comment-input-${postId}`);
    const commentText = commentInput.value.trim();

    if (commentText === '') {
        alert('댓글을 입력하세요.');
        return;
    }

    const formData = new URLSearchParams();
    formData.append('post_id', postId);
    formData.append('comment_text', commentText);

    fetch('add_comment.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
    })
    .then(response => response.text())
    .then(text => {
        try {
            const data = JSON.parse(text);
            if (data.status === 'success') {
                // 새로운 댓글 추가
                const commentList = document.getElementById(`comment-list-${postId}`);
                const newComment = document.createElement('li');
                newComment.innerHTML = `
                    <div class="comment-header">
                        <img src="circle.png" alt="프로필" class="profile-pic">
                        <span>익명</span> <!-- 실제 사용자명 또는 익명 처리 필요 -->
                    </div>
                    <p>${escapeHtml(data.commentText)}</p>
                `;
                commentList.appendChild(newComment);
                // 댓글 입력 초기화
                commentInput.value = '';
                // 댓글 수 업데이트
                const commentCountElement = document.querySelector(`#comments-section-${postId} .comment-count`);
                let currentCount = parseInt(commentCountElement.textContent.replace('댓글 ', '')) || 0;
                commentCountElement.textContent = `댓글 ${currentCount + 1}`;
            } else {
                alert(data.message);
            }
        } catch (e) {
            console.error('JSON parsing error:', e);
            alert('댓글을 추가하는 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('Error adding comment:', error);
        alert('댓글을 추가하는 중 오류가 발생했습니다.');
    });
}

// HTML 이스케이프 함수 (XSS 방지)
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;',
    };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

// DOMContentLoaded 이벤트 리스너
document.addEventListener('DOMContentLoaded', () => {
    // 댓글 버튼 클릭 이벤트 리스너
    const commentButtons = document.querySelectorAll('.comment-button');
    commentButtons.forEach(button => {
        button.addEventListener('click', (event) => {
            event.preventDefault();
            const postId = button.getAttribute('data-post-id');
            toggleComments(postId);
        });
    });

    // 댓글 추가 버튼 클릭 이벤트 리스너
    const addCommentButtons = document.querySelectorAll('.add-comment-button');
    addCommentButtons.forEach(button => {
        button.addEventListener('click', () => {
            const postId = button.getAttribute('data-post-id');
            addComment(postId);
        });
    });
});
