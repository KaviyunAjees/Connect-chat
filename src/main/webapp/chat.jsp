<%@ page import="com.connectchat.model.User" %>
<%@ page import="com.connectchat.model.Message" %>
<%@ page import="com.connectchat.model.ChatGroup" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User currentUser =
            (User) session.getAttribute("user");

    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<User> users =
            (List<User>) request.getAttribute("users");

    if (users == null) {
        users = new ArrayList<>();
    }

    List<Message> messages =
            (List<Message>) request.getAttribute("messages");

    if (messages == null) {
        messages = new ArrayList<>();
    }

    User receiver =
            (User) request.getAttribute("receiver");

    List<ChatGroup> groups =
            (List<ChatGroup>) request.getAttribute("groups");

    if (groups == null) {
        groups = new ArrayList<>();
    }

    ChatGroup selectedGroup =
            (ChatGroup) request.getAttribute("selectedGroup");

    /*
     * MessageServlet now returns List<Message>
     * for group messages.
     */
    List<Message> groupMessages =
            (List<Message>) request.getAttribute("groupMessages");

    if (groupMessages == null) {
        groupMessages = new ArrayList<>();
    }

    Integer receiverId =
            (Integer) request.getAttribute("receiverId");

    Integer groupId =
            (Integer) request.getAttribute("groupId");

    String profilePicture =
            currentUser.getProfilePicture();

    if (profilePicture == null ||
            profilePicture.trim().isEmpty()) {

        profilePicture = "default.png";
    }
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>ConnectChat</title>


    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }


        body {
            font-family:
                Arial,
                Helvetica,
                sans-serif;

            background: #f3f6fb;

            height: 100vh;

            overflow: hidden;
        }


        .app {
            width: 100%;
            height: 100vh;

            display: flex;

            background: white;
        }


        /* =========================================
           SIDEBAR
           ========================================= */

        .sidebar {
            width: 365px;
            min-width: 365px;

            height: 100vh;

            background: white;

            border-right:
                1px solid #e5e7eb;

            display: flex;

            flex-direction: column;
        }


        /* =========================================
           LOGO
           ========================================= */

        .logo-section {
            height: 78px;

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding: 0 25px;

            border-bottom:
                1px solid #e5e7eb;
        }


        .logo {
            font-size: 25px;

            font-weight: 700;

            color: #2563eb;
        }


        .logo span {
            color: #111827;
        }


        .small-profile {
            width: 45px;
            height: 45px;

            border-radius: 50%;

            object-fit: cover;

            border:
                2px solid #2563eb;
        }


        /* =========================================
           PROFILE
           ========================================= */

        .profile-section {
            padding: 20px;

            background:
                linear-gradient(
                    135deg,
                    #315bea,
                    #5145e5
                );

            color: white;
        }


        .profile-main {
            display: flex;

            align-items: center;

            gap: 15px;
        }


        .profile-image {
            width: 70px;
            height: 70px;

            border-radius: 50%;

            object-fit: cover;

            border:
                3px solid white;
        }


        .profile-details {
            min-width: 0;
        }


        .profile-name {
            font-size: 17px;

            font-weight: 700;

            margin-bottom: 5px;
        }


        .profile-email {
            font-size: 13px;

            opacity: 0.9;

            white-space: nowrap;

            overflow: hidden;

            text-overflow: ellipsis;
        }


        .change-photo {
            display: block;

            width: 100%;

            margin-top: 15px;

            padding: 10px;

            border:
                1px solid
                rgba(255,255,255,0.55);

            border-radius: 8px;

            text-align: center;

            cursor: pointer;

            font-size: 14px;

            font-weight: 600;

            color: white;

            background:
                rgba(255,255,255,0.08);
        }


        .change-photo:hover {
            background:
                rgba(255,255,255,0.18);
        }


        /* =========================================
           SEARCH
           ========================================= */

        .search-section {
            padding: 16px 15px;

            border-bottom:
                1px solid #e5e7eb;
        }


        .search-input {
            width: 100%;

            padding: 12px 14px;

            border:
                1px solid #d9dee7;

            border-radius: 9px;

            outline: none;

            font-size: 14px;

            background: #f8fafc;
        }


        .search-input:focus {
            border-color: #2563eb;

            background: white;
        }


        /* =========================================
           SIDEBAR CONTENT
           ========================================= */

        .sidebar-content {
            flex: 1;

            overflow-y: auto;
        }


        .section {
            padding: 17px 15px;
        }


        .section-title {
            font-size: 12px;

            font-weight: 700;

            color: #6b7280;

            letter-spacing: 0.7px;

            margin-bottom: 10px;
        }


        /* =========================================
           USERS
           ========================================= */

        .user-item {
            display: flex;

            align-items: center;

            gap: 12px;

            width: 100%;

            padding: 11px;

            margin-bottom: 3px;

            border-radius: 9px;

            text-decoration: none;

            color: #111827;

            transition:
                background 0.15s;
        }


        .user-item:hover {
            background: #f3f6fb;
        }


        .user-item.active {
            background: #eaf1ff;

            border-left:
                3px solid #2563eb;
        }


        .user-avatar-container {
            position: relative;

            width: 47px;
            height: 47px;

            flex-shrink: 0;
        }


        .user-avatar {
            width: 47px;
            height: 47px;

            border-radius: 50%;

            object-fit: cover;
        }


        /* =========================================
           ONLINE / OFFLINE
           ========================================= */

        .status-dot {
            position: absolute;

            right: -1px;

            bottom: 1px;

            width: 11px;
            height: 11px;

            border-radius: 50%;

            background: #ef4444;

            border:
                2px solid white;
        }


        .status-dot.online {
            background: #22c55e;
        }


        .user-info {
            min-width: 0;

            flex: 1;
        }


        .user-name {
            font-size: 15px;

            font-weight: 600;

            white-space: nowrap;

            overflow: hidden;

            text-overflow: ellipsis;
        }


        .user-status {
            display: flex;

            align-items: center;

            gap: 5px;

            margin-top: 4px;

            font-size: 12px;

            color: #ef4444;
        }


        .user-status.online-text {
            color: #22c55e;
        }


        .no-users {
            padding: 15px 5px;

            color: #9ca3af;

            text-align: center;

            font-size: 13px;
        }


        /* =========================================
           GROUPS
           ========================================= */

        .group-section {
            padding: 15px;

            border-top:
                1px solid #e5e7eb;
        }


        .create-group-btn {
            width: 100%;

            padding: 10px;

            border: none;

            border-radius: 8px;

            background: #2563eb;

            color: white;

            font-size: 14px;

            font-weight: 600;

            cursor: pointer;

            margin-bottom: 10px;
        }


        .create-group-btn:hover {
            background: #1d4ed8;
        }


        .group-item {
            display: flex;

            align-items: center;

            gap: 11px;

            padding: 11px;

            margin-bottom: 3px;

            border-radius: 9px;

            text-decoration: none;

            color: #111827;
        }


        .group-item:hover {
            background: #f3f6fb;
        }


        .group-item.active {
            background: #eaf1ff;

            border-left:
                3px solid #2563eb;
        }


        .group-icon {
            width: 43px;
            height: 43px;

            border-radius: 10px;

            display: flex;

            align-items: center;

            justify-content: center;

            background: #e8efff;

            color: #2563eb;

            font-weight: 700;

            font-size: 18px;

            object-fit: cover;

            flex-shrink: 0;
        }


        .group-picture {
            width: 43px;
            height: 43px;

            border-radius: 10px;

            object-fit: cover;

            flex-shrink: 0;
        }


        .group-info {
            min-width: 0;

            flex: 1;
        }


        .group-name {
            font-size: 14px;

            font-weight: 700;

            white-space: nowrap;

            overflow: hidden;

            text-overflow: ellipsis;
        }


        .group-admin {
            margin-top: 4px;

            font-size: 11px;

            color: #6b7280;

            white-space: nowrap;

            overflow: hidden;

            text-overflow: ellipsis;
        }


        .admin-badge {
            display: inline-block;

            margin-left: 5px;

            padding: 2px 6px;

            border-radius: 4px;

            background: #e0e7ff;

            color: #4338ca;

            font-size: 9px;

            font-weight: 700;
        }


        /* =========================================
           MAIN CHAT
           ========================================= */

        .chat-area {
            flex: 1;

            height: 100vh;

            min-width: 0;

            display: flex;

            flex-direction: column;

            background: #f7f9fc;
        }


        /* =========================================
           HEADER
           ========================================= */

        .chat-header {
            min-height: 78px;

            flex-shrink: 0;

            display: flex;

            align-items: center;

            padding: 0 25px;

            background: white;

            border-bottom:
                1px solid #e5e7eb;
        }


        .header-avatar {
            width: 48px;
            height: 48px;

            border-radius: 50%;

            object-fit: cover;

            margin-right: 13px;
        }


        .header-group-picture {
            width: 48px;
            height: 48px;

            border-radius: 11px;

            object-fit: cover;

            margin-right: 13px;
        }


        .header-group-icon {
            width: 48px;
            height: 48px;

            border-radius: 11px;

            background: #e8efff;

            color: #2563eb;

            display: flex;

            align-items: center;

            justify-content: center;

            font-size: 19px;

            font-weight: 700;

            margin-right: 13px;
        }


        .header-name {
            font-size: 17px;

            font-weight: 700;

            color: #111827;
        }


        .header-status {
            margin-top: 4px;

            font-size: 12px;

            color: #6b7280;
        }


        /* =========================================
           ADMIN ACTIONS
           ========================================= */

        .admin-actions {
            margin-left: auto;

            display: flex;

            align-items: center;

            gap: 8px;
        }


        .add-member-btn,
        .change-group-picture-btn {
            padding: 9px 14px;

            border:
                1px solid #2563eb;

            border-radius: 7px;

            background: white;

            color: #2563eb;

            font-size: 13px;

            font-weight: 600;

            cursor: pointer;
        }


        .add-member-btn:hover,
        .change-group-picture-btn:hover {
            background: #eff6ff;
        }


        /* =========================================
           MESSAGES
           ========================================= */

        .messages-area {
            flex: 1;

            overflow-y: auto;

            padding: 25px;

            display: flex;

            flex-direction: column;

            gap: 9px;
        }


        .message-row {
            display: flex;

            width: 100%;
        }


        .message-row.sent {
            justify-content: flex-end;
        }


        .message-row.received {
            justify-content: flex-start;
        }


        .message-bubble {
            max-width: 65%;

            padding: 11px 14px;

            border-radius: 10px;

            font-size: 14px;

            line-height: 1.45;

            word-wrap: break-word;

            white-space: pre-wrap;
        }


        .message-row.sent
        .message-bubble {
            background: #2563eb;

            color: white;

            border-bottom-right-radius: 3px;
        }


        .message-row.received
        .message-bubble {
            background: white;

            color: #111827;

            border:
                1px solid #e5e7eb;

            border-bottom-left-radius: 3px;
        }


        .group-sender {
            font-size: 11px;

            font-weight: 700;

            color: #2563eb;

            margin-bottom: 4px;
        }


        .empty-chat {
            flex: 1;

            display: flex;

            align-items: center;

            justify-content: center;

            color: #9ca3af;

            text-align: center;

            font-size: 14px;
        }


        /* =========================================
           MESSAGE FORM
           ========================================= */

        .message-form {
            display: flex;

            gap: 10px;

            padding: 16px 20px;

            background: white;

            border-top:
                1px solid #e5e7eb;
        }


        .message-input {
            flex: 1;

            padding: 13px 15px;

            border:
                1px solid #d1d5db;

            border-radius: 9px;

            outline: none;

            font-size: 14px;
        }


        .message-input:focus {
            border-color: #2563eb;
        }


        .send-btn {
            min-width: 90px;

            padding: 0 20px;

            border: none;

            border-radius: 9px;

            background: #2563eb;

            color: white;

            font-weight: 700;

            cursor: pointer;
        }


        .send-btn:hover {
            background: #1d4ed8;
        }


        /* =========================================
           MODALS
           ========================================= */

        .modal {
            display: none;

            position: fixed;

            inset: 0;

            z-index: 1000;

            background:
                rgba(15,23,42,0.5);

            align-items: center;

            justify-content: center;

            padding: 20px;
        }


        .modal-box {
            width: 100%;

            max-width: 430px;

            background: white;

            border-radius: 14px;

            padding: 24px;

            box-shadow:
                0 20px 50px
                rgba(0,0,0,0.2);
        }


        .modal-title {
            font-size: 19px;

            font-weight: 700;

            color: #111827;

            margin-bottom: 18px;
        }


        .modal-input {
            width: 100%;

            padding: 12px;

            border:
                1px solid #d1d5db;

            border-radius: 8px;

            outline: none;

            font-size: 14px;
        }


        .modal-input:focus {
            border-color: #2563eb;
        }


        .modal-buttons {
            display: flex;

            justify-content: flex-end;

            gap: 9px;

            margin-top: 20px;
        }


        .cancel-btn {
            padding: 9px 15px;

            border:
                1px solid #d1d5db;

            background: white;

            border-radius: 7px;

            cursor: pointer;
        }


        .confirm-btn {
            padding: 9px 15px;

            border: none;

            background: #2563eb;

            color: white;

            border-radius: 7px;

            cursor: pointer;

            font-weight: 600;
        }


        .member-list {
            max-height: 300px;

            overflow-y: auto;
        }


        .member-option {
            display: flex;

            align-items: center;

            gap: 10px;

            padding: 9px;

            border-radius: 7px;

            margin-bottom: 3px;
        }


        .member-option:hover {
            background: #f3f6fb;
        }


        .member-option img {
            width: 38px;
            height: 38px;

            border-radius: 50%;

            object-fit: cover;
        }


        .member-option-info {
            flex: 1;

            min-width: 0;
        }


        .member-option-name {
            font-size: 14px;

            font-weight: 600;
        }


        .member-option-email {
            font-size: 11px;

            color: #6b7280;

            margin-top: 2px;

            overflow: hidden;

            text-overflow: ellipsis;

            white-space: nowrap;
        }


        /* =========================================
           MOBILE
           ========================================= */

        @media (max-width: 800px) {

            .sidebar {
                width: 290px;

                min-width: 290px;
            }

            .message-bubble {
                max-width: 80%;
            }

            .admin-actions {
                display: none;
            }
        }


        @media (max-width: 600px) {

            .sidebar {
                width: 100px;

                min-width: 100px;
            }

            .profile-details,
            .change-photo,
            .search-section,
            .section-title,
            .user-info,
            .group-info,
            .create-group-btn {
                display: none;
            }

            .profile-section {
                padding: 15px;
            }

            .profile-main {
                justify-content: center;
            }

            .logo-section {
                justify-content: center;
            }

            .logo {
                font-size: 17px;
            }

            .small-profile {
                display: none;
            }

            .user-item,
            .group-item {
                justify-content: center;
            }

            .chat-header {
                padding: 0 12px;
            }

            .messages-area {
                padding: 15px;
            }
        }

    </style>

