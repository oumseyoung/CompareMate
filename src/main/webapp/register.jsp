<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CM Register</title>
    <link rel="stylesheet" href="register.css" />
    <script>
        function checkDuplicate() {
            var id = document.querySelector("input[name='id']").value;

            if (!id) {
                alert("아이디를 입력해주세요.");
                return;
            }

            var xhr = new XMLHttpRequest();
            xhr.open("GET", "checkDuplicate.jsp?id=" + encodeURIComponent(id), true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    if (xhr.responseText.trim() === "duplicate") {
                        alert("이미 사용 중인 아이디입니다.");
                    } else {
                        alert("사용 가능한 아이디입니다.");
                    }
                }
            };
            xhr.send();
        }

        function registerUser(event) {
            event.preventDefault(); 

            var id = document.querySelector("input[name='id']").value.trim();
            var email = document.querySelector("input[name='email']").value.trim();
            var password = document.querySelector("input[name='password']").value;
            var confirmPassword = document.querySelector("input[name='confirm_password']").value;
            var nickname = document.querySelector("input[name='nickname']").value.trim();

            if (!id || !email || !password || !confirmPassword || !nickname) {
                alert("모든 필드를 입력해주세요.");
                return;
            }

            // 이메일 형식 검증 추가
            var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                alert("유효한 이메일 주소를 입력해주세요.");
                return;
            }

            if (password !== confirmPassword) {
                alert("비밀번호가 일치하지 않습니다.");
                return;
            }

            var xhr = new XMLHttpRequest();
            xhr.open("POST", "registerProcess.jsp", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            if (response.status === "success") {
                                alert(response.message);
                                window.location.href = "login.jsp";
                            } else {
                                alert(response.message);
                            }
                        } catch (e) {
                            alert("응답을 처리하는 중 오류가 발생했습니다.");
                        }
                    } else {
                        alert("서버와의 통신에 실패했습니다.");
                    }
                }
            };

            var params = "id=" + encodeURIComponent(id) +
                         "&email=" + encodeURIComponent(email) +
                         "&password=" + encodeURIComponent(password) +
                         "&confirm_password=" + encodeURIComponent(confirmPassword) +
                         "&nickname=" + encodeURIComponent(nickname);

            xhr.send(params);
        }

        window.onload = function() {
            document.getElementById("submit").addEventListener("click", registerUser);
        };
    </script>
</head>
<body>
   <a href="first.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
    <hr />
    
    <div class="content">
        <h2>Compare Mate</h2>
        <h3>회원가입</h3>
        <div class="form-container">
            <!-- form 태그 없이 입력 필드들 -->
            <p>아이디</p>
            <div class="input-group">
                <input type="text" name="id" required />
                <input type="button" id="duplicate-check" value="중복확인" onclick="checkDuplicate()" />
            </div>
            <p>이메일</p>
            <!-- 이메일 입력 필드 수정 -->
            <input type="text" name="email" required />
            <p>비밀번호</p>
            <input type="password" name="password" required />
            <p>비밀번호 확인</p>
            <input type="password" name="confirm_password" required />
            <p>닉네임</p>
            <input type="text" name="nickname" required />
            <input type="submit" id="submit" value="가입하기"/>    
        </div>
    </div>
</body>
</html>
