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

document.addEventListener("DOMContentLoaded", function () {

  // 기존 항목의 이벤트 리스너 추가 (이미지 업로드 관련 기존 코드)
  const existingUploadTriggers = document.querySelectorAll(".upload-trigger");
  existingUploadTriggers.forEach((uploadTrigger) => {
    const fileInput = uploadTrigger.previousElementSibling; // 바로 이전 요소인 input[type="file"]
    addImagePreviewEvent(fileInput, uploadTrigger);
  });

  // '항목 추가' 버튼 이벤트 리스너 (이미지 업로드 관련 기존 코드)
  const pollOptionsContainer = document.querySelector(".poll-options");
  const addOptionButton = document.querySelector(".add-option");

  addOptionButton.addEventListener("click", function () {
    const newOption = document.createElement("div");
    newOption.className = "poll-option";

    // 고유한 이름을 부여하기 위해 배열 표기법 사용
    newOption.innerHTML = `
      <input type="text" placeholder="항목 입력" name="pollOption[]">
      <input type="file" accept="image/*" style="display: none;" name="pollOptionImage[]" class="file-input">
      <img src="image.png" alt="이미지 추가" class="upload-trigger">
    `;

    pollOptionsContainer.insertBefore(newOption, addOptionButton);

    // 새로 추가된 항목의 이벤트 리스너 추가
    const fileInput = newOption.querySelector(".file-input");
    const uploadTrigger = newOption.querySelector(".upload-trigger");
    addImagePreviewEvent(fileInput, uploadTrigger);
  });

  // 이미지 미리보기 및 삭제 기능 함수 (이미지 업로드 관련 기존 코드)
  function addImagePreviewEvent(fileInput, uploadTrigger) {
    let isImageUploaded = false; // 업로드 상태 추적

    uploadTrigger.addEventListener("click", function () {
      if (isImageUploaded) {
        const deleteConfirm = confirm("이미지를 삭제하시겠습니까?");
        if (deleteConfirm) {
          uploadTrigger.src = "image.png";
          isImageUploaded = false;
          fileInput.value = "";
        }
      } else {
        fileInput.click();
      }
    });

    fileInput.addEventListener("change", function () {
      if (fileInput.files.length > 0) {
        const file = fileInput.files[0];

        const reader = new FileReader();
        reader.onload = function (e) {
          uploadTrigger.src = e.target.result;
          isImageUploaded = true;
        };
        reader.readAsDataURL(file);
      }
    });
  }
});
