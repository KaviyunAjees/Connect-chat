<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>ConnectChat - Login</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;

            background: linear-gradient(
                135deg,
                #667eea,
                #764ba2
            );
        }

        /* LOGIN CARD */

        .login-container {
            width: 475px;

            background: #ffffff;

            padding: 48px 50px;

            border-radius: 28px;

            box-shadow:
                0 20px 50px rgba(0, 0, 0, 0.20);

            text-align: center;
        }

        /* LOGO */

        .logo-area {
            display: flex;
            flex-direction: column;
            align-items: center;

            margin-bottom: 10px;
        }

        .chat-icon {
            width: 72px;
            height: 72px;

            border-radius: 22px;

            background: linear-gradient(
                135deg,
                #667eea,
                #764ba2
            );

            display: flex;
            justify-content: center;
            align-items: center;

            position: relative;

            margin-bottom: 14px;

            box-shadow:
                0 8px 20px rgba(102, 126, 234, 0.35);
        }

        /* Chat bubble */

        .chat-icon::before {
            content: "";

            width: 39px;
            height: 29px;

            background: white;

            border-radius: 10px;

            position: absolute;
        }

        /* Chat bubble tail */

        .chat-icon::after {
            content: "";

            position: absolute;

            bottom: 17px;
            right: 16px;

            width: 10px;
            height: 10px;

            background: white;

            transform: rotate(45deg);
        }

        /* Dots inside icon */

        .dots {
            position: relative;

            z-index: 2;

            display: flex;

            gap: 5px;
        }

        .dot {
            width: 6px;
            height: 6px;

            background: #667eea;

            border-radius: 50%;
        }

        /* TITLE */

        .logo-title {
            font-size: 34px;

            font-weight: 700;

            color: #667eea;

            letter-spacing: -1px;
        }

        .subtitle {
            font-size: 17px;

            color: #777;

            margin-top: 8px;

            margin-bottom: 30px;
        }

        /* MESSAGE */

        .error {
            background: #ffe5e5;

            color: #d63031;

            padding: 13px;

            border-radius: 10px;

            margin-bottom: 18px;

            font-size: 15px;
        }

        .success {
            background: #e5ffe9;

            color: #218c3a;

            padding: 13px;

            border-radius: 10px;

            margin-bottom: 18px;

            font-size: 15px;
        }

        /* FORM */

        .form-group {
            text-align: left;

            margin-bottom: 20px;
        }

        .form-group label {
            display: block;

            margin-bottom: 9px;

            color: #222;

            font-size: 16px;

            font-weight: bold;
        }

        .form-group input {
            width: 100%;

            padding: 15px;

            border: 1px solid #ddd;

            border-radius: 12px;

            font-size: 16px;

            outline: none;

            transition: 0.2s;
        }

        .form-group input:focus {
            border-color: #667eea;

            box-shadow:
                0 0 0 3px rgba(102, 126, 234, 0.12);
        }

        /* LOGIN BUTTON */

        .login-btn {
            width: 100%;

            padding: 16px;

            margin-top: 5px;

            border: none;

            border-radius: 12px;

            background: linear-gradient(
                135deg,
                #667eea,
                #667eea
            );

            color: white;

            font-size: 17px;

            font-weight: bold;

            cursor: pointer;

            transition: 0.2s;
        }

        .login-btn:hover {
            transform: translateY(-2px);

            box-shadow:
                0 8px 18px rgba(102, 126, 234, 0.35);
        }

        /* REGISTER */

        .register {
            margin-top: 27px;

            color: #777;

            font-size: 16px;
        }

        .register a {
            color: #667eea;

            text-decoration: none;

            font-weight: bold;
        }

        .register a:hover {
            text-decoration: underline;
        }

    </style>

</head>


<body>


<div class="login-container">


    <!-- CONNECTCHAT LOGO -->

    <div class="logo-area">

        <div class="chat-icon">

            <div class="dots">

                <span class="dot"></span>

                <span class="dot"></span>

                <span class="dot"></span>

            </div>

        </div>


        <div class="logo-title">
            ConnectChat
        </div>

    </div>


    <p class="subtitle">
        Welcome back! Login to continue
    </p>


    <!-- ERROR MESSAGE -->

    <% if ("invalid".equals(request.getParameter("error"))) { %>

        <div class="error">
            Invalid email or password
        </div>

    <% } %>


    <!-- SUCCESS MESSAGE -->

    <% if ("registered".equals(request.getParameter("success"))) { %>

        <div class="success">
            Registration successful! Please login.
        </div>

    <% } %>


    <!-- LOGIN FORM -->

    <form action="login" method="post">


        <div class="form-group">

            <label>
                Email
            </label>

            <input
                type="email"
                name="email"
                placeholder="Enter your email"
                required>

        </div>


        <div class="form-group">

            <label>
                Password
            </label>

            <input
                type="password"
                name="password"
                placeholder="Enter your password"
                required>

        </div>


        <button
            type="submit"
            class="login-btn">

            Login

        </button>


    </form>


    <!-- REGISTER -->

    <div class="register">

        Don't have an account?

        <a href="register.jsp">
            Create Account
        </a>

    </div>


</div>


</body>

</html>