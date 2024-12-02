// 알람 레이어의 표시/숨김을 토글하는 함수
function toggleLayer() {
  const layer = document.getElementById("layer");
  layer.classList.toggle("hidden"); // 'hidden' 클래스를 추가하거나 제거하여 표시/숨김 토글
}

// 알람 추가 함수
function addAlert(message, imageUrl) {
  const alertList = document.getElementById("alert-list");

  // 새로운 알람 항목 생성
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

  // 알람을 목록의 맨 위에 추가
  alertList.insertBefore(newAlert, alertList.firstChild);
}
function clearAlerts() {
  const alertList = document.getElementById("alert-list");
  alertList.innerHTML = ""; // 알람 목록을 비움
  alertCounter = 0; // 알람 카운터 초기화
}

// 5초마다 무작위로 메시지를 추가
setInterval(() => {
  const messages = [
    { text: "게시물에 댓글이 달렸습니다.", image: "circle.png" },
    { text: "투표가 종료되었습니다.", image: "circle.png" },
  ];

  // 메시지 중 하나를 무작위로 선택
  const randomMessage = messages[Math.floor(Math.random() * messages.length)];

  addAlert(randomMessage.text, randomMessage.image);
}, 5000); // 5초마다 알람 추가

// 사이드바 카테고리 클릭 이벤트
document.querySelectorAll('.side ul li a').forEach(link => {
  link.addEventListener('click', (event) => {
      event.preventDefault(); // 기본 링크 동작 방지
      const category = link.getAttribute('data-category');
      // main.html로 이동하면서 카테고리를 URL에 포함
      window.location.href = `main.html?category=${category}`;
  });
});

/* -----------------------------------------
 * 프로필 수정 기능
 * ----------------------------------------- */
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
        profileImage.src = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  });

  // 확인 버튼 클릭 이벤트
  saveProfileBtn.addEventListener("click", () => {
    const newNickname = nicknameInput.value.trim();
    if (newNickname) {
      nicknameElement.textContent = newNickname;
    }

    // 관심분야 저장
    const selectedInterests = Array.from(
      document.querySelectorAll("#interest-form input:checked")
    ).map((checkbox) => checkbox.value);
    interestList.textContent = selectedInterests.join(", ");

    // 수정 UI 숨기기
    nicknameInput.classList.add("hidden");
    nicknameElement.classList.remove("hidden");
    cameraDiv.classList.add("hidden");
    interestEditSection.classList.add("hidden");
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
        const postElement = event.target.closest(".post");
        const menuPopup = postElement.querySelector(".menu-popup");

        const confirmation = confirm("정말 삭제하시겠습니까?");
        if (confirmation) {
          postElement.remove();
        } else {
          menuPopup.classList.add("hidden");
        }
      });
    });
  };

  // 삭제 버튼 초기화
  initializeDeleteButtons();
});

// 팝업 관련 요소 가져오기
const popup = document.getElementById('image-popup');
const popupImage = document.getElementById('popup-image');
const closePopupButton = document.getElementById('close-popup');
const clickableImages = document.querySelectorAll('.poll-option img');

// 이미지 클릭 시 팝업 표시
clickableImages.forEach(image => {
  image.addEventListener('click', (event) => {
    event.stopPropagation(); // 부모 이벤트 전파 방지
    popupImage.src = image.src; // 클릭한 이미지의 src 설정
    popup.classList.remove('hidden'); // hidden 클래스 제거
    popup.style.display = 'flex'; // 팝업을 flex로 표시
  });
});

// 팝업 닫기 버튼 클릭 시 팝업 숨기기
closePopupButton.addEventListener('click', (event) => {
  event.preventDefault(); // 기본 동작 방지
  event.stopPropagation(); // 이벤트 전파 차단
  popup.classList.add('hidden'); // hidden 클래스 추가
  popup.style.display = 'none'; // 팝업 숨기기
  popupImage.src = ''; // 팝업 이미지 초기화
});

// 팝업 외부 클릭 시 팝업 숨기기
popup.addEventListener('click', (event) => {
  if (event.target === popup) {
    popup.classList.add('hidden'); // hidden 클래스 추가
    popup.style.display = 'none'; // 팝업 숨기기
    popupImage.src = ''; // 팝업 이미지 초기화
  }
});

// 팝업 닫기 함수
function closePopup() {
  popup.classList.add("hidden"); // hidden 클래스 추가
  popup.style.display = "none"; // 팝업 숨기기
  popupImage.src = ""; // 팝업 이미지 초기화
}

// 페이지 로드 시 팝업 숨기기
window.addEventListener('load', () => {
  const popup = document.getElementById('image-popup');
  if (!popup.classList.contains('hidden')) {
    popup.classList.add('hidden');
  }
});

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
    const isRadio = input.type === 'radio'; // 여기서 isRadio 변수 정의
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

// 투표 버튼에 이벤트 리스너 추가
document.querySelectorAll('button.vote-button').forEach(voteButton => {
  voteButton.addEventListener('click', () => {
    const postId = voteButton.getAttribute('data-post-id');
    const poll = voteButton.closest('.poll');
    const pollOptions = poll.querySelectorAll('input[type="checkbox"], input[type="radio"]');
    const isMultipleChoice = poll.getAttribute('data-multiple-choice') === 'true';

    // 체크된 항목이 있는지 확인
    const selectedOptions = Array.from(pollOptions)
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

// 투표 결과 로드 및 UI 업데이트 함수 수정
function loadVotes() {
  document.querySelectorAll('.poll').forEach(poll => {
    const postId = poll.getAttribute('data-post-id');
    const voteData = JSON.parse(localStorage.getItem(`vote-${postId}`));

    if (voteData) {
      const voteButton = poll.querySelector('button.vote-button');
      const pollOptions = poll.querySelectorAll('.poll-option');

      voteButton.disabled = true;
      voteButton.textContent = '이미 투표한 게시글입니다';

      // poll-option 업데이트
      pollOptions.forEach(option => {
        const input = option.querySelector('input[type="checkbox"], input[type="radio"]');
        input.disabled = true;
        option.classList.add('disabled');

        const optionValue = input.value;
        const voteCount = voteData[optionValue] || 0;

        // 투표 수를 표시할 span 추가
        let voteCountSpan = option.querySelector('.vote-count');
        if (!voteCountSpan) {
          voteCountSpan = document.createElement('span');
          voteCountSpan.className = 'vote-count';
          voteCountSpan.style.marginRight = '10px';
          voteCountSpan.style.fontSize = '14px';
          voteCountSpan.style.color = '#555';
          // 이미지 요소를 선택
          const imageElement = option.querySelector('img');
          // 투표 수를 이미지 왼쪽에 삽입
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

      // 투표 수를 표시할 span 추가
      let voteCountSpan = option.querySelector('.vote-count');
      if (!voteCountSpan) {
        voteCountSpan = document.createElement('span');
        voteCountSpan.className = 'vote-count';
        voteCountSpan.style.marginRight = '10px';
        voteCountSpan.style.fontSize = '14px';
        voteCountSpan.style.color = '#555';
        // 이미지 요소를 선택
        const imageElement = option.querySelector('img');
        // 투표 수를 이미지 왼쪽에 삽입
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