</head>


<body>


<div class="app">


    <!-- =================================================
         LEFT SIDEBAR
         ================================================= -->

    <aside class="sidebar">


        <!-- LOGO -->

        <div class="logo-section">

            <div class="logo">
                Connect<span>Chat</span>
            </div>

            <img
                src="uploads/profiles/<%= profilePicture %>"
                class="small-profile"
                alt="Profile"
            >

        </div>


        <!-- PROFILE -->

        <div class="profile-section">

            <div class="profile-main">

                <img
                    src="uploads/profiles/<%= profilePicture %>"
                    class="profile-image"
                    alt="Profile"
                >

                <div class="profile-details">

                    <div class="profile-name">
                        <%= currentUser.getUsername() %>
                    </div>

                    <div class="profile-email">
                        <%= currentUser.getEmail() %>
                    </div>

                </div>

            </div>


            <form
                action="profile"
                method="post"
                enctype="multipart/form-data"
            >

                <label
                    for="profilePicture"
                    class="change-photo"
                >
                    Change Photo
                </label>

                <input
                    type="file"
                    id="profilePicture"
                    name="profilePicture"
                    accept="image/*"
                    onchange="this.form.submit()"
                    style="display:none;"
                >

            </form>

        </div>


        <!-- SEARCH -->

        <div class="search-section">

            <input
                type="text"
                id="searchUsers"
                class="search-input"
                placeholder="Search users..."
                onkeyup="searchUsers()"
            >

        </div>


        <!-- SIDEBAR CONTENT -->

        <div class="sidebar-content">


            <!-- AVAILABLE USERS -->

            <div class="section">

                <div class="section-title">
                    AVAILABLE USERS
                </div>


                <div id="usersList">

                    <%
                        if (users.isEmpty()) {
                    %>

                        <div class="no-users">
                            No other users available
                        </div>

                    <%
                        } else {

                            for (User user : users) {

                                String userPicture =
                                        user.getProfilePicture();

                                if (userPicture == null ||
                                        userPicture.trim().isEmpty()) {

                                    userPicture =
                                            "default.png";
                                }

                                boolean activeUser =
                                        receiverId != null &&
                                        receiverId ==
                                            user.getId();
                    %>


                    <a
                        href="messages?receiverId=<%= user.getId() %>"
                        class="user-item <%= activeUser ? "active" : "" %>"
                        data-user-id="<%= user.getId() %>"
                        data-username="<%= user.getUsername().toLowerCase() %>"
                    >

                        <div class="user-avatar-container">

                            <img
                                src="uploads/profiles/<%= userPicture %>"
                                class="user-avatar"
                                alt="Profile"
                            >

                            <span
                                class="status-dot"
                                id="status-dot-<%= user.getId() %>"
                            ></span>

                        </div>


                        <div class="user-info">

                            <div class="user-name">
                                <%= user.getUsername() %>
                            </div>

                            <div
                                class="user-status"
                                id="user-status-<%= user.getId() %>"
                            >
                                Offline
                            </div>

                        </div>

                    </a>


                    <%
                            }
                        }
                    %>

                </div>

            </div>


            <!-- GROUP CHATS -->

            <div class="group-section">

                <div class="section-title">
                    GROUP CHATS
                </div>


                <button
                    type="button"
                    class="create-group-btn"
                    onclick="openCreateGroupModal()"
                >
                    Create Group
                </button>


                <div>

                    <%
                        if (groups.isEmpty()) {
                    %>

                        <div class="no-users">
                            No groups yet
                        </div>

                    <%
                        } else {

                            for (ChatGroup group : groups) {

                                boolean activeGroup =
                                        groupId != null &&
                                        groupId ==
                                            group.getId();

                                String groupPicture =
                                        group.getGroupPicture();

                                if (groupPicture == null ||
                                        groupPicture.trim().isEmpty()) {

                                    groupPicture =
                                            "group-default.png";
                                }
                    %>


                    <a
                        href="messages?groupId=<%= group.getId() %>"
                        class="group-item <%= activeGroup ? "active" : "" %>"
                    >

                        <img
                            src="uploads/groups/<%= groupPicture %>"
                            class="group-picture"
                            alt="Group"
                        >


                        <div class="group-info">

                            <div class="group-name">
                                <%= group.getGroupName() %>
                            </div>

                            <div class="group-admin">

                                Admin:
                                <%= group.getCreatorName() %>

                                <%
                                    if (group.isAdmin()) {
                                %>

                                    <span class="admin-badge">
                                        ADMIN
                                    </span>

                                <%
                                    }
                                %>

                            </div>

                        </div>

                    </a>


                    <%
                            }
                        }
                    %>

                </div>

            </div>


        </div>

    </aside>


    <!-- =================================================
         MAIN CHAT AREA
         ================================================= -->

    <main class="chat-area">


        <!-- CHAT HEADER -->

        <div class="chat-header">


            <%
                if (selectedGroup != null) {

                    String selectedGroupPicture =
                            selectedGroup.getGroupPicture();

                    if (selectedGroupPicture == null ||
                            selectedGroupPicture.trim().isEmpty()) {

                        selectedGroupPicture =
                                "group-default.png";
                    }
            %>


                <img
                    src="uploads/groups/<%= selectedGroupPicture %>"
                    class="header-group-picture"
                    alt="Group"
                >


                <div>

                    <div class="header-name">
                        <%= selectedGroup.getGroupName() %>
                    </div>

                    <div class="header-status">

                        Created by
                        <%= selectedGroup.getCreatorName() %>

                        <%
                            if (selectedGroup.isAdmin()) {
                        %>

                            · You are Admin

                        <%
                            }
                        %>

                    </div>

                </div>


                <%
                    if (selectedGroup.isAdmin()) {
                %>

                    <div class="admin-actions">

                        <!-- CHANGE GROUP PICTURE -->

                        <form
                            action="group-profile"
                            method="post"
                            enctype="multipart/form-data"
                        >

                            <input
                                type="hidden"
                                name="groupId"
                                value="<%= selectedGroup.getId() %>"
                            >

                            <label
                                for="groupPictureInput"
                                class="change-group-picture-btn"
                            >
                                Change Picture
                            </label>

                            <input
                                type="file"
                                id="groupPictureInput"
                                name="groupPicture"
                                accept="image/*"
                                onchange="this.form.submit()"
                                style="display:none;"
                            >

                        </form>


                        <!-- ADD MEMBERS -->

                        <button
                            type="button"
                            class="add-member-btn"
                            onclick="openMemberModal()"
                        >
                            Add Members
                        </button>

                    </div>

                <%
                    }
                %>


            <%
                } else if (receiver != null) {
            %>


                <%
                    String receiverPicture =
                            receiver.getProfilePicture();

                    if (receiverPicture == null ||
                            receiverPicture.trim().isEmpty()) {

                        receiverPicture =
                                "default.png";
                    }
                %>


                <img
                    src="uploads/profiles/<%= receiverPicture %>"
                    class="header-avatar"
                    alt="Profile"
                >


                <div>

                    <div class="header-name">
                        <%= receiver.getUsername() %>
                    </div>

                    <div
                        class="header-status"
                        id="header-user-status"
                    >
                        Offline
                    </div>

                </div>


            <%
                } else {
            %>


                <div>

                    <div class="header-name">
                        Welcome to ConnectChat
                    </div>

                    <div class="header-status">
                        Select a user or group to start chatting
                    </div>

                </div>


            <%
                }
            %>

        </div>


        <!-- =================================================
             MESSAGES AREA
             ================================================= -->

        <div
            class="messages-area"
            id="messagesArea"
        >


            <%
                if (selectedGroup != null) {

                    if (groupMessages.isEmpty()) {
            %>

                        <div class="empty-chat">
                            No messages in this group yet.
                        </div>

            <%
                    } else {

                        for (Message groupMessage :
                                groupMessages) {

                            int senderId =
                                    groupMessage.getSenderId();

                            String text =
                                    groupMessage.getMessage();

                            boolean sent =
                                    senderId ==
                                    currentUser.getId();
            %>


                    <div
                        class="message-row <%= sent ? "sent" : "received" %>"
                    >

                        <div class="message-bubble">

                            <%
                                if (!sent) {
                            %>

                                <div class="group-sender">
                                    Member
                                </div>

                            <%
                                }
                            %>

                            <%= text %>

                        </div>

                    </div>


            <%
                        }
                    }

                } else if (receiver != null) {

                    if (messages.isEmpty()) {
            %>

                        <div class="empty-chat">
                            No messages yet. Start the conversation.
                        </div>

            <%
                    } else {

                        for (Message message :
                                messages) {

                            boolean sent =
                                    message.getSenderId() ==
                                    currentUser.getId();
            %>


                    <div
                        class="message-row <%= sent ? "sent" : "received" %>"
                    >

                        <div class="message-bubble">

                            <%= message.getMessage() %>

                        </div>

                    </div>


            <%
                        }
                    }

                } else {
            %>


                    <div class="empty-chat">

                        Select a user or group from the left
                        to start chatting.

                    </div>


            <%
                }
            %>


        </div>


        <!-- =================================================
             MESSAGE FORM
             ================================================= -->

        <%
            if (receiver != null ||
                    selectedGroup != null) {
        %>


        <form
            class="message-form"
            id="messageForm"
        >

            <input
                type="text"
                id="messageInput"
                class="message-input"
                placeholder="Type a message..."
                autocomplete="off"
            >

            <button
                type="submit"
                class="send-btn"
            >
                Send
            </button>

        </form>


        <%
            }
        %>


    </main>

