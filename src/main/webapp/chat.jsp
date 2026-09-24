<%@ page import="com.connectchat.model.User" %>
<%@ page import="com.connectchat.model.Message" %>
<%@ page import="java.util.List" %>

<%
    User currentUser =
            (User) session.getAttribute("user");

    if (currentUser == null) {

        response.sendRedirect("login.jsp");
        return;
    }


    List<User> users =
            (List<User>) request.getAttribute("users");

    List<Message> messages =
            (List<Message>) request.getAttribute("messages");

    User receiver =
            (User) request.getAttribute("receiver");

    Integer receiverId =
            (Integer) request.getAttribute("receiverId");


    /*
     * If users were not loaded yet,
     * load the page normally.
     */
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


        /* =========================
           MAIN
        ========================= */

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

            background:
                linear-gradient(
                    180deg,
                    #5146e5,
                    #3932a5
                );

            color: white;

            padding: 28px 24px;

            position: relative;

            overflow-y: auto;
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

            background:
                rgba(255,255,255,0.16);

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


        /* TITLE */

        .section-title {

            font-size: 12px;

            font-weight: 600;

            letter-spacing: 0.5px;

            margin-bottom: 14px;

            opacity: 0.75;
        }


        /* USERS */

        .user-link {

            display: flex;

            align-items: center;

            gap: 13px;

            padding: 14px;

            margin-bottom: 10px;

            border-radius: 16px;

            color: white;

            text-decoration: none;

            background:
                rgba(255,255,255,0.10);

            transition: 0.2s;
        }


        .user-link:hover {

            background:
                rgba(255,255,255,0.22);
        }


        .user-link.active {

            background:
                rgba(255,255,255,0.25);
        }


        .user-avatar {

            width: 46px;
            height: 46px;

            min-width: 46px;

            border-radius: 50%;

            background: white;

            display: flex;

            align-items: center;

            justify-content: center;

            overflow: hidden;
        }


        .user-avatar svg {

            width: 28px;
            height: 28px;
        }


        .user-info {

            min-width: 0;
        }


        .user-name {

            font-size: 16px;

            font-weight: 700;

            white-space: nowrap;

            overflow: hidden;

            text-overflow: ellipsis;
        }


        .user-status {

            font-size: 12px;

            margin-top: 5px;

            opacity: 0.75;
        }


        .online-dot {

            color: #4ade80;
        }


        .no-users {

            color: rgba(255,255,255,0.7);

            font-size: 14px;

            padding: 15px 5px;
        }


        /* LOGOUT */

        .logout {

            margin-top: 30px;
        }


        .logout a {

            display: block;

            text-align: center;

            padding: 13px;

            border-radius: 12px;

            background:
                rgba(255,255,255,0.14);

            color: white;

            text-decoration: none;

            font-weight: 600;
        }


        .logout a:hover {

            background:
                rgba(255,255,255,0.24);
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

            border-bottom:
                1px solid #e5e7eb;
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

            width: 30px;
            height: 30px;
        }


        .chat-user-name {

            color: #111827;

            font-size: 20px;

            font-weight: 700;
        }


        .chat-status {

            color: #22c55e;

            font-size: 13px;

            margin-top: 5px;
        }


        /* =========================
           MESSAGES
        ========================= */

        .messages {

            flex: 1;

            min-height: 0;

            overflow-y: auto;

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


        .empty-icon {

            width: 90px;
            height: 90px;

            margin: auto;

            margin-bottom: 20px;

            border-radius: 28px;

            background: #eef2ff;

            display: flex;

            align-items: center;

            justify-content: center;
        }


        .empty-icon svg {

            width: 50px;
            height: 50px;
        }


        .empty-chat h2 {

            color: #64748b;

            margin-bottom: 8px;
        }


        .empty-chat p {

            color: #94a3b8;
        }


        /* MESSAGE */

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

            max-width: 65%;

            padding: 13px 17px;

            border-radius: 17px;

            background: white;

            color: #334155;

            box-shadow:
                0 2px 8px
                rgba(0,0,0,0.06);

            overflow-wrap: anywhere;
        }


        .message.sent
        .message-bubble {

            background: #5146e5;

            color: white;

            border-bottom-right-radius: 5px;
        }


        .message.received
        .message-bubble {

            border-bottom-left-radius: 5px;
        }


        /* =========================
           INPUT
        ========================= */

        .message-form {

            width: 100%;

            min-height: 82px;

            display: flex;

            align-items: center;

            gap: 12px;

            padding: 16px 25px;

            background: white;

            border-top:
                1px solid #e5e7eb;
        }


        .message-input {

            flex: 1;

            height: 50px;

            border:
                1px solid #d1d5db;

            border-radius: 25px;

            padding: 0 20px;

            outline: none;

            font-size: 15px;
        }


        .message-input:focus {

            border-color: #5146e5;

            box-shadow:
                0 0 0 3px
                rgba(81,70,229,0.1);
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
        }


        .send-button:hover {

            background: #3932a5;
        }


    </style>

