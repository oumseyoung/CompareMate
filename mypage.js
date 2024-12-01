document.addEventListener("DOMContentLoaded", () => {
  /* -----------------------------------------
   * 알람 레이어의 표시/숨김
   * ----------------------------------------- */
  const toggleLayer = () => {
    const layer = document.getElementById("layer");
    layer.classList.toggle("hidden"); // 'hidden' 클래스를 추가하거나 제거하여 표시/숨김 토글
  };

  // 알람 추가 함수
  const addAlert = (message, imageUrl) => {
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
  };

  // 알람 초기화 함수
  const clearAlerts = () => {
    const alertList = document.getElementById("alert-list");
    alertList.innerHTML = ""; // 알람 목록을 비움
  };

  // 5초마다 무작위 메시지를 추가
  setInterval(() => {
    const messages = [
      { text: "게시물에 댓글이 달렸습니다.", image: "circle.png" },
      { text: "투표가 종료되었습니다.", image: "circle.png" },
    ];
    const randomMessage = messages[Math.floor(Math.random() * messages.length)];
    addAlert(randomMessage.text, randomMessage.image);
  }, 5000);

  /* -----------------------------------------
   * 프로필 수정 기능
   * ----------------------------------------- */
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
const popup = document.getElementById("image-popup");
const popupImage = document.getElementById("popup-image");
const closePopupButton = document.getElementById("close-popup");
const clickableImages = document.querySelectorAll(".clickable-image");

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
