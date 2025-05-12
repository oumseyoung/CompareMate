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
      // main.html로 이동하면서 카테고리를 URL에 포함
      window.location.href = `main.html?category=${category}`;
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

