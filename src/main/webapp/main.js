// main.js

// 알람 레이어의 표시/숨김
function toggleLayer() {
    const layer = document.getElementById("layer");
    layer.classList.toggle("hidden");
}

// 알람 추가 함수
function fetchAlerts() {
	fetch("fetch_alerts.jsp")
	    .then(response => response.json())
	    .then(data => {
	        const alertList = document.getElementById("alert-list");
	        alertList.innerHTML = ""; // 기존 알림 제거

	        if (data.alerts && data.alerts.length > 0) {
	            data.alerts.forEach(alert => {
	                const alertItem = document.createElement("li");
	                alertItem.className = "alert-item";
	                alertItem.innerHTML = `
	                    <a href="#">
	                        <span>${alert.message}</span>
	                    </a>
	                `;
	                alertList.appendChild(alertItem);
	            });
	        } else {
	            alertList.innerHTML = "<li>알림이 없습니다.</li>";
	        }
	    })
	    .catch(error => {
	        console.error("Error fetching alerts:", error);
	    });
}

// 페이지 로드 시 알림 불러오기
document.addEventListener("DOMContentLoaded", () => {
    fetchAlerts();
    setInterval(fetchAlerts, 10000); // 1분마다 알림 갱신
});


// 알람 비우기
function clearAlerts() {
    fetch('clear_alerts.jsp', { method: 'POST' })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                alert('알림이 삭제되었습니다.');
                location.reload(); // 페이지 새로고침
            } else {
                alert(data.message);
            }
        })
        .catch(error => console.error('Error:', error));
}

document.addEventListener("DOMContentLoaded", fetchAlerts);


// 카테고리 업데이트 함수
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

// 카테고리 가져오기
function getCategoryFromURL() {
    const params = new URLSearchParams(window.location.search);
    return params.get('category') || '전체 게시글';
}

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
    if (poll) {
        const pollInputs = poll.querySelectorAll('.poll-option input');
        pollInputs.forEach(option => {
            option.disabled = true;
        });

        const voteButton = poll.querySelector('.vote-button');
        if (voteButton) {
            voteButton.disabled = true;
            voteButton.textContent = '투표 완료';
        }
    }
}

// 투표 상태에 따라 가장 높은 투표수를 가진 옵션을 강조하는 함수
function highlightHighestVotedOptions(postId, voteResults) {
    const poll = document.querySelector(`.poll[data-post-id="${postId}"]`);
    if (!poll) return;

    // 가장 높은 투표 수 찾기
    let maxVotes = 0;
    voteResults.forEach(option => {
        if (option.voteCount > maxVotes) {
            maxVotes = option.voteCount;
        }
    });

    // 가장 높은 투표 수를 가진 모든 옵션에 강조 클래스 추가
    poll.querySelectorAll('.poll-option').forEach(option => {
        const optionId = option.querySelector('input').value;
        const correspondingOption = voteResults.find(o => o.optionId == optionId);
        if (correspondingOption && correspondingOption.voteCount === maxVotes) {
            option.classList.add('highlight');
        } else {
            option.classList.remove('highlight');
        }
    });
}

// 투표 UI 업데이트 함수
function updateVoteUI(postId, results) {
    const poll = document.querySelector(`.poll[data-post-id="${postId}"]`);
    if (!poll) return;

    const pollOptions = poll.querySelectorAll('.poll-option');

    pollOptions.forEach(option => {
        const input = option.querySelector('input');
        const optionId = input.value;
        const result = results.find(r => r.optionId == optionId);

        let voteCountSpan = option.querySelector('.vote-count');
        if (!voteCountSpan) {
            voteCountSpan = document.createElement('span');
            voteCountSpan.className = 'vote-count';
            option.appendChild(voteCountSpan);
        }
        voteCountSpan.textContent = `(${result ? result.voteCount : 0}표)`;
    });

    // 가장 높은 투표수를 가진 옵션 강조
    highlightHighestVotedOptions(postId, results);
}

// 댓글 개수 업데이트 함수
function updateCommentCount(postId, count) {
    const commentCountElement = document.querySelector(`#comments-section-${postId} .comment-count`);
    if (commentCountElement) {
        commentCountElement.textContent = `댓글 ${count}`;
    }
}

