<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Account - ConnectChat</title>

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #6a11cb, #2575fc);
        }

        .container {
            width: 420px;
            background: white;
            border-radius: 22px;
            padding: 40px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.25);
        }

        .logo {
            width: 70px;
            height: 70px;
            margin: 0 auto 20px;
            background: linear-gradient(135deg, #6a11cb, #2575fc);
            border-radius: 20px;
            position: relative;
        }

        .logo::before {
            content: "";
            position: absolute;
            width: 38px;
            height: 28px;
            background: white;
            border-radius: 12px;
            left: 16px;
            top: 17px;
        }

        .logo::after {
            content: "";
            position: absolute;
            width: 10px;
            height: 10px;
            background: white;
            transform: rotate(45deg);
            left: 18px;
            bottom: 17px;
        }

        h1 {
            text-align: center;
            color: #222;
            margin-bottom: 8px;
            font-size: 28px;
        }

        .subtitle {
            text-align: center;
            color: #777;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .input-group {
            margin-bottom: 18px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            color: #333;
            font-size: 14px;
            font-weight: bold;
        }

        input {
            width: 100%;
            padding: 14px;
            border: 1px solid #ddd;
            border-radius: 10px;
            font-size: 15px;
            outline: none;
            transition: 0.3s;
        }

        input:focus {
            border-color: #6a11cb;
            box-shadow: 0 0 0 3px rgba(106, 17, 203, 0.1);
        }

        .register-btn {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #6a11cb, #2575fc);
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 8px;
            transition: 0.3s;
        }

        .register-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(37, 117, 252, 0.3);
        }

        .login-link {
            text-align: center;
            margin-top: 22px;
            font-size: 14px;
            color: #666;
        }

        .login-link a {
            color: #6a11cb;
            text-decoration: none;
            font-weight: bold;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        .error {
            background: #ffe5e5;
            color: #d60000;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 15px;
            text-align: center;
            font-size: 13px;
        }

    </style>
</head>

<body>

<div class="container">

    <div class="logo"></div>

    <h1>Create Account</h1>

    <p class="subtitle">
        Join ConnectChat and start connecting
    </p>

    <% 
        String error = request.getParameter("error");

        if ("registration_failed".equals(error)) {
    %>

        <div class="error">
            Registration failed. Email may already exist.
        </div>

    <%
        }
    %>

    <form action="register" method="post"
          onsubmit="return validatePassword()">

        <div class="input-group">
            <label>Username</label>
            <input
                type="text"
                name="username"
                placeholder="Enter your username"
                required>
        </div>

        <div class="input-group">
            <label>Email</label>
            <input
                type="email"
                name="email"
                placeholder="Enter your email"
                required>
        </div>

        <div class="input-group">
            <label>Password</label>
            <input
                type="password"
                id="password"
                name="password"
                placeholder="Create a password"
                required>
        </div>

        <div class="input-group">
            <label>Confirm Password</label>
            <input
                type="password"
                id="confirmPassword"
                placeholder="Confirm your password"
                required>
        </div>

        <button type="submit" class="register-btn">
            Create Account
        </button>

    </form>

    <div class="login-link">
        Already have an account?
        <a href="login.jsp">Login</a>
    </div>

</div>

<script>

function validatePassword() {

    const password =
        document.getElementById("password").value;

    const confirmPassword =
        document.getElementById("confirmPassword").value;

    if (password !== confirmPassword) {

        alert("Passwords do not match!");

        return false;
    }

    return true;
}

</script>

</body>
</html>