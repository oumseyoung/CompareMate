<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>CM 비밀번호 찾기</title>
    <link rel="stylesheet" href="login.css" />
    <script>
        // 이메일 유효성 검사 함수
        function validateEmail(email) {
            var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        // 비밀번호 변경 요청 함수
        function resetPassword() {
            var userId = document.getElementById('userId').value.trim();
            var email = document.getElementById('email').value.trim();

            if (userId === '') {
                alert('아이디를 입력해주세요.');
                return;
            }

            if (!validateEmail(email)) {
                alert('유효한 이메일 주소를 입력해주세요.');
                return;
            }

            // 서버로 아이디와 이메일 전송
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'findPasswordProcess.jsp', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    // 서버로부터 받은 응답 처리
                    var response = xhr.responseText.trim(); // 공백 제거
                    if (response === 'SUCCESS') {
                        // 비밀번호 변경 페이지로 이동
                        window.location.href = 'resetPassword.jsp?userId=' + encodeURIComponent(userId);
                    } else {
                        alert(response);
                    }
                }
            };
            xhr.send('userId=' + encodeURIComponent(userId) + '&email=' + encodeURIComponent(email));
        }
    </script>
</head>
<body>
    <a href="first.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
    <hr />
    <div class="content">
        <h2>Compare Mate</h2>
        <h3>비밀번호 찾기</h3>
        <div class="form-container">
            <p>아이디</p>
            <input type="text" id="userId" required />
            <p>이메일</p>
            <input type="text" id="email" required />
            <input type="button" id="submit" value="비밀번호 변경" onclick="resetPassword()" />

            <div class="links">
                <a href="findId.jsp">아이디 찾기</a> | <a href="findPassword.jsp">비밀번호 찾기</a> | <a href="register.jsp">회원가입</a>
            </div>
        </div>
    </div>
</body>
</html>
