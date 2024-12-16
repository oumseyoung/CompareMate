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

            // 실시간 투표 종료 시간 확인 및 UI 업데이트
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
    const titleElement = post.querySelector('.post-title');
    if (titleElement && !post.querySelector('.voting-closed-text')) {
        const votingClosedText = document.createElement('span');
        votingClosedText.className = 'voting-closed-text';
        votingClosedText.textContent = ' (종료된 투표)';
        titleElement.appendChild(votingClosedText);
    }

    const poll = post.querySelector('.poll');
    const pollInputs = poll.querySelectorAll('.poll-option input');
    pollInputs.forEach(option => {
        option.disabled = true;
    });

    const voteButton = poll.querySelector('.vote-button');
    if (voteButton) {
        voteButton.disabled = true;
    }
}

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
            const formData = new URLSearchParams();
            formData.append('post_id', postId);
            selectedOptions.forEach(option => formData.append('options[]', option));

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

function updateVoteUI(postId, results) {
    const poll = document.querySelector(`.poll[data-post-id="${postId}"]`);
    const pollOptions = poll.querySelectorAll('.poll-option');

    pollOptions.forEach(option => {
        const input = option.querySelector('input[type="checkbox"], input[type="radio"]');
        const optionId = input.value;
        const result = results.find(r => r.option_id == optionId);

        let voteCountSpan = option.querySelector('.vote-count');
        if (!voteCountSpan) {
            voteCountSpan = document.createElement('span');
            voteCountSpan.className = 'vote-count';
            option.appendChild(voteCountSpan);
        }
        voteCountSpan.textContent = `(${result ? result.count : 0}표)`;
    });
}

document.addEventListener('DOMContentLoaded', () => {
    // 댓글 버튼 클릭 이벤트
    document.body.addEventListener('click', (event) => {
        const button = event.target.closest('.comment-button');
        if (button) {
            event.preventDefault();
            const postId = button.getAttribute('data-post-id');
            document.getElementById(`comments-section-${postId}`).classList.toggle('hidden');
        }
    });

    // 댓글 추가 버튼 클릭 이벤트
    document.body.addEventListener('click', (event) => {
        const button = event.target.closest('.add-comment-button');
        if (button) {
            event.preventDefault();
            const postId = button.getAttribute('data-post-id');
            const commentInput = document.querySelector(`#comment-input-${postId}`);
            const commentText = commentInput.value.trim();

            if (commentText === "") {
                alert("댓글을 입력하세요.");
                return;
            }

            fetch("add_comment.jsp", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                body: `post_id=${postId}&comment_text=${encodeURIComponent(commentText)}`,
            })
            .then((response) => response.json())
            .then((data) => {
                if (data.status === "success") {
                    const commentList = document.querySelector(`#comment-list-${postId}`);
                    const newComment = document.createElement("li");
                    newComment.innerHTML = `
                        <div class="comment-header">
                            <img src="circle.png" alt="프로필" class="profile-pic">
                            <span>${data.comment.userId}</span>
                            <span class="comment-date">${new Date(data.comment.commentDate).toLocaleString()}</span>
                        </div>
                        <p>${data.comment.commentText}</p>
                    `;
                    commentList.appendChild(newComment);
                    commentInput.value = "";
                } else {
                    alert(data.message);
                }
            })
            .catch((error) => {
                console.error("Error:", error);
                alert("댓글 추가 중 오류가 발생했습니다.");
            });
        }
    });
});

document.addEventListener("click", (event) => {
    const editLink = event.target.closest(".edit-comment");
    const deleteLink = event.target.closest(".delete-comment");

    if (editLink) {
        event.preventDefault();
        const commentId = editLink.getAttribute("data-comment-id");
        const commentTextElement = document.getElementById(`comment-text-${commentId}`);
        const currentText = commentTextElement.textContent;

        const inputField = document.createElement("textarea");
        inputField.value = currentText;
        inputField.className = "comment-edit-input";

        const saveButton = document.createElement("button");
        saveButton.textContent = "저장";
        saveButton.className = "comment-save-button";

        commentTextElement.replaceWith(inputField);
        inputField.after(saveButton);

        saveButton.addEventListener("click", () => {
            const updatedText = inputField.value.trim();
            if (updatedText === "") {
                alert("댓글을 입력해주세요.");
                return;
            }

            fetch("edit_comment.jsp", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: `comment_id=${commentId}&comment_text=${encodeURIComponent(updatedText)}`
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    const newTextElement = document.createElement("p");
                    newTextElement.id = `comment-text-${commentId}`;
                    newTextElement.textContent = updatedText;

                    inputField.replaceWith(newTextElement);
                    saveButton.remove();
                } else {
                    alert("댓글 수정에 실패했습니다.");
                }
            })
            .catch(error => {
                console.error("Error:", error);
                alert("서버 오류가 발생했습니다.");
            });
        });
    }

    if (deleteLink) {
        event.preventDefault();
        const commentId = deleteLink.getAttribute("data-comment-id");

        if (confirm("정말 삭제하시겠습니까?")) {
            fetch("delete_comment.jsp", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: `comment_id=${commentId}`
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    deleteLink.closest("li").remove();
                } else {
                    alert("댓글 삭제에 실패했습니다.");
                }
            })
            .catch(error => {
                console.error("Error:", error);
                alert("서버 오류가 발생했습니다.");
            });
        }
    }
});

document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.bookmark-checkbox').forEach(function(checkbox) {
        checkbox.addEventListener('change', function() {
            const labelImg = this.parentNode.querySelector('label img.bookmark-icon');
            const postId = this.id.replace('bookmark-', '');
            
            let action = 'add'; 
            if (!this.checked) {
                action = 'remove';
            }

            fetch('toggle_bookmark.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `post_id=${encodeURIComponent(postId)}&action=${encodeURIComponent(action)}`
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    if (action === 'add') {
                        labelImg.src = 'bookmark_filled.png';
                    } else {
                        labelImg.src = 'bookmark.png';
                    }
                } else {
                    alert(data.message || '북마크 처리에 실패했습니다.');
                    // 상태 복원
                    this.checked = (action === 'remove');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('서버 오류가 발생했습니다.');
                // 상태 복원
                this.checked = (action === 'remove');
            });
        });
    });
});
