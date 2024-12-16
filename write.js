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

    newOption.innerHTML = `
      <input type="text" placeholder="항목 입력" name="pollOption[]">
      <input type="file" accept="image/*" style="display: none;" class="file-input">
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
