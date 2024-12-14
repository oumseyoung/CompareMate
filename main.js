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
    // 카테고리 필터링 시 URL 업데이트
    window.history.pushState(null, '', `?category=${category}`);
  });
});

function filterPosts(category) {
  const posts = document.querySelectorAll('.post');
  const contentTitle = document.querySelector('.content h2'); // <h2> 요소 선택

  // 카테고리 이름을 결정
  const categoryNames = {
    all: '전체 게시글',
    electronics: '전자제품',
    fashion: '패션/의류',
    beauty: '뷰티/건강',
    food: '식품/음료',
    household: '생활용품',
    hobby: '취미/여가',
    automotive: '자동차/오토바이',
    others: '기타',
  };

  // <h2> 내용을 업데이트
  contentTitle.textContent = categoryNames[category] || '전체 게시글';

  posts.forEach(post => {
    if (category === 'all') {
      post.style.display = 'block';
    } else {
      const postCategory = post.getAttribute('data-category');
      post.style.display = postCategory === category ? 'block' : 'none';
    }
  });
}

// URL에서 카테고리 파라미터 읽기
function getCategoryFromURL() {
  const params = new URLSearchParams(window.location.search);
  return params.get('category') || 'all'; // 기본값은 'all'
}

// 페이지 로드 시 카테고리 필터 적용
window.addEventListener('load', () => {
  const selectedCategory = getCategoryFromURL();
  filterPosts(selectedCategory); // 기존 filterPosts 함수 재사용
});

// 투표 옵션에 이벤트 리스너 추가 (checkbox와 radio 모두 처리)
const pollOptions = document.querySelectorAll('.poll-option');

pollOptions.forEach(option => {
  const input = option.querySelector('input[type="checkbox"], input[type="radio"]');
  input.addEventListener('change', () => {
    const isRadio = input.type === 'radio'; // 라디오 버튼인지 확인
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
    if (!isLoggedIn) {
      alert("로그인 후에 투표를 진행해주세요.");
      return;
    }

    const postId = voteButton.getAttribute('data-post-id');
    const poll = voteButton.closest('.poll');
    const pollInputs = poll.querySelectorAll('input[type="checkbox"], input[type="radio"]');
    const isMultipleChoice = poll.getAttribute('data-multiple-choice') === 'true';

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

// 팝업 관련 요소 가져오기
const popupImages = document.querySelectorAll('.poll-option-image');
const closePopupButtons = document.querySelectorAll('.close-popup');

// 이미지 클릭 시 팝업 표시
popupImages.forEach(image => {
  image.addEventListener('click', (event) => {
    event.stopPropagation(); // 부모 이벤트 전파 방지
    const pollOption = image.closest('.poll-option');
    const postId = pollOption.closest('.poll').getAttribute('data-post-id');
    const popup = document.getElementById(`image-popup-${postId}`);
    const popupImage = popup.querySelector('.popup-image');

    popupImage.src = image.src; // 클릭한 이미지의 src 설정
    popup.classList.remove('hidden'); // hidden 클래스 제거
    popup.style.display = 'flex'; // 팝업을 flex로 표시
  });
});

// 팝업 닫기 버튼 클릭 시 팝업 숨기기
closePopupButtons.forEach(button => {
  button.addEventListener('click', (event) => {
    event.preventDefault(); // 기본 동작 방지
    event.stopPropagation(); // 이벤트 전파 차단
    const popup = button.closest('.image-popup');
    popup.classList.add('hidden'); // hidden 클래스 추가
    popup.style.display = 'none'; // 팝업 숨기기
    const popupImage = popup.querySelector('.popup-image');
    popupImage.src = ''; // 팝업 이미지 초기화
  });
});

// 팝업 외부 클릭 시 팝업 숨기기
document.querySelectorAll('.image-popup').forEach(popup => {
  popup.addEventListener('click', (event) => {
    if (event.target === popup) {
      popup.classList.add('hidden'); // hidden 클래스 추가
      popup.style.display = 'none'; // 팝업 숨기기
      const popupImage = popup.querySelector('.popup-image');
      popupImage.src = ''; // 팝업 이미지 초기화
    }
  });
});

// 페이지 로드 시 팝업 숨기기
window.addEventListener('load', () => {
  document.querySelectorAll('.image-popup').forEach(popup => {
    if (!popup.classList.contains('hidden')) {
      popup.classList.add('hidden');
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
          const imageElement = option.querySelector('.poll-option-image');
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
        const imageElement = option.querySelector('.poll-option-image');
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

// 댓글 수를 업데이트하는 함수
function updateCommentCount() {
  const commentList = document.getElementById('comment-list');
  const commentCountElement = document.querySelector('.comment-count');
  const commentCount = commentList.children.length; // 댓글 목록의 자식 수 계산
  if (commentCountElement) {
    commentCountElement.textContent = `댓글 ${commentCount}`;
  }
}

// 댓글 추가 로직 수정
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
      updateCommentCount(); // 댓글 수 업데이트
    } else {
      alert('댓글을 입력하세요.');
    }
  });
}

// 페이지 로드 시 초기 댓글 수 설정
window.addEventListener('load', () => {
  updateCommentCount();
});
