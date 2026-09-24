<%@ page import="com.connectchat.model.User" %>
<%@ page import="com.connectchat.model.Message" %>
<%@ page import="java.util.List" %>

<%
    User currentUser = (User) session.getAttribute("user");

    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Message> messages =
        (List<Message>) request.getAttribute("messages");

    Integer receiverId =
        (Integer) request.getAttribute("receiverId");

    /*
     * If receiverId was not supplied by MessageServlet,
     * read it from the URL.
     */
    if (receiverId == null) {
        String receiverParam = request.getParameter("receiverId");

        if (receiverParam != null && !receiverParam.isEmpty()) {
            try {
                receiverId = Integer.parseInt(receiverParam);
            } catch (NumberFormatException e) {
                receiverId = null;
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>

    <meta charset="UTF-8">

    <title>ConnectChat</title>

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html,
        body {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f5f7fb;
        }

        /* MAIN APP */

        .app {
            width: 100%;
            height: 100vh;
            display: flex;
            overflow: hidden;
        }

        /* =========================
           SIDEBAR
        ========================= */

        .sidebar {
            width: 320px;
            min-width: 320px;
            height: 100vh;
            background: linear-gradient(
                180deg,
                #5146e5 0%,
                #3932a5 100%
            );
            color: white;
            padding: 28px 24px;
            position: relative;
            overflow: hidden;
        }

        /* LOGO */

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 35px;
        }

        .brand-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
        }

        .brand-icon svg {
            width: 32px;
            height: 32px;
        }

        .brand-name {
            font-size: 28px;
            font-weight: 700;
        }

        /* PROFILE */

        .profile {
            background: rgba(255,255,255,0.16);
            border-radius: 18px;
            padding: 20px;
            margin-bottom: 30px;
        }

        .profile-name {
            font-size: 19px;
            font-weight: 700;
            margin-bottom: 7px;
        }

        .profile-email {
            font-size: 13px;
            opacity: 0.85;
            word-break: break-word;
        }

        /* CONVERSATION TITLE */

        .section-title {
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.5px;
            margin-bottom: 14px;
            opacity: 0.75;
        }

        /* CONTACT */

        .contact {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 15px;
            border-radius: 16px;
            background: rgba(255,255,255,0.16);
            color: white;
            text-decoration: none;
            transition: 0.2s;
        }

        .contact:hover {
            background: rgba(255,255,255,0.24);
        }

        .contact-avatar {
            width: 46px;
            height: 46px;
            min-width: 46px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .contact-avatar svg {
            width: 25px;
            height: 25px;
        }

        .contact-info {
            min-width: 0;
        }

        .contact-name {
            font-size: 16px;
            font-weight: 700;
        }

        .contact-status {
            font-size: 13px;
            margin-top: 5px;
            opacity: 0.8;
        }

        .status-dot {
            color: #4ade80;
        }

        /* LOGOUT */

        .logout {
            position: absolute;
            left: 24px;
            right: 24px;
            bottom: 25px;
        }

        .logout a {
            display: block;
            text-align: center;
            padding: 13px;
            border-radius: 12px;
            background: rgba(255,255,255,0.14);
            color: white;
            text-decoration: none;
            font-weight: 600;
            transition: 0.2s;
        }

        .logout a:hover {
            background: rgba(255,255,255,0.23);
        }

        /* =========================
           CHAT AREA
        ========================= */

        .chat-area {
            flex: 1;
            min-width: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            background: #f8fafc;
        }

        /* HEADER */

        .chat-header {
            height: 88px;
            min-height: 88px;
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 0 30px;
            background: white;
            border-bottom: 1px solid #e5e7eb;
        }

        .chat-avatar {
            width: 54px;
            height: 54px;
            min-width: 54px;
            border-radius: 50%;
            background: #5146e5;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .chat-avatar svg {
            width: 29px;
            height: 29px;
        }

        .chat-user-name {
            color: #111827;
            font-size: 20px;
            font-weight: 700;
        }

        .online {
            color: #22c55e;
            font-size: 13px;
            margin-top: 5px;
        }

        /* =========================
           MESSAGE AREA
        ========================= */

        .messages {
            flex: 1;
            min-height: 0;
            min-width: 0;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 30px;
        }

        .empty-chat {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
        }

        .empty-content {
            max-width: 350px;
        }

        .empty-icon {
            width: 90px;
            height: 90px;
            margin: 0 auto 20px;
            border-radius: 28px;
            background: #eef2ff;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .empty-icon svg {
            width: 52px;
            height: 52px;
        }

        .empty-content h2 {
            color: #64748b;
            font-size: 25px;
            margin-bottom: 8px;
        }

        .empty-content p {
            color: #94a3b8;
            font-size: 15px;
        }

        /* MESSAGES */

        .message {
            display: flex;
            width: 100%;
            margin-bottom: 16px;
        }

        .message.sent {
            justify-content: flex-end;
        }

        .message.received {
            justify-content: flex-start;
        }

        .message-bubble {
            max-width: min(65%, 600px);
            padding: 13px 17px;
            border-radius: 17px;
            background: white;
            color: #334155;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow-wrap: anywhere;
        }

        .message.sent .message-bubble {
            background: #5146e5;
            color: white;
            border-bottom-right-radius: 5px;
        }

        .message.received .message-bubble {
            border-bottom-left-radius: 5px;
        }

        /* =========================
           MESSAGE INPUT
        ========================= */

        .message-form {
            width: 100%;
            min-height: 82px;
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 25px;
            background: white;
            border-top: 1px solid #e5e7eb;
        }

        .message-input {
            flex: 1;
            min-width: 0;
            height: 50px;
            border: 1px solid #d1d5db;
            border-radius: 25px;
            padding: 0 20px;
            outline: none;
            font-size: 15px;
            color: #334155;
        }

        .message-input:focus {
            border-color: #5146e5;
            box-shadow: 0 0 0 3px rgba(81,70,229,0.1);
        }

        .send-button {
            height: 50px;
            border: none;
            border-radius: 25px;
            padding: 0 25px;
            background: #5146e5;
            color: white;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: 0.2s;
        }

        .send-button:hover {
            background: #3932a5;
        }

        /* MOBILE */

        @media (max-width: 700px) {

            .sidebar {
                width: 230px;
                min-width: 230px;
                padding: 20px 15px;
            }

            .brand-name {
                font-size: 21px;
            }

            .profile-email {
                font-size: 11px;
            }

            .chat-header {
                padding: 0 18px;
            }

            .messages {
                padding: 18px;
            }

            .message-form {
                padding: 12px;
            }

            .send-button {
                padding: 0 17px;
            }
        }

    </style>

</head>

<body>

<div class="app">

    <!-- =========================
         SIDEBAR
    ========================== -->

    <aside class="sidebar">

        <!-- LOGO ICON -->

        <div class="brand">

            <div class="brand-icon">

                <!-- CHAT ICON -->

                <svg viewBox="0 0 64 64"
                     xmlns="http://www.w3.org/2000/svg">

                    <path
                        d="M10 12h44a6 6 0 0 1 6 6v27a6 6 0 0 1-6 6H34L22 59v-8H10a6 6 0 0 1-6-6V18a6 6 0 0 1 6-6z"
                        fill="#5146e5"/>

                    <circle cx="22" cy="31" r="4" fill="white"/>
                    <circle cx="32" cy="31" r="4" fill="white"/>
                    <circle cx="42" cy="31" r="4" fill="white"/>

                </svg>

            </div>

            <div class="brand-name">
                ConnectChat
            </div>

        </div>


        <!-- PROFILE -->

        <div class="profile">

            <div class="profile-name">
                <%= currentUser.getUsername() %>
            </div>

            <div class="profile-email">
                <%= currentUser.getEmail() %>
            </div>

        </div>


        <!-- CONVERSATIONS -->

        <div class="section-title">
            CONVERSATIONS
        </div>


        <!-- CONTACT -->

        <%
            /*
             * Change 2 to the ID of another registered user
             * if your second user's ID is different.
             */
            int chatUserId = 2;
        %>

        <a class="contact"
           href="messages?receiverId=<%= chatUserId %>">

            <div class="contact-avatar">

                <svg viewBox="0 0 64 64"
                     xmlns="http://www.w3.org/2000/svg">

                    <circle
                        cx="32"
                        cy="32"
                        r="30"
                        fill="#5146e5"/>

                    <circle
                        cx="32"
                        cy="25"
                        r="10"
                        fill="white"/>

                    <path
                        d="M15 51c3-11 10-16 17-16s14 5 17 16"
                        fill="white"/>

                </svg>

            </div>

            <div class="contact-info">

                <div class="contact-name">
                    Chat User
                </div>

                <div class="contact-status">
                    <span class="status-dot">●</span>
                    Online
                </div>

            </div>

        </a>


        <!-- LOGOUT -->

        <div class="logout">

            <a href="logout">
                Logout
            </a>

        </div>

    </aside>


    <!-- =========================
         CHAT AREA
    ========================== -->

    <main class="chat-area">


        <!-- CHAT HEADER -->

        <header class="chat-header">

            <div class="chat-avatar">

                <svg viewBox="0 0 64 64"
                     xmlns="http://www.w3.org/2000/svg">

                    <circle
                        cx="32"
                        cy="32"
                        r="30"
                        fill="white"/>

                    <circle
                        cx="32"
                        cy="25"
                        r="10"
                        fill="#5146e5"/>

                    <path
                        d="M15 51c3-11 10-16 17-16s14 5 17 16"
                        fill="#5146e5"/>

                </svg>

            </div>

            <div>

                <div class="chat-user-name">
                    Chat User
                </div>

                <div class="online">
                    ● Online
                </div>

            </div>

        </header>


        <!-- =========================
             MESSAGES
        ========================== -->

        <section class="messages">

            <%
                if (messages == null || messages.isEmpty()) {
            %>

                <div class="empty-chat">

                    <div class="empty-content">

                        <div class="empty-icon">

                            <!-- CHAT PICTURE ICON -->

                            <svg viewBox="0 0 64 64"
                                 xmlns="http://www.w3.org/2000/svg">

                                <path
                                    d="M10 10h44a7 7 0 0 1 7 7v27a7 7 0 0 1-7 7H35L22 59v-8H10a7 7 0 0 1-7-7V17a7 7 0 0 1 7-7z"
                                    fill="#5146e5"/>

                                <circle
                                    cx="22"
                                    cy="31"
                                    r="4"
                                    fill="white"/>

                                <circle
                                    cx="32"
                                    cy="31"
                                    r="4"
                                    fill="white"/>

                                <circle
                                    cx="42"
                                    cy="31"
                                    r="4"
                                    fill="white"/>

                            </svg>

                        </div>

                        <h2>
                            Start a conversation
                        </h2>

                        <p>
                            Send your first message!
                        </p>

                    </div>

                </div>

            <%
                } else {

                    for (Message msg : messages) {

                        boolean sent =
                            msg.getSenderId() ==
                            currentUser.getId();
            %>

                <div class="message <%= sent ? "sent" : "received" %>">

                    <div class="message-bubble">

                        <%= msg.getMessage() %>

                    </div>

                </div>

            <%
                    }
                }
            %>

        </section>


        <!-- =========================
             MESSAGE INPUT
        ========================== -->

        <%
            if (receiverId != null) {
        %>

        <form
            class="message-form"
            action="messages"
            method="post">

            <input
                type="hidden"
                name="receiverId"
                value="<%= receiverId %>">

            <input
                type="text"
                name="message"
                class="message-input"
                placeholder="Type your message..."
                autocomplete="off"
                required>

            <button
                type="submit"
                class="send-button">

                Send

            </button>

        </form>

        <%
            }
        %>

    </main>

</div>

</body>
</html>