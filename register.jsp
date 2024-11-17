<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CM Register</title>
    <link rel="stylesheet" href="register.css" />
</head>
<body>
    <img src="icon.png" alt="CM" />
    <hr />
    
    <div class="content">
        <h2>Compare Mate</h2>
        <h3>회원가입</h3>
        <div class="form-container">
            <!-- 회원가입 처리를 위한 form 태그 추가 -->
            <form action="register.jsp" method="post">
               <p>아이디</p>
                <div class="input-group">
                    <input type="text" name="id" required />
                    <input type="button" id="duplicate-check" value="중복확인" onclick="checkDuplicate()" />
                </div>
                <p>비밀번호</p>
                <input type="password" name="password" required />
                <p>비밀번호 확인</p>
                <input type="password" name="confirm_password" required />
                <p>닉네임</p>
                <input type="text" name="nickname" required /><br /><br />
                <input type="submit" id="submit" value="가입하기"/>
            </form>
        </div>
    </div>
    <%
        // 회원가입 처리
        String id = request.getParameter("id");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String nickname = request.getParameter("nickname");

        if (id != null && password != null && confirmPassword != null && nickname != null) {
            if (!password.equals(confirmPassword)) {
                out.println("<script>alert('비밀번호가 일치하지 않습니다.');</script>");
            } else {
            	try {
            	    Class.forName("com.mysql.cj.jdbc.Driver");
            	    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/compare_mate", "lee", "lee1202");
            	    String sql = "INSERT INTO compare_mate (id, password, nickname) VALUES (?, ?, ?)";
            	    PreparedStatement pstmt = conn.prepareStatement(sql);
            	    pstmt.setString(1, id);
            	    pstmt.setString(2, password);
            	    pstmt.setString(3, nickname);

            	    int rows = pstmt.executeUpdate();
            	    if (rows > 0) {
            	        out.println("<script>alert('회원가입이 완료되었습니다.'); location.href='login.jsp';</script>");
            	    } else {
            	        out.println("<script>alert('회원가입에 실패했습니다. 다시 시도해주세요.');</script>");
            	    }

            	    pstmt.close();
            	    conn.close();
            	}catch (Exception e) {
                    out.println("<script>alert('오류가 발생했습니다: " + e.getMessage() + "');</script>");
                }

            }
        }
    %>

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
</script>

</body>
</html>
