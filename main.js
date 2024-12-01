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

// 사이드바 카테고리 링크 선택
const categoryLinks = document.querySelectorAll('.side ul li a');

categoryLinks.forEach(link => {
  link.addEventListener('click', (event) => {
    event.preventDefault();
    const category = link.getAttribute('data-category');
    filterPosts(category);
  });
});

function filterPosts(category) {
  const posts = document.querySelectorAll('.post');

  posts.forEach(post => {
    if (category === 'all') {
      post.style.display = 'block';
    } else {
      const postCategory = post.getAttribute('data-category'); // 각 포스트에 data-category 속성 추가 필요
      if (postCategory === category) {
        post.style.display = 'block';
      } else {
        post.style.display = 'none';
      }
    }
  });
}

// 모든 poll-option 요소를 선택합니다.
const pollOptions = document.querySelectorAll('.poll-option');

pollOptions.forEach(option => {
  const checkbox = option.querySelector('input[type="checkbox"]');
  checkbox.addEventListener('change', () => {
    if (checkbox.checked) {
      option.classList.add('checked');
    } else {
      option.classList.remove('checked');
    }
  });
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

// 페이지 로드 후 URL에 '#comment-section'이 있는지 확인
window.addEventListener('load', () => {
  if (window.location.hash === '#comment-section') {
    const commentInput = document.getElementById('comment-input');
    if (commentInput) {
      commentInput.focus(); // 댓글 입력 필드에 포커스
    }
  }
});

// 투표 버튼에 이벤트 리스너 추가
document.querySelectorAll('button.vote-button').forEach(voteButton => {
  voteButton.addEventListener('click', () => {
    const postId = voteButton.getAttribute('data-post-id');
    const poll = voteButton.closest('.poll');
    const pollOptions = poll.querySelectorAll('input[type="checkbox"]');

    // 체크된 항목이 있는지 확인
    const selectedOptions = Array.from(pollOptions)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value);

    if (selectedOptions.length > 0) {
      // 투표 결과 저장
      localStorage.setItem(`vote-${postId}`, JSON.stringify(selectedOptions));

      alert('투표가 완료되었습니다!');

      // 투표 완료 후 UI 업데이트
      updateVoteUI(postId);
    } else {
      alert('항목을 선택해주세요.');
    }
  });
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

// 페이지 로드 시 팝업 숨기기
window.addEventListener('load', () => {
  const popup = document.getElementById('image-popup');
  if (!popup.classList.contains('hidden')) {
    popup.classList.add('hidden');
  }
});