</head>


<body>


<div class="app">


    <!-- =========================
         SIDEBAR
    ========================== -->

    <aside class="sidebar">


        <!-- LOGO -->

        <div class="brand">

            <div class="brand-icon">

                <svg viewBox="0 0 64 64">

                    <path
                        d="M10 12h44a6 6 0 0 1 6 6v27a6 6 0 0 1-6 6H34L22 59v-8H10a6 6 0 0 1-6-6V18a6 6 0 0 1 6-6z"
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


        <!-- USERS -->

        <div class="section-title">

            CONVERSATIONS

        </div>


        <%

            if (users != null &&
                !users.isEmpty()) {

                for (User chatUser : users) {

                    boolean active =
                        receiverId != null &&
                        receiverId == chatUser.getId();

        %>


        <a
            class="user-link <%= active ? "active" : "" %>"
            href="messages?receiverId=<%= chatUser.getId() %>">


            <div class="user-avatar">

                <svg viewBox="0 0 64 64">

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


            <div class="user-info">

                <div class="user-name">

                    <%= chatUser.getUsername() %>

                </div>


                <div class="user-status">

                    <span class="online-dot">●</span>

                    Online

                </div>

            </div>


        </a>


        <%

                }

            } else {

        %>


        <div class="no-users">

            No other users registered yet.

        </div>


        <%

            }

        %>


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


        <!-- HEADER -->

        <header class="chat-header">


            <div class="chat-avatar">

                <svg viewBox="0 0 64 64">

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

                <%

                    if (receiver != null) {

                %>


                <div class="chat-user-name">

                    <%= receiver.getUsername() %>

                </div>


                <div class="chat-status">

                    ● Online

                </div>


                <%

                    } else {

                %>


                <div class="chat-user-name">

                    Select a user

                </div>


                <div class="chat-status">

                    Choose someone to start chatting

                </div>


                <%

                    }

                %>

            </div>


        </header>


        <!-- =========================
             MESSAGE AREA
        ========================== -->

        <section class="messages">


            <%

                if (receiver == null) {

            %>


            <div class="empty-chat">

                <div>

                    <div class="empty-icon">

                        <svg viewBox="0 0 64 64">

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

                        Select a conversation

                    </h2>


                    <p>

                        Choose a user from the left.

                    </p>

                </div>

            </div>


            <%

                } else if
                (messages == null ||
                 messages.isEmpty()) {

            %>


            <div class="empty-chat">

                <div>

                    <div class="empty-icon">

                        <svg viewBox="0 0 64 64">

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

                        Send your first message to
                        <%= receiver.getUsername() %>

                    </p>

                </div>

            </div>


            <%

                } else {

                    for (Message msg : messages) {

                        boolean sent =
                            msg.getSenderId()
                            == currentUser.getId();

            %>


            <div class="message
                <%= sent ? "sent" : "received" %>">


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
             SEND MESSAGE
        ========================== -->


        <%

            if (receiver != null) {

        %>


        <form
            class="message-form"
            action="messages"
            method="post">


            <input
                type="hidden"
                name="receiverId"
                value="<%= receiver.getId() %>">


            <input
                type="text"
                name="message"
                class="message-input"
                placeholder="Type a message..."
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