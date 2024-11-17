<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Compare Mate</title>
    <link rel="stylesheet" href="first.css" />
  </head>
  <body>
    <img src="icon.png" alt="CM" />
    <h1>Welcome to Compare Mate!</h1>
    <div class="btn">
      <input
        type="button"
        id="sign"
        value="Sign in"
        onclick="window.location.href='login.jsp';"
      />
      <input
        type="button"
        id="register"
        value="Register"
        onclick="window.location.href='register.jsp';"
      />
    </div>
  </body>
</html>
