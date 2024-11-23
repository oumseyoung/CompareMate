document.addEventListener("DOMContentLoaded", function () {
    const endDateInput = document.getElementById("end-date");
    const endTimeInput = document.getElementById("end-time");

    const now = new Date();
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const yyyy = tomorrow.getFullYear();
    const mm = String(tomorrow.getMonth() + 1).padStart(2, "0");
    const dd = String(tomorrow.getDate()).padStart(2, "0");
    const hh = String(tomorrow.getHours()).padStart(2, "0");
    const min = String(tomorrow.getMinutes()).padStart(2, "0");

    endDateInput.value = `${yyyy}-${mm}-${dd}`;
    endTimeInput.value = `${hh}:${min}`;

    // 기존 항목의 이벤트 리스너 추가
    const existingUploadTriggers = document.querySelectorAll(".upload-trigger");
    existingUploadTriggers.forEach((uploadTrigger) => {
        const fileInput = uploadTrigger.previousElementSibling; // 바로 이전 요소인 input[type="file"]
        addImagePreviewEvent(fileInput, uploadTrigger);
    });

    // 새로 추가된 항목의 이벤트 리스너 추가
    const pollOptionsContainer = document.querySelector(".poll-options");
    const addOptionButton = document.querySelector(".add-option");

    addOptionButton.addEventListener("click", function () {
        const newOption = document.createElement("div");
        newOption.className = "poll-option";

        newOption.innerHTML = `
            <input type="text" placeholder="항목 입력">
            <input type="file" accept="image/*" style="display: none;" class="file-input">
            <img src="image.png" alt="이미지 추가" class="upload-trigger">
        `;

        pollOptionsContainer.insertBefore(newOption, addOptionButton);

        // 새로 추가된 항목의 이벤트 리스너 추가
        const fileInput = newOption.querySelector(".file-input");
        const uploadTrigger = newOption.querySelector(".upload-trigger");
        addImagePreviewEvent(fileInput, uploadTrigger);
    });

    // 파일 선택 및 미리보기/삭제 설정
    function addImagePreviewEvent(fileInput, uploadTrigger) {
        let isImageUploaded = false; // 업로드 상태를 추적

        uploadTrigger.addEventListener("click", function () {
            if (isImageUploaded) {
                // 이미지 삭제 옵션 표시
                const deleteConfirm = confirm("이미지를 삭제하시겠습니까?");
                if (deleteConfirm) {
                    // 이미지 삭제 처리
                    uploadTrigger.src = "image.png"; // 기본 이미지로 되돌림
                    isImageUploaded = false;
                    fileInput.value = ""; // 파일 선택 초기화
                }
            } else {
                // 파일 선택 창 열기
                fileInput.click();
            }
        });

        fileInput.addEventListener("change", function () {
            if (fileInput.files.length > 0) {
                const file = fileInput.files[0];
                console.log("선택된 파일:", file.name);

                // 파일 미리보기 생성
                const reader = new FileReader();
                reader.onload = function (e) {
                    uploadTrigger.src = e.target.result; // 미리보기 이미지 표시
                    isImageUploaded = true; // 이미지 업로드 상태 갱신
                };
                reader.readAsDataURL(file); // 파일 읽기
            }
        });
    }
});