</div>


<!-- =====================================================
     CREATE GROUP MODAL
     ===================================================== -->

<div
    class="modal"
    id="createGroupModal"
>

    <div class="modal-box">

        <div class="modal-title">
            Create New Group
        </div>


        <form
            action="groups"
            method="post"
        >

            <input
                type="hidden"
                name="action"
                value="create"
            >


            <input
                type="text"
                name="groupName"
                class="modal-input"
                placeholder="Enter group name"
                maxlength="100"
                required
            >


            <div class="modal-buttons">

                <button
                    type="button"
                    class="cancel-btn"
                    onclick="closeCreateGroupModal()"
                >
                    Cancel
                </button>

                <button
                    type="submit"
                    class="confirm-btn"
                >
                    Create Group
                </button>

            </div>

        </form>

    </div>

</div>


<!-- =====================================================
     ADD MEMBER MODAL
     ===================================================== -->

<%
    if (selectedGroup != null &&
            selectedGroup.isAdmin()) {
%>

<div
    class="modal"
    id="memberModal"
>

    <div class="modal-box">

        <div class="modal-title">
            Add Members
        </div>


        <div class="member-list">

            <%
                if (users.isEmpty()) {
            %>

                <div class="no-users">
                    No users available.
                </div>

            <%
                } else {

                    for (User user :
                            users) {

                        String memberPicture =
                                user.getProfilePicture();

                        if (memberPicture == null ||
                                memberPicture.trim().isEmpty()) {

                            memberPicture =
                                    "default.png";
                        }
            %>


                <form
                    action="group-members"
                    method="post"
                    class="member-option"
                >

                    <input
                        type="hidden"
                        name="groupId"
                        value="<%= selectedGroup.getId() %>"
                    >

                    <input
                        type="hidden"
                        name="userId"
                        value="<%= user.getId() %>"
                    >


                    <img
                        src="uploads/profiles/<%= memberPicture %>"
                        alt="Profile"
                    >


                    <div class="member-option-info">

                        <div class="member-option-name">
                            <%= user.getUsername() %>
                        </div>

                        <div class="member-option-email">
                            <%= user.getEmail() %>
                        </div>

                    </div>


                    <button
                        type="submit"
                        class="confirm-btn"
                    >
                        Add
                    </button>

                </form>


            <%
                    }
                }
            %>

        </div>


        <div class="modal-buttons">

            <button
                type="button"
                class="cancel-btn"
                onclick="closeMemberModal()"
            >
                Close
            </button>

        </div>

    </div>

</div>

<%
    }
