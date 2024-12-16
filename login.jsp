<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CM Login</title>
    <link rel="stylesheet" href="login.css" />
</head>
<body>
    <a href="main.jsp"><img src="icon.png" alt="CM" id="CM" /></a>
    <hr />
    <div class="content">
        <h2>Compare Mate</h2>
        <h3>로그인</h3>
        <div class="form-container">
            <p>아이디</p>
            <input type="text" id="id" required />
            <p>비밀번호</p>
            <input type="password" id="psw1" required />
            <input type="button" id="submit" value="로그인" onclick="login()" />
            
            <!-- 아이디 찾기 및 비밀번호 찾기 링크 추가 -->
            <div class="links">
                <a href="findId.jsp">아이디 찾기</a> | <a href="findPassword.jsp">비밀번호 찾기</a> | <a href="register.jsp">회원가입</a>
            </div>
        </div>
    </div>

    <script>
        function login() {
            var id = document.getElementById("id").value;
            var password = document.getElementById("psw1").value;

            if (!id || !password) {
                alert("아이디와 비밀번호를 입력해주세요.");
                return;
            }

            var xhr = new XMLHttpRequest();
            xhr.open("POST", "loginProcess.jsp", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        if (xhr.responseText.trim() === "success") {
                            alert("로그인 성공!");
                            window.location.href = "main.jsp"; // 로그인 후 이동할 페이지
                        } else {
                            alert("아이디 또는 비밀번호가 잘못되었습니다.");
                        }
                    } else {
                        alert("로그인 요청 중 오류가 발생했습니다.");
                    }
                }
            };
            xhr.send("id=" + encodeURIComponent(id) + "&password=" + encodeURIComponent(password));
        }
    </script>
</body>
</html>
