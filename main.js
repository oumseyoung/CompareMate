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
