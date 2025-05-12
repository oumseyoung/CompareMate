// 알람 레이어의 표시/숨김을 토글하는 함수
function toggleLayer() {
  const layer = document.getElementById("layer");
  layer.classList.toggle("hidden"); // 'hidden' 클래스를 추가하거나 제거하여 표시/숨김 토글
}

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
document.addEventListener("DOMContentLoaded", fetchAlerts);

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
document.addEventListener("DOMContentLoaded", fetchAlerts);

// 사이드바 카테고리 클릭 이벤트
document.querySelectorAll('.side ul li a').forEach(link => {
  link.addEventListener('click', (event) => {
      event.preventDefault(); // 기본 링크 동작 방지
      const category = link.getAttribute('data-category');
      // main.jsp로 이동하면서 카테고리를 URL에 포함 (필요시 수정)
      window.location.href = `main.jsp?category=${category}`;
  });
});

// 페이지 로드 시 초기화
document.addEventListener("DOMContentLoaded", () => {
  const editProfileBtn = document.getElementById("edit-profile");
  const nicknameElement = document.getElementById("nickname");
  const nicknameInput = document.getElementById("nickname-input");
  const profileImage = document.getElementById("profile-image");
  const cameraIcon = document.getElementById("camera-icon");
  const cameraDiv = document.getElementById("camera");
  const fileInput = document.getElementById("file-input");
  const interestList = document.getElementById("interest-list");
  const interestEditSection = document.getElementById("interest-edit");
  const saveProfileBtn = document.getElementById("save-profile");

  // 프로필 수정 버튼 클릭 이벤트
  editProfileBtn.addEventListener("click", () => {
    nicknameElement.classList.add("hidden");
    nicknameInput.classList.remove("hidden");
    cameraDiv.classList.remove("hidden");
    interestEditSection.classList.remove("hidden");

    // 기존 관심분야를 체크박스에 반영
    const originalInterests = interestList.textContent.trim();
    originalInterests.split(",").map(i => i.trim()).forEach(i => {
      const checkbox = document.querySelector(`#interest-form input[value="${i}"]`);
      if (checkbox) {
        checkbox.checked = true;
      }
    });
  });

  // 카메라 이미지를 클릭해서 파일 첨부 열기
  cameraIcon.addEventListener("click", () => {
    fileInput.click();
  });

  // 파일 선택 시 프로필 이미지 미리보기
  fileInput.addEventListener("change", (event) => {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        profileImage.src = e.target.result; // 미리보기
        window.profileImageBase64 = e.target.result; // 전체 Base64 데이터
      };
      reader.readAsDataURL(file);
    }
  });

  // 확인 버튼 클릭 이벤트 (AJAX로 update_user_info.jsp 호출)
   saveProfileBtn.addEventListener("click", () => {
     const newNickname = nicknameInput.value.trim();
     const selectedInterests = Array.from(
       document.querySelectorAll("#interest-form input:checked")
     ).map((checkbox) => checkbox.value);
     const newInterests = selectedInterests.join(", ");
     const profileImageBase64 = window.profileImageBase64 || "";

     fetch("update_user_info.jsp", {
       method: "POST",
       headers: {
         "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
       },
       body: `nickname=${encodeURIComponent(newNickname)}&interests=${encodeURIComponent(newInterests)}&profileImage=${encodeURIComponent(profileImageBase64)}`
     })
       .then((response) => response.json())
       .then((data) => {
         if (data.status === "success") {
           alert("정보가 업데이트되었습니다.");
           window.location.reload();
         } else {
           alert("업데이트 실패: " + data.message);
         }
       })
       .catch((error) => {
         console.error(error);
         alert("서버 오류 발생");
       });
   });

  
});

// 팝업 관련 요소 가져오기
const popup = document.getElementById("image-popup");
if (popup) {
  const popupImage = document.getElementById("popup-image");
  const closePopupButton = document.getElementById("close-popup");
  const clickableImages = document.querySelectorAll('.poll-option img');

  // 이미지 클릭 시 팝업 표시
  clickableImages.forEach((image) => {
    image.addEventListener("click", (event) => {
      popupImage.src = image.src; // 클릭한 이미지의 src를 팝업에 설정
      popup.classList.remove("hidden"); // hidden 클래스 제거
      popup.style.display = "flex"; // 팝업 표시
    });
  });

  // 닫기 버튼 클릭 시 팝업 숨기기
  closePopupButton.addEventListener("click", () => {
    closePopup(); // 팝업 닫기 함수 호출
  });

  // 팝업 외부 클릭 시 팝업 숨기기
  popup.addEventListener("click", (event) => {
    if (event.target === popup) {
      closePopup(); // 팝업 닫기 함수 호출
    }
  });

  // 팝업 닫기 함수
  function closePopup() {
    popup.classList.add("hidden"); // hidden 클래스 추가
    popup.style.display = "none"; // 팝업 숨기기
    popupImage.src = ""; // 팝업 이미지 초기화
  }

  // 페이지 로드 시 팝업 숨기기
  window.addEventListener("load", () => {
    if (!popup.classList.contains("hidden")) {
      popup.classList.add("hidden");
      popup.style.display = "none";
    }
  });
}

// 북마크 체크박스와 아이콘을 동기화 및 상태 저장/불러오기
const bookmarkCheckboxes = document.querySelectorAll('.bookmark-checkbox');