// 투표 옵션의 시각적 상태를 업데이트하는 함수
function updatePollOptionSelection(poll) {
    const inputs = poll.querySelectorAll('input[type="checkbox"], input[type="radio"]');
    inputs.forEach(input => {
        const pollOption = input.closest('.poll-option');
        if (input.checked) {
            pollOption.classList.add('checked');
        } else {
            pollOption.classList.remove('checked');
        }
    });
}

// 투표 입력 변경 시 시각적 표시를 업데이트하는 이벤트 리스너
document.addEventListener('change', function(event) {
    const input = event.target.closest('input[type="checkbox"], input[type="radio"]');
    if (input) {
        const poll = input.closest('.poll');
        if (poll) {
            updatePollOptionSelection(poll);
        }
    }
});

// 이미지 팝업 처리 함수
function handleImagePopup() {
    const popup = document.getElementById('image-popup');
    const popupImage = popup.querySelector('.popup-image');
    const closePopupButton = popup.querySelector('.close-popup');

    // 이미지 클릭 이벤트 위임
    document.addEventListener('click', function(event) {
        const img = event.target.closest('.poll-option-image');
        if (img) {
            const actualImageUrl = img.getAttribute('data-actual-image-url');
            if (actualImageUrl) {
                popupImage.src = actualImageUrl;
                popup.classList.remove('hidden');
                document.body.classList.add('no-scroll'); // 배경 스크롤 방지
            } else {
                alert('이미지가 없습니다.');
            }
            // 이벤트 전파 중단 및 기본 동작 방지
            event.preventDefault();
            event.stopPropagation();
        }

        // 팝업 닫기 버튼 클릭 처리
        if (event.target.closest('.close-popup')) {
            popup.classList.add('hidden');
            popupImage.src = '';
            document.body.classList.remove('no-scroll'); // 스크롤 복원
        }
    });

    // Esc 키로 팝업 닫기
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape' && !popup.classList.contains('hidden')) {
            popup.classList.add('hidden');
            popupImage.src = '';
            document.body.classList.remove('no-scroll');
        }
    });
}

// 페이지 로드 시 실행되는 초기화 함수
window.addEventListener('load', () => {
	
	
    const selectedCategory = getCategoryFromURL();
    updateContentTitle(selectedCategory);
    highlightSelectedCategoryByCategory(selectedCategory);

    // 투표 옵션 시각적 선택 상태 초기화
    const polls = document.querySelectorAll('.poll');
    polls.forEach(poll => {
        updatePollOptionSelection(poll);
    });

    // 투표 상태에 따른 UI 업데이트
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
                    appendVotingClosedText(post, postId);
                } else {
                    const timeRemaining = endDateTime - currentTime;
                    setTimeout(() => {
                        appendVotingClosedText(post, postId);
                    }, timeRemaining);
                }
            }

            // 서버 측 투표 상태 확인 및 로컬 스토리지 동기화
            if (postData.hasVoted) {
                localStorage.setItem(`voted_post_${postId}`, 'true');
            }

            if (postData.hasVoted || localStorage.getItem(`voted_post_${postId}`) === 'true') {
                highlightHighestVotedOptions(postId, postData.voteResults);
                // 이미 투표한 경우 투표 버튼 비활성화
                const voteButton = post.querySelector('.vote-button');
                
                    voteButton.textContent = '투표 완료'; // 버튼 텍스트 변경
                
            }
        }
    });

    // 이미지 팝업 처리 초기화
    handleImagePopup();
});

