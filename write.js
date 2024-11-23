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

    const pollOptionsContainer = document.querySelector(".poll-options");
    const addOptionButton = document.querySelector(".add-option");

    // 항목 추가 버튼 클릭 이벤트
    addOptionButton.addEventListener("click", function () {
        const newOption = document.createElement("div");
        newOption.className = "poll-option";

        newOption.innerHTML = `
            <input type="text" placeholder="항목 입력">
            <img src="image.png" alt="이미지 추가">
        `;

        // 버튼 위에 새로운 항목 추가
        pollOptionsContainer.insertBefore(newOption, addOptionButton);
    });
});
