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

    String contextPath =
            request.getContextPath();

    String currentProfile =
            currentUser.getProfilePicture();

    if (currentProfile == null ||
            currentProfile.trim().isEmpty()) {

        currentProfile = "default.png";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>ConnectChat</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            background: #eef2f7;
            height: 100vh;
            overflow: hidden;
        }

        .app-container {
            width: 100%;
            height: 100vh;
            display: flex;
        }

        /* =========================
           LEFT SIDEBAR
           ========================= */

        .sidebar {
            width: 340px;
            height: 100vh;
            background: #ffffff;
            border-right: 1px solid #e5e7eb;
            display: flex;
            flex-direction: column;
        }

        .sidebar-header {
            height: 75px;
            padding: 15px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #eeeeee;
        }

        .brand {
            font-size: 23px;
            font-weight: 700;
            color: #2563eb;
        }

        .brand span {
            color: #111827;
        }

        .profile-small {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .profile-small img {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #2563eb;
        }

        .profile-small-name {
            font-size: 14px;
            font-weight: 600;
            color: #1f2937;
        }

        /* =========================
           PROFILE AREA
           ========================= */

        .profile-section {
            padding: 20px;
            background: linear-gradient(
                135deg,
                #2563eb,
                #4f46e5
            );
            color: white;
        }

        .profile-main {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .profile-main img {
            width: 65px;
            height: 65px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid white;
        }

        .profile-info h3 {
            font-size: 17px;
            margin-bottom: 5px;
        }

        .profile-info p {
            font-size: 13px;
            opacity: 0.9;
        }

        .change-photo-button {
            width: 100%;
            margin-top: 15px;
            padding: 10px;
            border: 1px solid rgba(255,255,255,0.4);
            border-radius: 8px;
            background: rgba(255,255,255,0.15);
            color: white;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        .change-photo-button:hover {
            background: rgba(255,255,255,0.25);
        }

        /* =========================
           SEARCH
           ========================= */

        .search-box {
            padding: 15px;
            border-bottom: 1px solid #eeeeee;
        }

        .search-box input {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            outline: none;
            font-size: 14px;
            background: #f8fafc;
        }

        .search-box input:focus {
            border-color: #2563eb;
        }

        /* =========================
           USER LIST
           ========================= */

        .users-title {
            padding: 15px 20px 8px;
            font-size: 12px;
            font-weight: 700;
            color: #6b7280;
            text-transform: uppercase;
        }

        .users-list {
            flex: 1;
            overflow-y: auto;
        }

        .user-link {
            text-decoration: none;
            color: inherit;
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 13px 18px;
            border-bottom: 1px solid #f1f5f9;
            cursor: pointer;
            transition: 0.2s;
        }

        .user-link:hover {
            background: #f1f5f9;
        }

        .user-link.active {
            background: #e8f0ff;
            border-left: 4px solid #2563eb;
        }

        .user-avatar {
            position: relative;
            flex-shrink: 0;
        }

        .user-avatar img {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid #e5e7eb;
        }

        .user-details {
            min-width: 0;
            flex: 1;
        }

        .user-name {
            font-size: 15px;
            font-weight: 600;
            color: #111827;
            margin-bottom: 5px;
        }

        .user-status {
            font-size: 12px;
            color: #9ca3af;
        }

        .online-dot {
            color: #22c55e;
            font-size: 10px;
            margin-right: 4px;
        }

        .offline-dot {
            color: #9ca3af;
            font-size: 10px;
            margin-right: 4px;
        }

        /* =========================
           CHAT AREA
           ========================= */

        .chat-container {
            flex: 1;
            height: 100vh;
            display: flex;
            flex-direction: column;
            background: #f8fafc;
        }

        .chat-header {
            height: 75px;
            background: white;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            padding: 12px 22px;
        }

        .chat-header-user {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .chat-header-user img {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid #e5e7eb;
        }

        .chat-header-info h3 {
            font-size: 16px;
            color: #111827;
            margin-bottom: 5px;
        }

        .chat-status {
            font-size: 12px;
            color: #9ca3af;
        }

        /* =========================
           EMPTY CHAT
           ========================= */

        .empty-chat {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 30px;
        }

        .empty-chat-content {
            max-width: 420px;
        }

        .empty-chat-content h2 {
            color: #1f2937;
            margin-bottom: 10px;
            font-size: 25px;
        }

        .empty-chat-content p {
            color: #6b7280;
            line-height: 1.6;
            font-size: 14px;
        }

        /* =========================
           MESSAGES
           ========================= */

        .messages-area {
            flex: 1;
            padding: 25px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .message {
            display: flex;
            width: 100%;
        }

        .message.sent {
            justify-content: flex-end;
        }

        .message.received {
            justify-content: flex-start;
        }

        .message-bubble {
            max-width: 65%;
            padding: 11px 15px;
            border-radius: 14px;
            font-size: 14px;
            line-height: 1.5;
            word-wrap: break-word;
        }

        .message.sent .message-bubble {
            background: #2563eb;
            color: white;
            border-bottom-right-radius: 4px;
        }

        .message.received .message-bubble {
            background: white;
            color: #1f2937;
            border: 1px solid #e5e7eb;
            border-bottom-left-radius: 4px;
        }

        /* =========================
           MESSAGE FORM
           ========================= */

        .message-form-container {
            padding: 15px 20px;
            background: white;
            border-top: 1px solid #e5e7eb;
        }

        .message-form {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .message-input {
            flex: 1;
            padding: 13px 16px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            outline: none;
            font-size: 14px;
            background: #f9fafb;
        }

        .message-input:focus {
            border-color: #2563eb;
            background: white;
        }

        .send-button {
            padding: 13px 24px;
            border: none;
            border-radius: 10px;
            background: #2563eb;
            color: white;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        .send-button:hover {
            background: #1d4ed8;
        }

        .send-button:disabled {
            background: #9ca3af;
            cursor: not-allowed;
        }

        /* =========================
           SCROLLBAR
           ========================= */

        ::-webkit-scrollbar {
            width: 6px;
        }

        ::-webkit-scrollbar-track {
            background: transparent;
        }

        ::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 10px;
        }

        /* =========================
           RESPONSIVE
           ========================= */

        @media (max-width: 800px) {

            .sidebar {
                width: 280px;
            }

            .message-bubble {
                max-width: 80%;
            }
        }

        @media (max-width: 600px) {

            .sidebar {
                width: 100%;
            }

            .chat-container {
                display: none;
            }

            .sidebar-header {
                height: 65px;
            }
        }

    </style>

</head>

<body>

<div class="app-container">

    <!-- ==========================================
         LEFT SIDEBAR
         ========================================== -->

    <aside class="sidebar">

        <!-- Header -->

        <div class="sidebar-header">

            <div class="brand">
                Connect<span>Chat</span>
            </div>

            <div class="profile-small">

                <img
                    src="<%= contextPath %>/uploads/profiles/<%= currentProfile %>"
                    alt="Profile"
                    onerror="this.src='<%= contextPath %>/uploads/profiles/default.png'"
                >

            </div>

        </div>


        <!-- Current User Profile -->

        <div class="profile-section">

            <div class="profile-main">

                <img
                    src="<%= contextPath %>/uploads/profiles/<%= currentProfile %>"
                    alt="Profile"
                    onerror="this.src='<%= contextPath %>/uploads/profiles/default.png'"
                >

                <div class="profile-info">

                    <h3>
                        <%= currentUser.getUsername() %>
                    </h3>

                    <p>
                        <%= currentUser.getEmail() %>
                    </p>

                </div>

            </div>


            <!-- Profile Picture Form -->

            <form
                id="photoForm"
                action="<%= contextPath %>/profile"
                method="post"
                enctype="multipart/form-data"
            >

                <input
                    type="file"
                    id="profilePicture"
                    name="profilePicture"
                    accept="image/png,image/jpeg,image/jpg,image/webp"
                    style="display:none"
                    onchange="document.getElementById('photoForm').submit();"
                >

                <button
                    type="button"
                    class="change-photo-button"
                    onclick="document.getElementById('profilePicture').click();"
                >
                    Change Photo
                </button>

            </form>

        </div>


        <!-- Search -->

        <div class="search-box">

            <input
                type="text"
                id="searchUsers"
                placeholder="Search users..."
                autocomplete="off"
            >

        </div>


        <div class="users-title">
            Users
        </div>


        <!-- User List -->

        <div class="users-list" id="usersList">

            <%
                if (users != null && !users.isEmpty()) {

                    for (User chatUser : users) {

                        boolean active =
                                receiverId != null &&
                                receiverId == chatUser.getId();

                        String profile =
                                chatUser.getProfilePicture();

                        if (profile == null ||
                                profile.trim().isEmpty()) {

                            profile = "default.png";
                        }
            %>

            <a
                href="<%= contextPath %>/messages?receiverId=<%= chatUser.getId() %>"
                class="user-link <%= active ? "active" : "" %>"
                data-user-id="<%= chatUser.getId() %>"
            >

                <div class="user-avatar">

                    <img
                        src="<%= contextPath %>/uploads/profiles/<%= profile %>"
                        alt="Profile"
                        onerror="this.src='<%= contextPath %>/uploads/profiles/default.png'"
                    >

                </div>


                <div class="user-details">

                    <div class="user-name">
                        <%= chatUser.getUsername() %>
                    </div>

                    <div class="user-status">

                        <span class="offline-dot">
                            ●
                        </span>

                        Offline

                    </div>

                </div>

            </a>

            <%
                    }

                } else {
            %>

            <div style="
                padding:30px 20px;
                text-align:center;
                color:#9ca3af;
                font-size:14px;
            ">
                No other users found.
            </div>

            <%
                }
            %>

        </div>

    </aside>


    <!-- ==========================================
         CHAT AREA
         ========================================== -->

    <main class="chat-container">


        <%
            if (receiver != null) {

                String receiverProfile =
                        receiver.getProfilePicture();

                if (receiverProfile == null ||
                        receiverProfile.trim().isEmpty()) {

                    receiverProfile = "default.png";
                }
        %>


        <!-- Chat Header -->

        <header class="chat-header">

            <div class="chat-header-user">

                <img
                    src="<%= contextPath %>/uploads/profiles/<%= receiverProfile %>"
                    alt="Profile"
                    onerror="this.src='<%= contextPath %>/uploads/profiles/default.png'"
                >

                <div class="chat-header-info">

                    <h3>
                        <%= receiver.getUsername() %>
                    </h3>

                    <div
                        class="chat-status"
                        id="chatStatus"
                    >

                        <span class="offline-dot">
                            ●
                        </span>

                        Offline

                    </div>

                </div>

            </div>

        </header>


        <!-- Messages -->

        <div
            class="messages-area"
            id="messagesArea"
        >

            <%
                if (messages != null &&
                        !messages.isEmpty()) {

                    for (Message message : messages) {

                        boolean sent =
                                message.getSenderId()
                                == currentUser.getId();
            %>

            <div
                class="message <%= sent ? "sent" : "received" %>"
            >

                <div class="message-bubble">

                    <%= message.getMessage() %>

                </div>

            </div>

            <%
                    }

                } else {
            %>

            <div
                id="emptyConversation"
                style="
                    text-align:center;
                    color:#9ca3af;
                    font-size:14px;
                    margin:auto;
                "
            >
                No messages yet. Start the conversation.
            </div>

            <%
                }
            %>

        </div>


        <!-- Message Input -->

        <div class="message-form-container">

            <div class="message-form">

                <input
                    type="text"
                    id="messageInput"
                    class="message-input"
                    placeholder="Type a message..."
                    autocomplete="off"
                >

                <button
                    type="button"
                    id="sendButton"
                    class="send-button"
                    onclick="sendMessage()"
                >
                    Send
                </button>

            </div>

        </div>


        <%
            } else {
        %>


        <!-- No Chat Selected -->

        <div class="empty-chat">

            <div class="empty-chat-content">

                <h2>
                    Welcome to ConnectChat
                </h2>

                <p>
                    Select a user from the left side
                    to start a conversation.
                </p>

            </div>

        </div>


        <%
            }
        %>

    </main>

</div>


<script>

    /* ==========================================
       USER INFORMATION
       ========================================== */

    const currentUserId =
        <%= currentUser.getId() %>;

    const receiverId =
        <%= receiverId != null
                ? receiverId
                : "null" %>;

    const contextPath =
        "<%= contextPath %>";


    /* ==========================================
       WEBSOCKET
       ========================================== */

    let socket = null;

    let reconnectTimer = null;


    function connectWebSocket() {

        if (socket !== null &&
            socket.readyState === WebSocket.OPEN) {

            return;
        }


        const protocol =
            window.location.protocol === "https:"
                ? "wss://"
                : "ws://";


        const socketUrl =
            protocol +
            window.location.host +
            contextPath +
            "/chat?userId=" +
            currentUserId;


        console.log(
            "Connecting WebSocket:",
            socketUrl
        );


        socket =
            new WebSocket(socketUrl);


        socket.onopen =
            function () {

                console.log(
                    "WebSocket connected"
                );

                const sendButton =
                    document.getElementById(
                        "sendButton"
                    );

                if (sendButton) {

                    sendButton.disabled = false;

                }

            };


        socket.onmessage =
            function (event) {

                const data =
                    event.data;


                console.log(
                    "WebSocket message:",
                    data
                );


                /* Online users */

                if (
                    data.startsWith("ONLINE|")
                ) {

                    const onlineIds =
                        data.substring(7);

                    updateOnlineUsers(
                        onlineIds
                    );

                    return;
                }


                /* Chat message */

                if (
                    data.startsWith("MESSAGE|")
                ) {

                    displayIncomingMessage(
                        data
                    );

                    return;
                }

            };


        socket.onclose =
            function () {

                console.log(
                    "WebSocket disconnected"
                );


                const sendButton =
                    document.getElementById(
                        "sendButton"
                    );

                if (sendButton) {

                    sendButton.disabled = true;

                }


                clearTimeout(
                    reconnectTimer
                );


                reconnectTimer =
                    setTimeout(
                        connectWebSocket,
                        3000
                    );

            };


        socket.onerror =
            function (error) {

                console.error(
                    "WebSocket error:",
                    error
                );

            };

    }


    /* ==========================================
       SEND MESSAGE
       ========================================== */

    function sendMessage() {

        const input =
            document.getElementById(
                "messageInput"
            );


        if (!input) {
            return;
        }


        const message =
            input.value.trim();


        if (message === "") {

            return;

        }


        if (receiverId === null) {

            return;

        }


        if (
            socket === null ||
            socket.readyState !== WebSocket.OPEN
        ) {

            alert(
                "Chat connection is not ready. Please wait."
            );

            return;

        }


        const data =
            "PRIVATE|" +
            currentUserId +
            "|" +
            receiverId +
            "|" +
            message;


        socket.send(data);


        input.value = "";

        input.focus();

    }


    /* ==========================================
       DISPLAY RECEIVED MESSAGE
       ========================================== */

    function displayIncomingMessage(data) {

        const parts =
            data.split("|");


        if (parts.length < 4) {

            return;

        }


        const senderId =
            parseInt(parts[1]);


        const receivedReceiverId =
            parseInt(parts[2]);


        const message =
            parts.slice(3).join("|");


        /*
         * Only display messages belonging
         * to the currently opened conversation.
         */

        if (receiverId === null) {

            return;

        }


        if (
            senderId !== currentUserId &&
            senderId !== receiverId
        ) {

            return;

        }


        if (
            receivedReceiverId !== currentUserId &&
            receivedReceiverId !== receiverId
        ) {

            return;

        }


        const messagesArea =
            document.getElementById(
                "messagesArea"
            );


        if (!messagesArea) {

            return;

        }


        /* Remove "No messages yet" */

        const emptyConversation =
            document.getElementById(
                "emptyConversation"
            );


        if (emptyConversation) {

            emptyConversation.remove();

        }


        const messageDiv =
            document.createElement(
                "div"
            );


        if (senderId === currentUserId) {

            messageDiv.className =
                "message sent";

        } else {

            messageDiv.className =
                "message received";

        }


        const bubble =
            document.createElement(
                "div"
            );


        bubble.className =
            "message-bubble";


        /*
         * textContent is used instead of
         * innerHTML for message safety.
         */

        bubble.textContent =
            message;


        messageDiv.appendChild(
            bubble
        );


        messagesArea.appendChild(
            messageDiv
        );


        scrollToBottom();

    }


    /* ==========================================
       ONLINE / OFFLINE USERS
       ========================================== */

    function updateOnlineUsers(
        userIds
    ) {

        const onlineIds =
            userIds
                .split(",")
                .filter(
                    function(id) {
                        return id !== "";
                    }
                )
                .map(
                    function(id) {
                        return parseInt(id);
                    }
                );


        /*
         * Update users in sidebar
         */

        document
            .querySelectorAll(".user-link")
            .forEach(
                function(userElement) {

                    const userId =
                        parseInt(
                            userElement.dataset.userId
                        );


                    const statusElement =
                        userElement.querySelector(
                            ".user-status"
                        );


                    if (!statusElement) {

                        return;

                    }


                    if (
                        onlineIds.includes(
                            userId
                        )
                    ) {

                        statusElement.innerHTML =
                            '<span class="online-dot">●</span> Online';

                    } else {

                        statusElement.innerHTML =
                            '<span class="offline-dot">●</span> Offline';

                    }

                }
            );


        /*
         * Update selected user's status
         */

        if (receiverId !== null) {

            const headerStatus =
                document.getElementById(
                    "chatStatus"
                );


            if (headerStatus) {

                if (
                    onlineIds.includes(
                        receiverId
                    )
                ) {

                    headerStatus.innerHTML =
                        '<span class="online-dot">●</span> Online';

                } else {

                    headerStatus.innerHTML =
                        '<span class="offline-dot">●</span> Offline';

                }

            }

        }

    }


    /* ==========================================
       SEARCH USERS
       ========================================== */

    const searchInput =
        document.getElementById(
            "searchUsers"
        );


    if (searchInput) {

        searchInput.addEventListener(
            "input",
            function() {

                const searchText =
                    this.value
                        .toLowerCase()
                        .trim();


                const userLinks =
                    document.querySelectorAll(
                        ".user-link"
                    );


                userLinks.forEach(
                    function(userLink) {

                        const name =
                            userLink
                                .querySelector(
                                    ".user-name"
                                )
                                .textContent
                                .toLowerCase();


                        if (
                            name.includes(
                                searchText
                            )
                        ) {

                            userLink.style.display =
                                "flex";

                        } else {

                            userLink.style.display =
                                "none";

                        }

                    }
                );

            }
        );

    }


    /* ==========================================
       ENTER TO SEND
       ========================================== */

    const messageInput =
        document.getElementById(
            "messageInput"
        );


    if (messageInput) {

        messageInput.addEventListener(
            "keydown",
            function(event) {

                if (
                    event.key === "Enter" &&
                    !event.shiftKey
                ) {

                    event.preventDefault();

                    sendMessage();

                }

            }
        );

    }


    /* ==========================================
       SCROLL TO BOTTOM
       ========================================== */

    function scrollToBottom() {

        const messagesArea =
            document.getElementById(
                "messagesArea"
            );


        if (messagesArea) {

            messagesArea.scrollTop =
                messagesArea.scrollHeight;

        }

    }


    /* ==========================================
       START APPLICATION
       ========================================== */

    document.addEventListener(
        "DOMContentLoaded",
        function() {

            scrollToBottom();

            connectWebSocket();

        }
    );

</script>


</body>

</html>