bookmarkCheckboxes.forEach(checkbox => {
  const label = checkbox.nextElementSibling;
  const icon = label.querySelector('.bookmark-icon');
  const postId = checkbox.closest('.post').getAttribute('data-post-id');

  // 로컬 스토리지에서 북마크 상태 불러오기
  if (localStorage.getItem(`bookmark-${postId}`) === 'true') {
    checkbox.checked = true;
    icon.src = 'bookmark_filled.png';
  }

  // 체크박스 상태 변경 시 로컬 스토리지에 저장
  checkbox.addEventListener('change', () => {
    if (checkbox.checked) {
      icon.src = 'bookmark_filled.png'; // 체크 시 아이콘 변경
      localStorage.setItem(`bookmark-${postId}`, 'true');
    } else {
      icon.src = 'bookmark.png'; // 체크 해제 시 아이콘 변경
      localStorage.setItem(`bookmark-${postId}`, 'false');
    }
  });
});

// 투표 옵션에 이벤트 리스너 추가 (checkbox와 radio 모두 처리)
const pollOptions = document.querySelectorAll('.poll-option');

pollOptions.forEach(option => {
  const input = option.querySelector('input[type="checkbox"], input[type="radio"]');
  input.addEventListener('change', () => {
    const isRadio = input.type === 'radio';
    if (input.checked) {
      option.classList.add('checked');
      if (isRadio) {
        // 라디오 버튼인 경우, 동일한 그룹의 다른 옵션을 해제
        const name = input.name;
        const inputsInGroup = document.querySelectorAll(`input[name="${name}"]`);
        inputsInGroup.forEach(otherInput => {
          if (otherInput !== input) {
            otherInput.checked = false;
            const otherOption = otherInput.closest('.poll-option');
            otherOption.classList.remove('checked');
          }
        });
      }
    } else {
      option.classList.remove('checked');
    }
  });
});

// 투표 버튼에 이벤트 리스너 추가 (로컬 스토리지 저장)
document.querySelectorAll('button.vote-button').forEach(voteButton => {
  voteButton.addEventListener('click', () => {
    const postId = voteButton.getAttribute('data-post-id');
    const poll = voteButton.closest('.poll');
    const pollInputs = poll.querySelectorAll('input[type="checkbox"], input[type="radio"]');

    // 체크된 항목이 있는지 확인
    const selectedOptions = Array.from(pollInputs)
      .filter(input => input.checked)
      .map(input => input.value);

    if (selectedOptions.length > 0) {
      // 기존의 투표 데이터를 로드
      let voteData = JSON.parse(localStorage.getItem(`vote-${postId}`)) || {};

      // 각 항목별 투표 수 업데이트
      selectedOptions.forEach(option => {
        voteData[option] = (voteData[option] || 0) + 1;
      });

      // 투표 결과 저장
      localStorage.setItem(`vote-${postId}`, JSON.stringify(voteData));

      alert('투표가 완료되었습니다!');

      // 투표 완료 후 UI 업데이트
      updateVoteUI(postId);
    } else {
      alert('항목을 선택해주세요.');
    }
  });
});

// 투표 결과 로드 및 UI 업데이트 함수
function loadVotes() {
  document.querySelectorAll('.poll').forEach(poll => {
    const postId = poll.getAttribute('data-post-id');
    const voteData = JSON.parse(localStorage.getItem(`vote-${postId}`));

    if (voteData) {
      const voteButton = poll.querySelector('button.vote-button');
      const pollOptions = poll.querySelectorAll('.poll-option');

      voteButton.disabled = true;
      voteButton.textContent = '이미 투표한 게시글입니다';

      pollOptions.forEach(option => {
        const input = option.querySelector('input[type="checkbox"], input[type="radio"]');
        input.disabled = true;
        option.classList.add('disabled');

        const optionValue = input.value;
        const voteCount = voteData[optionValue] || 0;

        let voteCountSpan = option.querySelector('.vote-count');
        if (!voteCountSpan) {
          voteCountSpan = document.createElement('span');
          voteCountSpan.className = 'vote-count';
          voteCountSpan.style.marginRight = '10px';
          voteCountSpan.style.fontSize = '14px';
          voteCountSpan.style.color = '#555';
          const imageElement = option.querySelector('img');
          option.insertBefore(voteCountSpan, imageElement);
        }
        voteCountSpan.textContent = `(${voteCount}표)`;
      });
    }
  });
}

function updateVoteUI(postId) {
  const poll = document.querySelector(`.poll[data-post-id="${postId}"]`);
  const voteButton = poll.querySelector('button.vote-button');
  const pollOptions = poll.querySelectorAll('.poll-option');

  const voteData = JSON.parse(localStorage.getItem(`vote-${postId}`));

  if (voteData) {
    voteButton.disabled = true;
    voteButton.textContent = '이미 투표한 게시글입니다';

    pollOptions.forEach(option => {
      const input = option.querySelector('input[type="checkbox"], input[type="radio"]');
      input.disabled = true;
      option.classList.add('disabled');

      const optionValue = input.value;
      const voteCount = voteData[optionValue] || 0;

      let voteCountSpan = option.querySelector('.vote-count');
      if (!voteCountSpan) {
        voteCountSpan = document.createElement('span');
        voteCountSpan.className = 'vote-count';
        voteCountSpan.style.marginRight = '10px';
        voteCountSpan.style.fontSize = '14px';
        voteCountSpan.style.color = '#555';
        const imageElement = option.querySelector('img');
        option.insertBefore(voteCountSpan, imageElement);
      }
      voteCountSpan.textContent = `(${voteCount}표)`;
    });
  }
}

// 페이지 로드 시 투표 결과 로드
window.addEventListener('load', () => {
  loadVotes();
});


/* -----------------------------------------
 * 게시글 삭제 기능
 * ----------------------------------------- */
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




// 댓글 개수 업데이트 함수
function updateCommentCount(postId, count) {
    const commentCountElement = document.querySelector(`#comments-section-${postId} .comment-count`);
    if (commentCountElement) {
        commentCountElement.textContent = `댓글 ${count}`;
    }
}

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