%>


<script>


    /* =====================================================
       CURRENT USER
       ===================================================== */

    const currentUserId =
        <%= currentUser.getId() %>;


    /* =====================================================
       CURRENT PRIVATE CHAT USER
       ===================================================== */

    const currentReceiverId =
        <%= receiverId != null
                ? receiverId
                : "null" %>;


    /* =====================================================
       CURRENT GROUP
       ===================================================== */

    const currentGroupId =
        <%= groupId != null
                ? groupId
                : "null" %>;


    /* =====================================================
       WEBSOCKET
       ===================================================== */

    let socket = null;


    function connectWebSocket() {

        const protocol =
            window.location.protocol === "https:"
                ? "wss:"
                : "ws:";


        const host =
            window.location.host;


        const contextPath =
            "<%= request.getContextPath() %>";


        const socketUrl =
            protocol +
            "//" +
            host +
            contextPath +
            "/chat?userId=" +
            currentUserId;


        socket =
            new WebSocket(socketUrl);


        socket.onopen = function() {

            console.log(
                "ConnectChat WebSocket connected"
            );

        };


        socket.onmessage = function(event) {

            handleWebSocketMessage(
                event.data
            );

        };


        socket.onclose = function() {

            console.log(
                "WebSocket disconnected"
            );

        };


        socket.onerror = function(error) {

            console.log(
                "WebSocket error",
                error
            );

        };

    }


    /* =====================================================
       HANDLE WEBSOCKET MESSAGE
       ===================================================== */

    function handleWebSocketMessage(data) {


        /* ================================================
           ONLINE STATUS
           ================================================ */

        if (data.startsWith("ONLINE|")) {

            updateOnlineStatus(
                data.substring(7)
            );

            return;
        }


        /* ================================================
           PRIVATE MESSAGE
           ================================================ */

        if (data.startsWith("MESSAGE|")) {

            const parts =
                data.split("|");


            if (parts.length < 4) {
                return;
            }


            const senderId =
                parseInt(parts[1]);


            const receiverId =
                parseInt(parts[2]);


            const text =
                parts.slice(3).join("|");


            if (
                currentReceiverId !== null &&
                (
                    (
                        senderId === currentUserId &&
                        receiverId === currentReceiverId
                    )
                    ||
                    (
                        senderId === currentReceiverId &&
                        receiverId === currentUserId
                    )
                )
            ) {

                addPrivateMessage(
                    senderId,
                    text
                );

            }

            return;
        }


        /* ================================================
           GROUP MESSAGE
           ================================================ */

        if (data.startsWith("GROUP_MESSAGE|")) {

            const parts =
                data.split("|");


            if (parts.length < 4) {
                return;
            }


            const senderId =
                parseInt(parts[1]);


            const groupId =
                parseInt(parts[2]);


            const text =
                parts.slice(3).join("|");


            if (
                currentGroupId !== null &&
                groupId === currentGroupId
            ) {

                addGroupMessage(
                    senderId,
                    text
                );

            }

            return;
        }

    }


    /* =====================================================
       UPDATE ONLINE STATUS
       ===================================================== */

    function updateOnlineStatus(
        onlineUsersString
    ) {

        const onlineUsers =
            onlineUsersString
                .split(",")
                .filter(
                    value =>
                        value.trim() !== ""
                );


        document
            .querySelectorAll(
                ".user-item"
            )
            .forEach(function(item) {

                const userId =
                    item.getAttribute(
                        "data-user-id"
                    );


                const dot =
                    document.getElementById(
                        "status-dot-" +
                        userId
                    );


                const status =
                    document.getElementById(
                        "user-status-" +
                        userId
                    );


                if (!dot || !status) {
                    return;
                }


                if (
                    onlineUsers.includes(
                        userId
                    )
                ) {

                    dot.classList.add(
                        "online"
                    );

                    status.textContent =
                        "Online";

                    status.classList.add(
                        "online-text"
                    );

                } else {

                    dot.classList.remove(
                        "online"
                    );

                    status.textContent =
                        "Offline";

                    status.classList.remove(
                        "online-text"
                    );

                }

            });


        /* ================================================
           HEADER ONLINE STATUS
           ================================================ */

        if (currentReceiverId !== null) {

            const headerStatus =
                document.getElementById(
                    "header-user-status"
                );


            if (headerStatus) {

                const receiverIsOnline =
                    onlineUsers.includes(
                        String(
                            currentReceiverId
                        )
                    );


                headerStatus.textContent =
                    receiverIsOnline
                        ? "Online"
                        : "Offline";


                headerStatus.style.color =
                    receiverIsOnline
                        ? "#22c55e"
                        : "#ef4444";

            }

        }

    }


    /* =====================================================
       ADD PRIVATE MESSAGE
       ===================================================== */

    function addPrivateMessage(
        senderId,
        text
    ) {

        const messagesArea =
            document.getElementById(
                "messagesArea"
            );


        const emptyMessage =
            messagesArea.querySelector(
                ".empty-chat"
            );


        if (emptyMessage) {
            emptyMessage.remove();
        }


        const row =
            document.createElement(
                "div"
            );


        row.className =
            "message-row " +
            (
                senderId === currentUserId
                    ? "sent"
                    : "received"
            );


        const bubble =
            document.createElement(
                "div"
            );


        bubble.className =
            "message-bubble";


        bubble.textContent =
            text;


        row.appendChild(
            bubble
        );


        messagesArea.appendChild(
            row
        );


        scrollToBottom();

    }


    /* =====================================================
       ADD GROUP MESSAGE
       ===================================================== */

    function addGroupMessage(
        senderId,
        text
    ) {

        const messagesArea =
            document.getElementById(
                "messagesArea"
            );


        const emptyMessage =
            messagesArea.querySelector(
                ".empty-chat"
            );


        if (emptyMessage) {
            emptyMessage.remove();
        }


        const row =
            document.createElement(
                "div"
            );


        row.className =
            "message-row " +
            (
                senderId === currentUserId
                    ? "sent"
                    : "received"
            );


        const bubble =
            document.createElement(
                "div"
            );


        bubble.className =
            "message-bubble";


        if (senderId !== currentUserId) {

            const sender =
                document.createElement(
                    "div"
                );


            sender.className =
                "group-sender";


            sender.textContent =
                "Member";


            bubble.appendChild(
                sender
            );

        }


        const messageText =
            document.createElement(
                "span"
            );


        messageText.textContent =
            text;


        bubble.appendChild(
            messageText
        );


        row.appendChild(
            bubble
        );


        messagesArea.appendChild(
            row
        );


        scrollToBottom();

    }


    /* =====================================================
       SEND MESSAGE
       ===================================================== */

    const messageForm =
        document.getElementById(
            "messageForm"
        );


    if (messageForm) {

        messageForm.addEventListener(
            "submit",
            function(event) {

                event.preventDefault();


                const input =
                    document.getElementById(
                        "messageInput"
                    );


                const text =
                    input.value.trim();


                if (text === "") {
                    return;
                }


                if (
                    socket === null ||
                    socket.readyState !==
                        WebSocket.OPEN
                ) {

                    alert(
                        "Chat connection is not ready."
                    );

                    return;
                }


                /* ========================================
                   GROUP MESSAGE
                   ======================================== */

                if (currentGroupId !== null) {

                    socket.send(
                        "GROUP|" +
                        currentUserId +
                        "|" +
                        currentGroupId +
                        "|" +
                        text
                    );


                /* ========================================
                   PRIVATE MESSAGE
                   ======================================== */

                } else if (
                    currentReceiverId !== null
                ) {

                    socket.send(
                        "PRIVATE|" +
                        currentUserId +
                        "|" +
                        currentReceiverId +
                        "|" +
                        text
                    );

                }


                input.value = "";

                input.focus();

            }
        );

    }


    /* =====================================================
       ENTER KEY
       ===================================================== */

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

                    if (messageForm) {

                        messageForm.dispatchEvent(
                            new Event("submit")
                        );

                    }

                }

            }
        );

    }


    /* =====================================================
       SEARCH USERS
       ===================================================== */

    function searchUsers() {

        const searchInput =
            document.getElementById(
                "searchUsers"
            );


        const searchText =
            searchInput.value
                .toLowerCase()
                .trim();


        document
            .querySelectorAll(
                ".user-item"
            )
            .forEach(function(item) {

                const username =
                    item.getAttribute(
                        "data-username"
                    );


                if (
                    username.includes(
                        searchText
                    )
                ) {

                    item.style.display =
                        "flex";

                } else {

                    item.style.display =
                        "none";

                }

            });

    }


    /* =====================================================
       CREATE GROUP MODAL
       ===================================================== */

    function openCreateGroupModal() {

        const modal =
            document.getElementById(
                "createGroupModal"
            );


        if (modal) {

            modal.style.display =
                "flex";

        }

    }


    function closeCreateGroupModal() {

        const modal =
            document.getElementById(
                "createGroupModal"
            );


        if (modal) {

            modal.style.display =
                "none";

        }

    }


    /* =====================================================
       MEMBER MODAL
       ===================================================== */

    function openMemberModal() {

        const modal =
            document.getElementById(
                "memberModal"
            );


        if (modal) {

            modal.style.display =
                "flex";

        }

    }


    function closeMemberModal() {

        const modal =
            document.getElementById(
                "memberModal"
            );


        if (modal) {

            modal.style.display =
                "none";

        }

    }


    /* =====================================================
       CLOSE MODAL OUTSIDE
       ===================================================== */

    window.addEventListener(
        "click",
        function(event) {

            const createModal =
                document.getElementById(
                    "createGroupModal"
                );


            if (
                event.target ===
                createModal
            ) {

                closeCreateGroupModal();

            }


            const memberModal =
                document.getElementById(
                    "memberModal"
                );


            if (
                memberModal &&
                event.target ===
                    memberModal
            ) {

                closeMemberModal();

            }

        }
    );


    /* =====================================================
       SCROLL TO BOTTOM
       ===================================================== */

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


    /* =====================================================
       START WEBSOCKET
       ===================================================== */

    connectWebSocket();


    /* =====================================================
       INITIAL SCROLL
       ===================================================== */

    window.addEventListener(
        "load",
        function() {

            scrollToBottom();

        }
    );

</script>


</body>

</html>