// 이벤트 위임을 활용한 이벤트 핸들러 등록
document.addEventListener('click', (event) => {
    // 댓글 버튼 클릭 이벤트
    const commentButton = event.target.closest('.comment-button');
    if (commentButton) {
        event.preventDefault();
        const postId = commentButton.getAttribute('data-post-id');
        document.getElementById(`comments-section-${postId}`).classList.toggle('hidden');
        return;
    }

    // 댓글 추가 버튼 클릭 이벤트
    const addCommentButton = event.target.closest('.add-comment-button');
    if (addCommentButton) {
        event.preventDefault();
        const postId = addCommentButton.getAttribute('data-post-id');
        const commentInput = document.getElementById(`comment-input-${postId}`);
        const commentText = commentInput.value.trim();

        if (!commentText) {
            alert('댓글을 입력해주세요.');
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
                            <img src="${data.comment.profileImage || 'circle.png'}" alt="프로필" class="profile-pic">
                            <span style="font-size:10px;">${data.comment.userId}</span>
                        </div>
                        <p id="comment-text-${data.comment.commentId}">${data.comment.commentText}</p>
                        ${data.comment.userId === data.currentUserId ? `
                        <div class="comment-actions">
                            <a href="#" class="edit-comment" data-comment-id="${data.comment.commentId}">수정</a> |
                            <a href="#" class="delete-comment" data-comment-id="${data.comment.commentId}">삭제</a>
                        </div>` : ''}
                    `;
                    commentList.appendChild(newComment);
                    commentInput.value = "";
                    updateCommentCount(postId, data.comment.count);
                    alert('댓글이 추가되었습니다.');
                } else {
                    alert(data.message || '댓글 추가 실패');
                }
            })
            .catch((error) => {
                console.error("Error:", error);
                alert("댓글 추가 중 오류가 발생했습니다.");
            });
        return;
    }

    // 투표 버튼 클릭 이벤트
    const voteButton = event.target.closest('.vote-button');
    if (voteButton) {
        event.preventDefault();

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

                        // 투표 버튼 비활성화
                        voteButton.disabled = true;
                        voteButton.textContent = '투표 완료';

                        // 투표 상태를 localStorage에 저장
                        localStorage.setItem(`voted_post_${postId}`, 'true');

                        // 투표 결과 UI 업데이트
                        updateVoteUI(postId, data.results);
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
        return;
    }

    // 댓글 수정 버튼 클릭 이벤트
    const editLink = event.target.closest(".edit-comment");
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
        return;
    }

    // 댓글 삭제 버튼 클릭 이벤트
    const deleteLink = event.target.closest(".delete-comment");
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
                        const postId = data.postId;
                        deleteLink.closest("li").remove();
                        // 댓글 개수 업데이트
                        updateCommentCount(postId, data.newCount);
                    } else {
                        alert("댓글 삭제에 실패했습니다.");
                    }
                })
                .catch(error => {
                    console.error("Error:", error);
                    alert("서버 오류가 발생했습니다.");
                });
        }
        return;
    }
});

// 이벤트 위임을 활용한 북마크 처리
document.addEventListener('change', function(event) {
    const checkbox = event.target.closest('.bookmark-checkbox');
    if (checkbox) {
        const labelImg = checkbox.parentNode.querySelector('label img.bookmark-icon');
        const postId = checkbox.id.replace('bookmark-', '');

        let action = 'add'; 
        if (!checkbox.checked) {
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
                    checkbox.checked = (action === 'remove');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('서버 오류가 발생했습니다.');
                // 상태 복원
                checkbox.checked = (action === 'remove');
            });
    }
});


const initializeDeleteButtons = () => {
    document.querySelectorAll(".menu-icon").forEach((menuIcon) => {
        menuIcon.addEventListener("click", (event) => {
            const postElement = event.target.closest(".post");
            const menuPopup = postElement.querySelector(".menu-popup");
            menuPopup.classList.toggle("hidden");
        });
    });

    document.querySelectorAll(".delete-post-btn").forEach((deleteBtn) => {
        deleteBtn.addEventListener("click", (event) => {
            event.preventDefault(); // 기본 동작 방지
            const postElement = event.target.closest(".post");
            const menuPopup = event.target.closest(".menu-popup");
            const postId = postElement.getAttribute("data-post-id");

            const confirmation = confirm("정말 삭제하시겠습니까?");
            if (confirmation) {
                // 서버에 삭제 요청 보내기
                fetch('delete_post', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `post_id=${encodeURIComponent(postId)}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.status === "success") {
                        alert(data.message);
                        // 삭제된 게시글을 DOM에서 제거
                        postElement.remove();
                    } else {
                        alert(data.message || "게시글 삭제에 실패했습니다.");
                    }
                })
                .catch(error => {
                    console.error("Error:", error);
                    alert("게시글 삭제 중 오류가 발생했습니다.");
                });
            } else {
                menuPopup.classList.add("hidden");
            }
        });
    });
};

// 페이지 로드 시 삭제 버튼 초기화 함수 호출
document.addEventListener("DOMContentLoaded", initializeDeleteButtons);
