<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String userId = request.getParameter("userId");
    if (userId == null || userId.trim().isEmpty()) {
        // 잘못된 접근 처리
        response.sendRedirect("findPassword.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>CM 비밀번호 재설정</title>
    <link rel="stylesheet" href="login.css" />
    <script>
    // 비밀번호 변경 함수
    function changePassword() {
        var newPassword = document.getElementById('newPassword').value;
        var confirmPassword = document.getElementById('confirmPassword').value;

        if (newPassword !== confirmPassword) {
            alert('비밀번호가 일치하지 않습니다.');
            return;
        }

        // 서버로 새로운 비밀번호 전송
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'resetPasswordProcess.jsp', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = xhr.responseText.trim(); // 응답 문자열의 공백 제거
                alert(response);
                if (response === '비밀번호가 성공적으로 변경되었습니다.') {
                    window.location.href = 'login.jsp';
                }
            }
        };
        xhr.send('userId=' + encodeURIComponent('<%= userId %>') + '&newPassword=' + encodeURIComponent(newPassword));
    }
</script>

</head>
<body>
    <img src="icon.png" alt="CM" />
    <hr />
    <div class="content">
        <h2>Compare Mate</h2>
        <h3>비밀번호 재설정</h3>
        <div class="form-container">
            <p>새 비밀번호</p>
            <input type="password" id="newPassword" required />
            <p>새 비밀번호 확인</p>
            <input type="password" id="confirmPassword" required />
            <input type="button" id="submit" value="비밀번호 변경" onclick="changePassword()" />
        </div>
    </div>
</body>
</html>
