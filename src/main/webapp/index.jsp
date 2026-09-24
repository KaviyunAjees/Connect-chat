<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>ConnectChat | Real-Time Web Chat</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: "Segoe UI", Arial, sans-serif;
            background: #f7f9ff;
            color: #18264d;
            overflow-x: hidden;
        }

        /* =========================================
           SVG ICON
        ========================================= */

        .icon {
            width: 20px;
            height: 20px;
            display: inline-block;
            vertical-align: middle;
        }

        /* =========================================
           NAVBAR
        ========================================= */

        .navbar {
            width: 92%;
            max-width: 1400px;
            height: 76px;

            margin: 20px auto 0;

            padding: 0 25px;

            background: rgba(255,255,255,0.94);

            border: 1px solid #e8ecf8;

            border-radius: 24px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            box-shadow:
                0 10px 35px rgba(40,55,120,0.08);

            position: relative;
            z-index: 20;
        }

        /* LOGO */

        .logo {
            display: flex;
            align-items: center;
            gap: 12px;

            text-decoration: none;

            color: #172653;

            font-size: 25px;
            font-weight: 800;
        }

        .logo-icon {
            width: 45px;
            height: 45px;

            border-radius: 14px;

            background:
                linear-gradient(
                    135deg,
                    #634cf5,
                    #874ff2,
                    #27acec
                );

            display: flex;
            align-items: center;
            justify-content: center;

            color: white;

            box-shadow:
                0 8px 20px rgba(98,76,245,0.30);
        }

        .logo-icon svg {
            width: 27px;
            height: 27px;
        }

        .logo-text span {
            color: #6750ef;
        }

        /* NAV LINKS */

        .nav-links {
            display: flex;
            gap: 35px;
        }

        .nav-links a {
            text-decoration: none;

            color: #64708c;

            font-size: 15px;
            font-weight: 600;

            transition: 0.3s;
        }

        .nav-links a:hover {
            color: #634cf5;
        }

        .nav-links .active {
            color: #634cf5;
        }

        /* NAV BUTTONS */

        .nav-buttons {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .login-btn {
            text-decoration: none;

            padding: 11px 25px;

            border: 1.5px solid #5d4ee7;

            border-radius: 25px;

            color: #5043d0;

            font-size: 14px;
            font-weight: 700;

            transition: 0.3s;
        }

        .login-btn:hover {
            background: #604cf0;
            color: white;
        }

        .register-btn {
            text-decoration: none;

            padding: 12px 26px;

            border-radius: 25px;

            color: white;

            font-size: 14px;
            font-weight: 700;

            background:
                linear-gradient(
                    100deg,
                    #654cf3,
                    #8b4ced,
                    #28acec
                );

            box-shadow:
                0 8px 20px rgba(98,76,245,0.25);

            transition: 0.3s;
        }

        .register-btn:hover {
            transform: translateY(-2px);

            box-shadow:
                0 12px 28px rgba(98,76,245,0.35);
        }

        /* =========================================
           HERO
        ========================================= */

        .hero {
            width: 92%;
            max-width: 1400px;

            min-height: 600px;

            margin: 35px auto 0;

            display: grid;

            grid-template-columns: 0.9fr 1.1fr;

            align-items: center;

            gap: 50px;

            position: relative;
        }

        /* DECORATIVE BACKGROUND */

        .circle-one {
            position: absolute;

            width: 390px;
            height: 390px;

            border-radius: 50%;

            background: #e6e1ff;

            opacity: 0.55;

            filter: blur(2px);

            right: 60px;
            top: 80px;

            z-index: -2;
        }

        .circle-two {
            position: absolute;

            width: 240px;
            height: 240px;

            border-radius: 50%;

            background: #c9f3ff;

            opacity: 0.55;

            right: 380px;
            bottom: 10px;

            z-index: -3;
        }

        .small-dot {
            position: absolute;

            width: 18px;
            height: 18px;

            border-radius: 50%;

            background: #7254ef;

            right: 5%;
            top: 50px;

            opacity: 0.7;
        }

        /* LEFT SIDE */

        .hero-left {
            padding-left: 30px;
        }

        .badge {
            display: inline-flex;

            align-items: center;

            gap: 9px;

            padding: 9px 17px;

            border-radius: 30px;

            background: #edf0ff;

            color: #4053c8;

            font-size: 14px;

            font-weight: 700;

            margin-bottom: 22px;
        }

        .status-dot {
            width: 8px;
            height: 8px;

            border-radius: 50%;

            background: #28c979;

            box-shadow:
                0 0 0 5px rgba(40,201,121,0.12);
        }

        .hero-title {
            font-size: clamp(55px, 6vw, 82px);

            line-height: 0.98;

            letter-spacing: -4px;

            color: #142653;

            font-weight: 800;

            margin-bottom: 28px;
        }

        .gradient-text {
            background:
                linear-gradient(
                    100deg,
                    #6949f4,
                    #8651f4,
                    #1da9ed
                );

            -webkit-background-clip: text;

            -webkit-text-fill-color: transparent;
        }

        .hero-description {
            max-width: 590px;

            color: #68748f;

            font-size: 18px;

            line-height: 1.7;

            margin-bottom: 32px;
        }

        /* HERO BUTTONS */

        .hero-buttons {
            display: flex;

            align-items: center;

            gap: 17px;
        }

        .primary-btn {
            display: inline-flex;

            align-items: center;

            gap: 10px;

            text-decoration: none;

            padding: 16px 28px;

            border-radius: 32px;

            color: white;

            font-size: 16px;

            font-weight: 700;

            background:
                linear-gradient(
                    100deg,
                    #6349f3,
                    #8a4cef,
                    #26aceb
                );

            box-shadow:
                0 12px 28px rgba(96,75,239,0.25);

            transition: 0.3s;
        }

        .primary-btn:hover {
            transform: translateY(-4px);

            box-shadow:
                0 18px 35px rgba(96,75,239,0.35);
        }

        .secondary-btn {
            display: inline-flex;

            align-items: center;

            gap: 9px;

            text-decoration: none;

            padding: 15px 28px;

            border: 2px solid #5e55d9;

            border-radius: 32px;

            color: #5148c9;

            font-size: 16px;

            font-weight: 700;

            transition: 0.3s;
        }

        .secondary-btn:hover {
            background: #604df0;
            color: white;
        }

        /* =========================================
           CHAT PREVIEW
        ========================================= */

        .hero-right {
            position: relative;

            display: flex;

            justify-content: center;

            align-items: center;
        }

        .chat-card {
            width: 620px;

            max-width: 100%;

            height: 430px;

            background: white;

            border-radius: 28px;

            display: flex;

            overflow: hidden;

            border: 1px solid #e8ebf6;

            box-shadow:
                0 35px 80px rgba(47,60,135,0.18),
                0 5px 20px rgba(47,60,135,0.07);
        }

        /* SIDEBAR */

        .chat-sidebar {
            width: 185px;

            flex-shrink: 0;

            padding: 22px 14px;

            background:
                linear-gradient(
                    165deg,
                    #142452,
                    #263b80
                );

            color: white;
        }

        .chat-brand {
            display: flex;

            align-items: center;

            gap: 8px;

            font-size: 14px;

            font-weight: 700;

            margin-bottom: 27px;
        }

        .mini-logo {
            width: 30px;
            height: 30px;

            border-radius: 9px;

            background:
                linear-gradient(
                    135deg,
                    #7658ff,
                    #2bb9ed
                );

            display: flex;

            justify-content: center;

            align-items: center;
        }

        .mini-logo svg {
            width: 18px;
            height: 18px;
        }

        .side-menu {
            display: flex;

            flex-direction: column;

            gap: 6px;
        }

        .side-item {
            display: flex;

            align-items: center;

            gap: 9px;

            padding: 10px 11px;

            border-radius: 10px;

            color: #b9c4ea;

            font-size: 12px;

            transition: 0.3s;
        }

        .side-item svg {
            width: 16px;
            height: 16px;
        }

        .side-item.selected {
            background:
                linear-gradient(
                    90deg,
                    #5f50e8,
                    #397edb
                );

            color: white;
        }

        .online-title {
            margin: 25px 8px 12px;

            color: #95a4da;

            font-size: 10px;

            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: 1.3px;
        }

        .person {
            display: flex;

            align-items: center;

            gap: 8px;

            padding: 6px 4px;

            color: #d7def6;

            font-size: 11px;
        }

        .person-avatar {
            width: 29px;
            height: 29px;

            border-radius: 50%;

            display: flex;

            align-items: center;

            justify-content: center;

            font-weight: 700;

            color: white;

            background:
                linear-gradient(
                    135deg,
                    #8062ff,
                    #2bb8ea
                );
        }

        .online {
            display: inline-block;

            width: 6px;
            height: 6px;

            border-radius: 50%;

            background: #31d47e;

            margin-left: 3px;
        }

        /* CHAT MAIN */

        .chat-main {
            flex: 1;

            min-width: 0;

            display: flex;

            flex-direction: column;

            background: #fff;
        }

        .chat-header {
            height: 72px;

            padding: 0 20px;

            border-bottom: 1px solid #edf0f6;

            display: flex;

            align-items: center;

            justify-content: space-between;
        }

        .chat-user {
            display: flex;

            align-items: center;

            gap: 10px;
        }

        .user-avatar {
            width: 39px;
            height: 39px;

            border-radius: 50%;

            display: flex;

            align-items: center;

            justify-content: center;

            color: white;

            font-weight: 700;

            background:
                linear-gradient(
                    135deg,
                    #7557f6,
                    #29afea
                );
        }

        .user-name {
            font-size: 14px;

            font-weight: 700;

            color: #172653;
        }

        .user-status {
            margin-top: 3px;

            color: #2abb74;

            font-size: 10px;
        }

        .header-actions {
            display: flex;

            gap: 15px;

            color: #78839b;
        }

        .header-actions svg {
            width: 18px;
            height: 18px;
        }

        /* MESSAGES */

        .messages {
            flex: 1;

            padding: 20px;

            display: flex;

            flex-direction: column;

            gap: 14px;

            background:
                radial-gradient(
                    circle at 90% 10%,
                    rgba(101,78,240,0.06),
                    transparent 30%
                );
        }

        .message {
            max-width: 72%;

            padding: 11px 14px;

            border-radius: 15px;

            font-size: 12px;

            line-height: 1.45;
        }

        .received {
            align-self: flex-start;

            color: #3c4965;

            background: #f0f3f9;

            border-bottom-left-radius: 4px;
        }

        .sent {
            align-self: flex-end;

            color: white;

            background:
                linear-gradient(
                    135deg,
                    #6550ec,
                    #3d83e8
                );

            border-bottom-right-radius: 4px;
        }

        .time {
            display: block;

            margin-top: 5px;

            font-size: 9px;

            text-align: right;

            opacity: 0.65;
        }

        /* INPUT */

        .message-input {
            height: 63px;

            padding: 10px 15px;

            border-top: 1px solid #edf0f6;

            display: flex;

            align-items: center;

            gap: 9px;
        }

        .attachment {
            color: #7a849a;

            display: flex;
        }

        .fake-input {
            flex: 1;

            padding: 11px 15px;

            border-radius: 22px;

            background: #f4f6fa;

            color: #9ba4b6;

            font-size: 11px;
        }

        .send-button {
            width: 38px;
            height: 38px;

            border-radius: 50%;

            background:
                linear-gradient(
                    135deg,
                    #654ff1,
                    #299fe7
                );

            color: white;

            display: flex;

            align-items: center;

            justify-content: center;
        }

        .send-button svg {
            width: 17px;
            height: 17px;
        }

        /* FLOATING CARD */

        .floating-card {
            position: absolute;

            right: -18px;
            bottom: 22px;

            padding: 15px 18px;

            border-radius: 17px;

            background: white;

            box-shadow:
                0 15px 40px rgba(48,58,130,0.15);

            transform: rotate(4deg);

            text-align: center;
        }

        .floating-card .heart {
            width: 30px;
            height: 30px;

            margin: auto auto 5px;

            border-radius: 50%;

            background: #eee9ff;

            color: #6b51ec;

            display: flex;

            align-items: center;

            justify-content: center;
        }

        .floating-card p {
            color: #596181;

            font-size: 11px;

            font-weight: 700;

            line-height: 1.4;
        }

        /* =========================================
           FEATURES
        ========================================= */

        .features {
            width: 88%;

            max-width: 1200px;

            margin: 10px auto 0;

            padding: 22px 25px;

            background: rgba(255,255,255,0.9);

            border: 1px solid #e9edf7;

            border-radius: 25px;

            display: grid;

            grid-template-columns:
                repeat(4, 1fr);

            box-shadow:
                0 15px 45px rgba(48,66,130,0.07);
        }

        .feature {
            display: flex;

            align-items: center;

            gap: 14px;

            padding: 10px 20px;

            border-right: 1px solid #e6eaf3;
        }

        .feature:last-child {
            border-right: none;
        }

        .feature-icon {
            width: 48px;
            height: 48px;

            flex-shrink: 0;

            border-radius: 14px;

            display: flex;

            align-items: center;

            justify-content: center;

            background: #eeeaff;

            color: #634cf1;
        }

        .feature-icon svg {
            width: 23px;
            height: 23px;
        }

        .feature:nth-child(2) .feature-icon {
            background: #e5f8ee;
            color: #20a869;
        }

        .feature:nth-child(3) .feature-icon {
            background: #e5f1ff;
            color: #277ae4;
        }

        .feature:nth-child(4) .feature-icon {
            background: #f1eaff;
            color: #8850e9;
        }

        .feature h3 {
            font-size: 15px;

            margin-bottom: 4px;

            color: #172653;
        }

        .feature p {
            color: #78839a;

            font-size: 11px;

            line-height: 1.4;
        }

        /* =========================================
           FOOTER TEXT
        ========================================= */

        .bottom-text {
            text-align: center;

            padding: 25px 0 40px;

            color: #737d96;

            font-size: 12px;

            letter-spacing: 1.5px;
        }

        .bottom-line {
            display: flex;

            align-items: center;

            justify-content: center;

            gap: 12px;

            margin-bottom: 12px;
        }

        .bottom-line span {
            width: 45px;
            height: 1px;

            background: #b7aef5;
        }

        .bottom-heart {
            color: #6b52ef;
        }

        /* =========================================
           RESPONSIVE
        ========================================= */

        @media (max-width: 1100px) {

            .hero {
                grid-template-columns: 1fr;

                text-align: center;
            }

            .hero-left {
                padding-left: 0;
            }

            .hero-description {
                margin-left: auto;
                margin-right: auto;
            }

            .hero-buttons {
                justify-content: center;
            }

            .features {
                grid-template-columns:
                    repeat(2, 1fr);
            }

            .feature {
                border-right: none;
            }

            .hero-right {
                margin-top: 20px;
            }
        }

        @media (max-width: 700px) {

            .navbar {
                width: 94%;
                height: 68px;

                padding: 0 15px;
            }

            .nav-links {
                display: none;
            }

            .register-btn {
                display: none;
            }

            .logo {
                font-size: 20px;
            }

            .logo-icon {
                width: 39px;
                height: 39px;
            }

            .hero {
                width: 94%;

                margin-top: 30px;
            }

            .hero-title {
                font-size: 54px;

                letter-spacing: -3px;
            }

            .hero-description {
                font-size: 15px;
            }

            .hero-buttons {
                flex-direction: column;
            }

            .primary-btn,
            .secondary-btn {
                width: 220px;

                justify-content: center;
            }

            .chat-card {
                height: 380px;
            }

            .chat-sidebar {
                width: 135px;
            }

            .floating-card {
                display: none;
            }

            .features {
                width: 92%;

                grid-template-columns: 1fr;

                padding: 15px;
            }

            .feature {
                border-bottom: 1px solid #edf0f5;

                padding: 15px;
            }

            .feature:last-child {
                border-bottom: none;
            }
        }

    </style>

</head>


<body>


<!-- =========================================
     NAVBAR
========================================= -->

<nav class="navbar">


    <a href="index.jsp" class="logo">

        <div class="logo-icon">

            <!-- CHAT LOGO SVG -->

            <svg viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="1.8"
                 stroke-linecap="round"
                 stroke-linejoin="round">

                <path d="M20 11.5a7.5 7.5 0 0 1-8 7.5
                         8.5 8.5 0 0 1-3.2-.6
                         L4 20l1.6-3.8
                         A7.4 7.4 0 0 1 4.5 12
                         A7.5 7.5 0 0 1 12 4.5
                         A7.5 7.5 0 0 1 20 11.5Z"/>

                <path d="M8 12h.01"/>
                <path d="M12 12h.01"/>
                <path d="M16 12h.01"/>

            </svg>

        </div>

        <div class="logo-text">
            Connect<span>Chat</span>
        </div>

    </a>


    <div class="nav-links">

        <a href="index.jsp" class="active">
            Home
        </a>

        <a href="#features">
            Features
        </a>

        <a href="#about">
            About
        </a>

    </div>


    <div class="nav-buttons">

        <a href="login.jsp" class="login-btn">
            Login
        </a>

        <a href="register.jsp" class="register-btn">
            Register
        </a>

    </div>

</nav>


<!-- =========================================
     HERO
========================================= -->

<section class="hero">


    <div class="circle-one"></div>

    <div class="circle-two"></div>

    <div class="small-dot"></div>


    <!-- LEFT -->

    <div class="hero-left">


        <div class="badge">

            <span class="status-dot"></span>

            Real-Time Web Chat Application

        </div>


        <h1 class="hero-title">

            Connect.<br>

            <span class="gradient-text">
                Chat.
            </span><br>

            Share.

        </h1>


        <p class="hero-description">

            ConnectChat makes communication simple, fast and
            enjoyable. Chat with friends, share messages and
            stay connected in real time.

        </p>


        <div class="hero-buttons">


            <a href="register.jsp"
               class="primary-btn">

                Get Started

                <svg class="icon"
                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round">

                    <path d="M5 12h14"/>
                    <path d="m13 6 6 6-6 6"/>

                </svg>

            </a>


            <a href="login.jsp"
               class="secondary-btn">

                <svg class="icon"
                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round">

                    <path d="M15 3h4a2 2 0 0 1 2 2v14
                             a2 2 0 0 1-2 2h-4"/>

                    <path d="M10 17l5-5-5-5"/>

                    <path d="M15 12H3"/>

                </svg>

                Sign In

            </a>

        </div>


    </div>


    <!-- =====================================
         CHAT PREVIEW
    ====================================== -->

    <div class="hero-right">


        <div class="chat-card">


            <!-- SIDEBAR -->

            <div class="chat-sidebar">


                <div class="chat-brand">

                    <div class="mini-logo">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="white"
                             stroke-width="1.8"
                             stroke-linecap="round"
                             stroke-linejoin="round">

                            <path d="M20 11.5a7.5 7.5 0 0 1-8 7.5
                                     8.5 8.5 0 0 1-3.2-.6
                                     L4 20l1.6-3.8
                                     A7.4 7.4 0 0 1 4.5 12
                                     A7.5 7.5 0 0 1 12 4.5
                                     A7.5 7.5 0 0 1 20 11.5Z"/>

                        </svg>

                    </div>

                    ConnectChat

                </div>


                <div class="side-menu">


                    <div class="side-item selected">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="1.8">

                            <path d="M20 11.5a7.5 7.5 0 0 1-8 7.5
                                     8.5 8.5 0 0 1-3.2-.6
                                     L4 20l1.6-3.8
                                     A7.4 7.4 0 0 1 4.5 12
                                     A7.5 7.5 0 0 1 12 4.5
                                     A7.5 7.5 0 0 1 20 11.5Z"/>

                        </svg>

                        Chats

                    </div>


                    <div class="side-item">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="1.8">

                            <circle cx="9" cy="8" r="3"/>
                            <circle cx="17" cy="9" r="2.5"/>

                            <path d="M3 19c0-3 2.5-5 6-5s6 2 6 5"/>
                            <path d="M14 15c3 0 5 1.5 5 4"/>

                        </svg>

                        Friends

                    </div>


                    <div class="side-item">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="1.8">

                            <circle cx="8" cy="8" r="3"/>
                            <circle cx="16" cy="8" r="3"/>

                            <path d="M2.5 19c0-3 2.2-5 5.5-5"/>
                            <path d="M21.5 19c0-3-2.2-5-5.5-5"/>

                        </svg>

                        Groups

                    </div>


                    <div class="side-item">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="1.8">

                            <circle cx="12" cy="12" r="3"/>

                            <path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-1.7 1.7
                                     -.1-.1a1.7 1.7 0 0 0-1.9-.3
                                     1.7 1.7 0 0 0-1 1.5V20h-2.4v-.2
                                     a1.7 1.7 0 0 0-1-1.5
                                     1.7 1.7 0 0 0-1.9.3l-.1.1-1.7-1.7
                                     .1-.1a1.7 1.7 0 0 0 .3-1.9
                                     1.7 1.7 0 0 0-1.5-1H7v-2.4h.2
                                     a1.7 1.7 0 0 0 1.5-1
                                     1.7 1.7 0 0 0-.3-1.9l-.1-.1
                                     1.7-1.7.1.1a1.7 1.7 0 0 0 1.9.3
                                     1.7 1.7 0 0 0 1-1.5V5h2.4v.2
                                     a1.7 1.7 0 0 0 1 1.5
                                     1.7 1.7 0 0 0 1.9-.3l.1-.1
                                     1.7 1.7-.1.1a1.7 1.7 0 0 0-.3 1.9
                                     1.7 1.7 0 0 0 1.5 1h.2v2.4h-.2
                                     a1.7 1.7 0 0 0-1.5 1Z"/>

                        </svg>

                        Settings

                    </div>


                </div>


                <div class="online-title">
                    Online
                </div>


                <div class="person">

                    <div class="person-avatar">
                        A
                    </div>

                    Arun

                    <span class="online"></span>

                </div>


                <div class="person">

                    <div class="person-avatar">
                        P
                    </div>

                    Priya

                    <span class="online"></span>

                </div>


                <div class="person">

                    <div class="person-avatar">
                        R
                    </div>

                    Rahul

                    <span class="online"></span>

                </div>


                <div class="person">

                    <div class="person-avatar">
                        S
                    </div>

                    Sneha

                    <span class="online"></span>

                </div>


            </div>


            <!-- CHAT MAIN -->

            <div class="chat-main">


                <div class="chat-header">


                    <div class="chat-user">

                        <div class="user-avatar">
                            P
                        </div>

                        <div>

                            <div class="user-name">
                                Priya
                            </div>

                            <div class="user-status">
                                ● Online
                            </div>

                        </div>

                    </div>


                    <div class="header-actions">

                        <!-- PHONE -->

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="1.8"
                             stroke-linecap="round">

                            <path d="M22 16.9v3
                                     a2 2 0 0 1-2.2 2
                                     19.8 19.8 0 0 1-8.6-3.1
                                     19.5 19.5 0 0 1-6-6
                                     19.8 19.8 0 0 1-3.1-8.6
                                     A2 2 0 0 1 4.1 2h3
                                     a2 2 0 0 1 2 1.7
                                     12.8 12.8 0 0 0 .7 2.8
                                     2 2 0 0 1-.5 2.1L8 9.9
                                     a16 16 0 0 0 6 6l1.3-1.3
                                     a2 2 0 0 1 2.1-.5
                                     12.8 12.8 0 0 0 2.8.7
                                     A2 2 0 0 1 22 16.9Z"/>

                        </svg>


                        <!-- VIDEO -->

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="1.8"
                             stroke-linejoin="round">

                            <rect x="3" y="6"
                                  width="13"
                                  height="12"
                                  rx="2"/>

                            <path d="m16 10 5-3v10l-5-3z"/>

                        </svg>


                        <!-- MORE -->

                        <svg viewBox="0 0 24 24"
                             fill="currentColor">

                            <circle cx="5" cy="12" r="1.5"/>
                            <circle cx="12" cy="12" r="1.5"/>
                            <circle cx="19" cy="12" r="1.5"/>

                        </svg>

                    </div>

                </div>


                <!-- MESSAGES -->

                <div class="messages">


                    <div class="message received">

                        Hey! Welcome to ConnectChat.

                        <span class="time">
                            10:24 AM
                        </span>

                    </div>


                    <div class="message sent">

                        Hi! This looks amazing.

                        <span class="time">
                            10:25 AM ✓✓
                        </span>

                    </div>


                    <div class="message received">

                        Let's start chatting!

                        <span class="time">
                            10:26 AM
                        </span>

                    </div>


                    <div class="message sent">

                        Sure! Let's go.

                        <span class="time">
                            10:27 AM ✓✓
                        </span>

                    </div>


                </div>


                <!-- MESSAGE INPUT -->

                <div class="message-input">


                    <div class="attachment">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="1.8"
                             stroke-linecap="round"
                             stroke-linejoin="round">

                            <path d="m21.4 11.6-8.8 8.8
                                     a6 6 0 0 1-8.5-8.5l8.8-8.8
                                     a4 4 0 0 1 5.7 5.7l-8.8 8.8
                                     a2 2 0 0 1-2.8-2.8l8.1-8.1"/>

                        </svg>

                    </div>


                    <div class="fake-input">
                        Type a message...
                    </div>


                    <div class="send-button">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round">

                            <path d="m22 2-7 20-4-9-9-4Z"/>
                            <path d="M22 2 11 13"/>

                        </svg>

                    </div>


                </div>


            </div>

        </div>


        <!-- FLOATING CARD -->

        <div class="floating-card">

            <div class="heart">

                <svg viewBox="0 0 24 24"
                     width="17"
                     height="17"
                     fill="currentColor">

                    <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0
                             L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1
                             L12 21l7.8-7.6 1-1
                             a5.5 5.5 0 0 0 0-7.8Z"/>

                </svg>

            </div>

            <p>
                Better Conversations<br>
                Stronger Connections
            </p>

        </div>


    </div>

</section>


<!-- =========================================
     FEATURES
========================================= -->

<section class="features"
         id="features">


    <!-- FAST -->

    <div class="feature">

        <div class="feature-icon">

            <svg viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="1.8"
                 stroke-linecap="round"
                 stroke-linejoin="round">

                <path d="m13 2-9 12h7l-1 8
                         9-12h-7l1-8Z"/>

            </svg>

        </div>

        <div>

            <h3>
                Fast
            </h3>

            <p>
                Quick and responsive messaging.
            </p>

        </div>

    </div>


    <!-- SECURE -->

    <div class="feature">

        <div class="feature-icon">

            <svg viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="1.8"
                 stroke-linecap="round"
                 stroke-linejoin="round">

                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7
                         c0 6 8 10 8 10Z"/>

                <path d="m9 12 2 2 4-4"/>

            </svg>

        </div>

        <div>

            <h3>
                Secure
            </h3>

            <p>
                Your conversations stay protected.
            </p>

        </div>

    </div>


    <!-- CONNECT -->

    <div class="feature">

        <div class="feature-icon">

            <svg viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="1.8"
                 stroke-linecap="round"
                 stroke-linejoin="round">

                <circle cx="9" cy="8" r="3"/>

                <circle cx="17" cy="9" r="2.5"/>

                <path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/>

                <path d="M14 15c3.3 0 6 2.2 6 5"/>

            </svg>

        </div>

        <div>

            <h3>
                Connect
            </h3>

            <p>
                Chat and connect with people easily.
            </p>

        </div>

    </div>


    <!-- WEB -->

    <div class="feature">

        <div class="feature-icon">

            <svg viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="1.8"
                 stroke-linecap="round"
                 stroke-linejoin="round">

                <circle cx="12" cy="12" r="9"/>

                <path d="M3 12h18"/>

                <path d="M12 3c2.5 2.5 3.5 5.5 3.5 9
                         S14.5 18.5 12 21"/>

                <path d="M12 3c-2.5 2.5-3.5 5.5-3.5 9
                         S9.5 18.5 12 21"/>

            </svg>

        </div>

        <div>

            <h3>
                Web Based
            </h3>

            <p>
                Access your chat through the browser.
            </p>

        </div>

    </div>


</section>


<!-- =========================================
     FOOTER
========================================= -->

<div class="bottom-text"
     id="about">

    <div class="bottom-line">

        <span></span>

        <div class="bottom-heart">

            <svg viewBox="0 0 24 24"
                 width="16"
                 height="16"
                 fill="currentColor">

                <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0
                         L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1
                         L12 21l7.8-7.6 1-1
                         a5.5 5.5 0 0 0 0-7.8Z"/>

            </svg>

        </div>

        <span></span>

    </div>

    Better Conversations • Stronger Connections

</div>


</body>

</html>