<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CM 아이디 찾기</title>
    <link rel="stylesheet" href="login.css" />
    <script>
        // 이메일 유효성 검사 함수
        function validateEmail(email) {
            var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        // 아이디 찾기 함수
        function findId() {
            var email = document.getElementById('email').value;

            if (!validateEmail(email)) {
                alert('유효한 이메일 주소를 입력해주세요.');
                return;
            }

            // 서버로 이메일 전송
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'findIdAction.jsp', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    alert(xhr.responseText);
                    window.location.href = 'login.jsp';
                }
            };
            xhr.send('email=' + encodeURIComponent(email));
        }
    </script>
</head>
<body>
    <img src="icon.png" alt="CM" />
    <hr />
    <div class="content">
        <h2>Compare Mate</h2>
        <h3>아이디 찾기</h3>
        <div class="form-container">
            <p>이메일</p>
            <input type="text" id="email" required />
            <input type="button" id="submit" value="아이디 찾기" onclick="findId()" /> 	
            <div class="links">
                <a href="findId.jsp">아이디 찾기</a> | <a href="findPassword.jsp">비밀번호 찾기</a> | <a href="register.jsp">회원가입</a>
            </div>
        </div>
    </div>
</body>
</html>
