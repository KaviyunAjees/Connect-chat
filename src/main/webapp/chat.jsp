<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.connectchat.model.User" %>
<%@ page import="com.connectchat.model.Message" %>
<%@ page import="com.connectchat.model.ChatGroup" %>
<%@ page import="com.connectchat.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) users = new ArrayList<>();

    List<User> blockedUsers = (List<User>) request.getAttribute("blockedUsers");
    if (blockedUsers == null) blockedUsers = new ArrayList<>();

    List<Message> messages = (List<Message>) request.getAttribute("messages");
    if (messages == null) messages = new ArrayList<>();

    User receiver = (User) request.getAttribute("receiver");
    Integer receiverId = (Integer) request.getAttribute("receiverId");

    Boolean isBlockedByMe = (Boolean) request.getAttribute("isBlockedByMe");
    if (isBlockedByMe == null) isBlockedByMe = false;

    Boolean isBlockedByThem = (Boolean) request.getAttribute("isBlockedByThem");
    if (isBlockedByThem == null) isBlockedByThem = false;

    List<ChatGroup> groups = (List<ChatGroup>) request.getAttribute("groups");
    if (groups == null) groups = new ArrayList<>();

    ChatGroup selectedGroup = (ChatGroup) request.getAttribute("selectedGroup");
    Integer groupId = (Integer) request.getAttribute("groupId");

    List<Message> groupMessages = (List<Message>) request.getAttribute("groupMessages");
    if (groupMessages == null) groupMessages = new ArrayList<>();

    List<User> groupMembers = (List<User>) request.getAttribute("groupMembers");
    if (groupMembers == null) groupMembers = new ArrayList<>();

    List<User> nonMembers = (List<User>) request.getAttribute("nonMembers");
    if (nonMembers == null) nonMembers = new ArrayList<>();

    Boolean isGroupAdmin = (Boolean) request.getAttribute("isGroupAdmin");
    if (isGroupAdmin == null) isGroupAdmin = false;

    String profilePicture = currentUser.getProfilePicture();
    if (profilePicture == null || profilePicture.trim().isEmpty()) {
        profilePicture = "default.png";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ConnectChat - Modern Web Chat</title>
    <style>
        :root {
            --primary: #2563eb;
            --primary-hover: #1d4ed8;
            --primary-light: #eff6ff;
            --secondary: #4f46e5;
            --bg-main: #f8fafc;
            --bg-sidebar: #ffffff;
            --bg-chat: #ffffff;
            --border: #e2e8f0;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }

        body {
            background: var(--bg-main);
            color: var(--text-main);
            height: 100vh;
            overflow: hidden;
        }

        .app-container {
            display: flex;
            height: 100vh;
            width: 100vw;
            background: #fff;
        }

        /* SIDEBAR */
        .sidebar {
            width: 380px;
            min-width: 340px;
            height: 100vh;
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            background: var(--bg-sidebar);
            z-index: 10;
        }

        .logo-header {
            height: 70px;
            padding: 0 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--border);
        }

        .brand-logo {
            font-size: 24px;
            font-weight: 800;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .brand-logo span {
            color: var(--text-main);
        }

        .user-profile-badge {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .avatar-img {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--primary);
            cursor: pointer;
            transition: transform 0.2s;
        }

        .avatar-img:hover {
            transform: scale(1.05);
        }

        /* PROFILE SECTION */
        .profile-card {
            padding: 16px 20px;
            background: linear-gradient(135deg, #1e40af, #3b82f6);
            color: #fff;
        }

        .profile-row {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .profile-avatar-large {
            width: 58px;
            height: 58px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #fff;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }

        .profile-meta {
            flex: 1;
            min-width: 0;
        }

        .profile-username {
            font-size: 16px;
            font-weight: 700;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .profile-email {
            font-size: 12px;
            opacity: 0.85;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .profile-actions {
            display: flex;
            gap: 8px;
            margin-top: 12px;
        }

        .btn-profile-action {
            flex: 1;
            padding: 7px 10px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.4);
            background: rgba(255,255,255,0.15);
            color: #fff;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            transition: background 0.2s;
        }

        .btn-profile-action:hover {
            background: rgba(255,255,255,0.28);
        }

        /* SEARCH */
        .search-box {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border);
        }

        .search-input {
            width: 100%;
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid var(--border);
            font-size: 14px;
            outline: none;
            background: #f1f5f9;
            transition: border 0.2s;
        }

        .search-input:focus {
            border-color: var(--primary);
            background: #fff;
        }

        /* SIDEBAR TABS & LISTS */
        .sidebar-scroll {
            flex: 1;
            overflow-y: auto;
            padding: 12px 14px;
        }

        .section-header {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--text-muted);
            margin: 14px 6px 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .btn-create-group {
            background: var(--primary-light);
            color: var(--primary);
            border: 1px solid #bfdbfe;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-create-group:hover {
            background: var(--primary);
            color: #fff;
        }

        .chat-list-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            border-radius: 10px;
            text-decoration: none;
            color: var(--text-main);
            margin-bottom: 4px;
            transition: background 0.15s;
            position: relative;
        }

        .chat-list-item:hover {
            background: #f1f5f9;
        }

        .chat-list-item.active {
            background: var(--primary-light);
            border-left: 3px solid var(--primary);
        }

        .item-avatar-wrapper {
            position: relative;
            width: 44px;
            height: 44px;
            flex-shrink: 0;
        }

        .item-avatar {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            object-fit: cover;
        }

        .status-dot {
            position: absolute;
            bottom: 1px;
            right: 1px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #94a3b8;
            border: 2px solid #fff;
        }

        .status-dot.online {
            background: var(--success);
        }

        .item-info {
            flex: 1;
            min-width: 0;
        }

        .item-title {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-main);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .item-subtitle {
            font-size: 12px;
            color: var(--text-muted);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .badge-admin {
            background: #dbeafe;
            color: var(--primary);
            font-size: 10px;
            font-weight: 700;
            padding: 1px 6px;
            border-radius: 4px;
        }

        .badge-blocked {
            background: #fee2e2;
            color: var(--danger);
            font-size: 10px;
            font-weight: 700;
            padding: 1px 6px;
            border-radius: 4px;
        }

        /* MAIN CHAT AREA */
        .chat-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: var(--bg-chat);
            height: 100vh;
            position: relative;
        }

        /* CHAT HEADER */
        .chat-header {
            height: 72px;
            padding: 0 24px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #ffffff;
            z-index: 5;
        }

        .chat-header-info {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .chat-header-avatar {
            width: 46px;
            height: 46px;
            border-radius: 50%;
            object-fit: cover;
        }

        .chat-header-name {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-main);
        }

        .chat-header-status {
            font-size: 12px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .chat-header-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .header-btn {
            padding: 8px 14px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid var(--border);
            background: #fff;
            color: var(--text-main);
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .header-btn svg {
            width: 15px;
            height: 15px;
        }

        .header-btn:hover {
            background: #f1f5f9;
        }

        .header-btn.danger {
            color: var(--danger);
            border-color: #fca5a5;
        }

        .header-btn.danger:hover {
            background: #fee2e2;
        }

        .header-btn.primary {
            background: var(--primary);
            color: #fff;
            border-color: var(--primary);
        }

        .header-btn.primary:hover {
            background: var(--primary-hover);
        }

        /* BLOCK WARNING BANNER */
        .block-banner {
            background: #fef2f2;
            border-bottom: 1px solid #fecaca;
            color: #991b1b;
            padding: 10px 24px;
            font-size: 13px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* MESSAGES AREA */
        .messages-scroll {
            flex: 1;
            overflow-y: auto;
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            background: #f8fafc;
        }

        .empty-chat-message {
            margin: auto;
            text-align: center;
            color: var(--text-muted);
            max-width: 320px;
        }

        .empty-chat-message .empty-icon {
            margin-bottom: 12px;
            display: inline-block;
            color: var(--primary);
        }

        /* MESSAGE ROWS */
        .message-row {
            display: flex;
            flex-direction: column;
            max-width: 65%;
            position: relative;
        }

        .message-row.sent {
            align-self: flex-end;
            align-items: flex-end;
        }

        .message-row.received {
            align-self: flex-start;
            align-items: flex-start;
        }

        .message-bubble-wrapper {
            position: relative;
            display: inline-block;
        }

        .message-bubble {
            padding: 10px 14px;
            border-radius: 14px;
            font-size: 14px;
            line-height: 1.45;
            word-wrap: break-word;
            position: relative;
        }

        .message-row.sent .message-bubble {
            background: var(--primary);
            color: #ffffff;
            border-bottom-right-radius: 3px;
        }

        .message-row.received .message-bubble {
            background: #ffffff;
            color: var(--text-main);
            border: 1px solid var(--border);
            border-bottom-left-radius: 3px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }

        .group-sender-title {
            font-size: 11px;
            font-weight: 700;
            color: #0284c7;
            margin-bottom: 4px;
        }

        .message-row.sent .group-sender-title {
            color: #bfdbfe;
        }

        .message-text {
            white-space: pre-wrap;
        }

        .message-time {
            font-size: 10px;
            margin-top: 4px;
            opacity: 0.75;
            text-align: right;
        }

        .message-row.received .message-time {
            color: var(--text-muted);
        }

        .message-deleted-marker {
            font-style: italic;
            opacity: 0.85;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* PHOTO & FILE ATTACHMENTS IN BUBBLE */
        .chat-photo-thumb {
            max-width: 280px;
            max-height: 220px;
            border-radius: 8px;
            cursor: pointer;
            display: block;
            margin-bottom: 6px;
            transition: transform 0.2s;
        }

        .chat-photo-thumb:hover {
            transform: scale(1.02);
        }

        .file-attachment-card {
            display: flex;
            align-items: center;
            gap: 12px;
            background: rgba(0,0,0,0.06);
            padding: 10px 12px;
            border-radius: 10px;
            margin-bottom: 4px;
        }

        .message-row.received .file-attachment-card {
            background: #f1f5f9;
        }

        .file-icon-box {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            color: var(--primary);
        }

        .message-row.sent .file-icon-box {
            color: #fff;
        }

        .file-meta-info {
            flex: 1;
            min-width: 0;
        }

        .file-name-label {
            font-size: 13px;
            font-weight: 700;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 170px;
        }

        .file-size-label {
            font-size: 11px;
            opacity: 0.8;
        }

        .file-download-action {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: var(--primary);
            color: #fff;
            text-decoration: none;
            transition: transform 0.2s;
        }

        .file-download-action svg {
            width: 16px;
            height: 16px;
        }

        .file-download-action:hover {
            transform: scale(1.1);
        }

        .message-row.sent .file-download-action {
            background: #fff;
            color: var(--primary);
        }

        /* MESSAGE CONTEXT MENU */
        .msg-menu-btn {
            position: absolute;
            top: 4px;
            right: -24px;
            background: transparent;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            padding: 2px 4px;
            font-size: 14px;
            opacity: 0;
            transition: opacity 0.2s;
        }

        .message-row:hover .msg-menu-btn {
            opacity: 1;
        }

        .message-dropdown-menu {
            position: absolute;
            top: 24px;
            right: 0;
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.12);
            display: none;
            flex-direction: column;
            z-index: 50;
            min-width: 160px;
            overflow: hidden;
        }

        .message-dropdown-menu.show {
            display: flex;
        }

        .dropdown-item {
            padding: 8px 12px;
            font-size: 13px;
            color: var(--text-main);
            background: transparent;
            border: none;
            text-align: left;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: background 0.15s;
        }

        .dropdown-item svg {
            width: 14px;
            height: 14px;
        }

        .dropdown-item:hover {
            background: #f1f5f9;
        }

        .dropdown-item.danger {
            color: var(--danger);
        }

        /* MESSAGE FORM */
        .chat-input-bar {
            padding: 14px 20px;
            background: #ffffff;
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 10px;
            position: relative;
        }

        .attachment-menu-container {
            position: relative;
        }

        .btn-attachment {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            border: 1px solid var(--border);
            background: #f8fafc;
            color: var(--text-muted);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }

        .btn-attachment svg {
            width: 18px;
            height: 18px;
        }

        .btn-attachment:hover {
            background: #e2e8f0;
            color: var(--text-main);
        }

        .attachment-dropdown {
            position: absolute;
            bottom: 50px;
            left: 0;
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.14);
            display: none;
            flex-direction: column;
            width: 190px;
            overflow: hidden;
            z-index: 60;
        }

        .attachment-dropdown.show {
            display: flex;
        }

        .attachment-opt {
            padding: 10px 14px;
            display: flex;
            align-items: center;
            gap: 10px;
            background: transparent;
            border: none;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-main);
            cursor: pointer;
            transition: background 0.15s;
            text-align: left;
        }

        .attachment-opt svg {
            width: 16px;
            height: 16px;
            color: var(--primary);
        }

        .attachment-opt:hover {
            background: #f1f5f9;
        }

        .message-input {
            flex: 1;
            padding: 12px 18px;
            border-radius: 24px;
            border: 1px solid var(--border);
            outline: none;
            font-size: 14px;
            background: #f8fafc;
            transition: border 0.2s;
        }

        .message-input:focus {
            border-color: var(--primary);
            background: #fff;
        }

        .btn-send {
            padding: 12px 24px;
            border-radius: 24px;
            border: none;
            background: var(--primary);
            color: #fff;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
        }

        .btn-send:hover {
            background: var(--primary-hover);
        }

        .btn-send:active {
            transform: scale(0.97);
        }

        /* MODALS */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 23, 42, 0.6);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 100;
            backdrop-filter: blur(2px);
        }

        .modal-card {
            background: #fff;
            border-radius: 16px;
            width: 90%;
            max-width: 480px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.25);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            animation: modalFadeIn 0.2s ease-out;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }

        .modal-header {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .modal-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-main);
        }

        .modal-close-btn {
            background: transparent;
            border: none;
            font-size: 20px;
            color: var(--text-muted);
            cursor: pointer;
        }

        .modal-body {
            padding: 20px;
            max-height: 65vh;
            overflow-y: auto;
        }

        .modal-footer {
            padding: 14px 20px;
            border-top: 1px solid var(--border);
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            background: #f8fafc;
        }

        .modal-btn {
            padding: 9px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid var(--border);
            background: #fff;
            color: var(--text-main);
            transition: all 0.2s;
        }

        .modal-btn:hover {
            background: #f1f5f9;
        }

        .modal-btn.primary {
            background: var(--primary);
            color: #fff;
            border-color: var(--primary);
        }

        .modal-btn.primary:hover {
            background: var(--primary-hover);
        }

        .modal-btn.danger {
            background: var(--danger);
            color: #fff;
            border-color: var(--danger);
        }

        .preview-box {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 12px;
            margin-bottom: 14px;
        }

        .preview-img {
            max-width: 100%;
            max-height: 240px;
            border-radius: 10px;
            object-fit: cover;
            border: 1px solid var(--border);
        }

        .preview-avatar-circle {
            width: 110px;
            height: 110px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid var(--primary);
        }

        /* PROGRESS BAR */
        .progress-bar-container {
            width: 100%;
            height: 8px;
            background: #e2e8f0;
            border-radius: 4px;
            overflow: hidden;
            display: none;
            margin-top: 10px;
        }

        .progress-bar-fill {
            height: 100%;
            width: 0%;
            background: var(--primary);
            transition: width 0.2s;
        }

        /* LIGHTBOX */
        .lightbox-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0,0,0,0.85);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 200;
        }

        .lightbox-img {
            max-width: 90vw;
            max-height: 85vh;
            border-radius: 8px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }

        .lightbox-close {
            position: absolute;
            top: 20px;
            right: 25px;
            color: #fff;
            font-size: 32px;
            background: transparent;
            border: none;
            cursor: pointer;
        }

        .member-list-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid var(--border);
        }

        .member-list-item:last-child {
            border-bottom: none;
        }

        .member-item-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .member-item-name {
            font-size: 14px;
            font-weight: 600;
        }

        .member-item-email {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* TOAST NOTIFICATION */
        .toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: #1e293b;
            color: #fff;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 14px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            z-index: 300;
            display: none;
            animation: toastIn 0.3s;
        }

        @keyframes toastIn {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
    </style>
</head>
<body>

<div class="app-container">

    <!-- SIDEBAR -->
    <aside class="sidebar">

        <div class="logo-header">
            <a href="messages" class="brand-logo">Connect<span>Chat</span></a>
            <div class="user-profile-badge">
                <img src="media?type=profile&file=<%= profilePicture %>&name=<%= HtmlUtil.escape(currentUser.getUsername()) %>"
                     class="avatar-img"
                     alt="Profile"
                     onclick="openProfileModal()"
                     title="Click to change profile picture">
            </div>
        </div>

        <!-- CURRENT USER CARD -->
        <div class="profile-card">
            <div class="profile-row">
                <img src="media?type=profile&file=<%= profilePicture %>&name=<%= HtmlUtil.escape(currentUser.getUsername()) %>"
                     class="profile-avatar-large"
                     alt="Profile">
                <div class="profile-meta">
                    <div class="profile-username"><%= HtmlUtil.escape(currentUser.getUsername()) %></div>
                    <div class="profile-email"><%= HtmlUtil.escape(currentUser.getEmail()) %></div>
                </div>
            </div>
            <div class="profile-actions">
                <button type="button" class="btn-profile-action" onclick="openProfileModal()">Change Photo</button>
                <button type="button" class="btn-profile-action" onclick="openBlockedModal()">Blocked Users</button>
                <a href="logout" class="btn-profile-action" style="background: rgba(239,68,68,0.3); border-color: rgba(239,68,68,0.5);">Logout</a>
            </div>
        </div>

        <!-- SEARCH INPUT -->
        <div class="search-box">
            <input type="text"
                   id="searchUsersInput"
                   class="search-input"
                   placeholder="Search contacts and groups..."
                   onkeyup="filterSidebarList()">
        </div>

        <!-- CONTACTS & GROUPS SCROLL -->
        <div class="sidebar-scroll" id="sidebarScroll">

            <!-- PRIVATE CONVERSATIONS -->
            <div class="section-header">DIRECT MESSAGES</div>
            <div id="usersListContainer">
                <%
                    if (users.isEmpty()) {
                %>
                    <div style="font-size: 13px; color: var(--text-muted); padding: 8px 6px;">No other registered users.</div>
                <%
                    } else {
                        for (User user : users) {
                            boolean isActive = (receiverId != null && receiverId == user.getId());
                %>
                    <a href="messages?receiverId=<%= user.getId() %>"
                       class="chat-list-item <%= isActive ? "active" : "" %>"
                       data-user-id="<%= user.getId() %>"
                       data-name="<%= HtmlUtil.escape(user.getUsername().toLowerCase()) %>">
                        <div class="item-avatar-wrapper">
                            <img src="media?type=profile&file=<%= user.getProfilePicture() %>&name=<%= HtmlUtil.escape(user.getUsername()) %>"
                                 class="item-avatar"
                                 alt="Avatar">
                            <span class="status-dot" id="status-dot-<%= user.getId() %>"></span>
                        </div>
                        <div class="item-info">
                            <div class="item-title"><%= HtmlUtil.escape(user.getUsername()) %></div>
                            <div class="item-subtitle">
                                <span id="status-text-<%= user.getId() %>">Offline</span>
                                <% if (user.isBlocked()) { %>
                                    <span class="badge-blocked">Blocked</span>
                                <% } %>
                            </div>
                        </div>
                    </a>
                <%
                        }
                    }
                %>
            </div>

            <!-- GROUP CHATS -->
            <div class="section-header" style="margin-top: 20px;">
                <span>GROUP CHATS</span>
                <button type="button" class="btn-create-group" onclick="openCreateGroupModal()">+ New Group</button>
            </div>
            <div id="groupsListContainer">
                <%
                    if (groups.isEmpty()) {
                %>
                    <div style="font-size: 13px; color: var(--text-muted); padding: 8px 6px;">No groups joined yet.</div>
                <%
                    } else {
                        for (ChatGroup group : groups) {
                            boolean isActive = (groupId != null && groupId == group.getId());
                %>
                    <a href="messages?groupId=<%= group.getId() %>"
                       class="chat-list-item <%= isActive ? "active" : "" %>"
                       data-group-id="<%= group.getId() %>"
                       data-name="<%= HtmlUtil.escape(group.getGroupName().toLowerCase()) %>">
                        <div class="item-avatar-wrapper">
                            <img src="media?type=group&file=<%= group.getGroupPicture() %>&name=<%= HtmlUtil.escape(group.getGroupName()) %>"
                                 class="item-avatar"
                                 alt="Group">
                        </div>
                        <div class="item-info">
                            <div class="item-title"><%= HtmlUtil.escape(group.getGroupName()) %></div>
                            <div class="item-subtitle">
                                <%= group.getMemberCount() %> members
                                <% if (group.isAdmin()) { %>
                                    <span class="badge-admin">Admin</span>
                                <% } %>
                            </div>
                        </div>
                    </a>
                <%
                        }
                    }
                %>
            </div>

        </div>

    </aside>

    <!-- CHAT WORKSPACE -->
    <main class="chat-area">

        <!-- CHAT HEADER -->
        <div class="chat-header">
            <%
                if (selectedGroup != null) {
            %>
                <div class="chat-header-info">
                    <img src="media?type=group&file=<%= selectedGroup.getGroupPicture() %>&name=<%= HtmlUtil.escape(selectedGroup.getGroupName()) %>"
                         class="chat-header-avatar"
                         alt="Group">
                    <div>
                        <div class="chat-header-name"><%= HtmlUtil.escape(selectedGroup.getGroupName()) %></div>
                        <div class="chat-header-status">
                            Created by <%= HtmlUtil.escape(selectedGroup.getCreatorName()) %> &bull; <%= groupMembers.size() %> members
                            <% if (isGroupAdmin) { %>
                                <span class="badge-admin">Admin</span>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="chat-header-actions">
                    <button type="button" class="header-btn" onclick="openViewMembersModal()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        Members
                    </button>

                    <% if (isGroupAdmin) { %>
                        <button type="button" class="header-btn" onclick="openAddMemberModal()">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            Add Members
                        </button>
                        <button type="button" class="header-btn" onclick="openGroupPictureModal()">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            Picture
                        </button>
                        <button type="button" class="header-btn danger" onclick="confirmDeleteGroup(<%= selectedGroup.getId() %>, '<%= HtmlUtil.escape(selectedGroup.getGroupName()) %>')">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                            Delete Group
                        </button>
                    <% } %>

                    <button type="button" class="header-btn danger" onclick="confirmLeaveGroup(<%= selectedGroup.getId() %>, '<%= HtmlUtil.escape(selectedGroup.getGroupName()) %>')">Leave</button>
                </div>

            <%
                } else if (receiver != null) {
            %>
                <div class="chat-header-info">
                    <img src="media?type=profile&file=<%= receiver.getProfilePicture() %>&name=<%= HtmlUtil.escape(receiver.getUsername()) %>"
                         class="chat-header-avatar"
                         alt="Avatar">
                    <div>
                        <div class="chat-header-name"><%= HtmlUtil.escape(receiver.getUsername()) %></div>
                        <div class="chat-header-status">
                            <span id="activeHeaderStatus">Offline</span>
                        </div>
                    </div>
                </div>

                <div class="chat-header-actions">
                    <% if (isBlockedByMe) { %>
                        <button type="button" class="header-btn primary" onclick="confirmUnblockUser(<%= receiver.getId() %>, '<%= HtmlUtil.escape(receiver.getUsername()) %>')">Unblock User</button>
                    <% } else { %>
                        <button type="button" class="header-btn danger" onclick="confirmBlockUser(<%= receiver.getId() %>, '<%= HtmlUtil.escape(receiver.getUsername()) %>')">Block User</button>
                    <% } %>
                </div>

            <%
                } else {
            %>
                <div class="chat-header-info">
                    <div>
                        <div class="chat-header-name">Welcome to ConnectChat</div>
                        <div class="chat-header-status">Select a contact or group to start chatting</div>
                    </div>
                </div>
            <%
                }
            %>
        </div>

        <!-- BLOCK WARNING BANNER (IF APPLICABLE) -->
        <% if (receiver != null && isBlockedByMe) { %>
            <div class="block-banner">
                <span>Notice: You have blocked <%= HtmlUtil.escape(receiver.getUsername()) %>. Unblock them to send or receive messages.</span>
                <button type="button" class="header-btn primary" style="padding: 4px 10px; font-size: 12px;" onclick="confirmUnblockUser(<%= receiver.getId() %>, '<%= HtmlUtil.escape(receiver.getUsername()) %>')">Unblock Now</button>
            </div>
        <% } else if (receiver != null && isBlockedByThem) { %>
            <div class="block-banner">
                <span>Notice: You cannot message <%= HtmlUtil.escape(receiver.getUsername()) %> because you have been blocked.</span>
            </div>
        <% } %>

        <!-- MESSAGES CONTAINER -->
        <div class="messages-scroll" id="messagesArea">
            <%
                if (selectedGroup != null) {
                    if (groupMessages.isEmpty()) {
            %>
                        <div class="empty-chat-message">
                            <div class="empty-icon">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                            </div>
                            <div>No messages in this group yet. Send a message or photo to start!</div>
                        </div>
            <%
                    } else {
                        for (Message msg : groupMessages) {
                            boolean isSent = (msg.getSenderId() == currentUser.getId());
                            boolean canDeleteEveryone = isSent || isGroupAdmin;
            %>
                        <div class="message-row <%= isSent ? "sent" : "received" %>" id="msg-row-<%= msg.getId() %>" data-message-id="<%= msg.getId() %>">
                            <div class="message-bubble-wrapper">
                                <div class="message-bubble">
                                    <% if (!isSent) { %>
                                        <div class="group-sender-title"><%= HtmlUtil.escape(msg.getSenderName() != null ? msg.getSenderName() : "Member") %></div>
                                    <% } %>

                                    <% if (msg.isDeletedForAll()) { %>
                                        <div class="message-deleted-marker"><i>This message was deleted</i></div>
                                    <% } else if ("IMAGE".equalsIgnoreCase(msg.getMessageType())) { %>
                                        <img src="attachment?id=<%= msg.getId() %>&isGroup=true"
                                             class="chat-photo-thumb"
                                             alt="Photo"
                                             onclick="openLightbox('attachment?id=<%= msg.getId() %>&isGroup=true', '<%= HtmlUtil.escape(msg.getFileName()) %>')">
                                        <% if (msg.getMessage() != null && !msg.getMessage().isEmpty() && !msg.getMessage().equals(msg.getFileName())) { %>
                                            <div class="message-text"><%= HtmlUtil.escape(msg.getMessage()) %></div>
                                        <% } %>
                                    <% } else if ("FILE".equalsIgnoreCase(msg.getMessageType())) { %>
                                        <div class="file-attachment-card">
                                            <div class="file-icon-box">
                                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                            </div>
                                            <div class="file-meta-info">
                                                <div class="file-name-label" title="<%= HtmlUtil.escape(msg.getFileName()) %>"><%= HtmlUtil.escape(msg.getFileName()) %></div>
                                                <div class="file-size-label"><%= msg.getFormattedFileSize() %></div>
                                            </div>
                                            <a href="attachment?id=<%= msg.getId() %>&isGroup=true&download=true" class="file-download-action" title="Download file">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                            </a>
                                        </div>
                                        <% if (msg.getMessage() != null && !msg.getMessage().isEmpty() && !msg.getMessage().equals(msg.getFileName())) { %>
                                            <div class="message-text"><%= HtmlUtil.escape(msg.getMessage()) %></div>
                                        <% } %>
                                    <% } else { %>
                                        <div class="message-text"><%= HtmlUtil.escape(msg.getMessage()) %></div>
                                    <% } %>

                                    <div class="message-time"><%= msg.getCreatedAt() != null && msg.getCreatedAt().length() >= 16 ? msg.getCreatedAt().substring(11, 16) : "" %></div>
                                </div>

                                <% if (!msg.isDeletedForAll()) { %>
                                    <button type="button" class="msg-menu-btn" onclick="toggleMessageMenu(event, <%= msg.getId() %>)">&#8942;</button>
                                    <div class="message-dropdown-menu" id="menu-<%= msg.getId() %>">
                                        <button type="button" class="dropdown-item" onclick="confirmDeleteMessage(<%= msg.getId() %>, true, 'me')">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                            Delete for me
                                        </button>
                                        <% if (canDeleteEveryone) { %>
                                            <button type="button" class="dropdown-item danger" onclick="confirmDeleteMessage(<%= msg.getId() %>, true, 'everyone')">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                                Delete for everyone
                                            </button>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                        </div>
            <%
                        }
                    }
                } else if (receiver != null) {
                    if (messages.isEmpty()) {
            %>
                        <div class="empty-chat-message">
                            <div class="empty-icon">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                            </div>
                            <div>No messages yet. Say hello or share a photo with <%= HtmlUtil.escape(receiver.getUsername()) %>!</div>
                        </div>
            <%
                    } else {
                        for (Message msg : messages) {
                            boolean isSent = (msg.getSenderId() == currentUser.getId());
                            boolean canDeleteEveryone = isSent;
            %>
                        <div class="message-row <%= isSent ? "sent" : "received" %>" id="msg-row-<%= msg.getId() %>" data-message-id="<%= msg.getId() %>">
                            <div class="message-bubble-wrapper">
                                <div class="message-bubble">
                                    <% if (msg.isDeletedForAll()) { %>
                                        <div class="message-deleted-marker"><i>This message was deleted</i></div>
                                    <% } else if ("IMAGE".equalsIgnoreCase(msg.getMessageType())) { %>
                                        <img src="attachment?id=<%= msg.getId() %>&isGroup=false"
                                             class="chat-photo-thumb"
                                             alt="Photo"
                                             onclick="openLightbox('attachment?id=<%= msg.getId() %>&isGroup=false', '<%= HtmlUtil.escape(msg.getFileName()) %>')">
                                        <% if (msg.getMessage() != null && !msg.getMessage().isEmpty() && !msg.getMessage().equals(msg.getFileName())) { %>
                                            <div class="message-text"><%= HtmlUtil.escape(msg.getMessage()) %></div>
                                        <% } %>
                                    <% } else if ("FILE".equalsIgnoreCase(msg.getMessageType())) { %>
                                        <div class="file-attachment-card">
                                            <div class="file-icon-box">
                                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                            </div>
                                            <div class="file-meta-info">
                                                <div class="file-name-label" title="<%= HtmlUtil.escape(msg.getFileName()) %>"><%= HtmlUtil.escape(msg.getFileName()) %></div>
                                                <div class="file-size-label"><%= msg.getFormattedFileSize() %></div>
                                            </div>
                                            <a href="attachment?id=<%= msg.getId() %>&isGroup=false&download=true" class="file-download-action" title="Download file">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                            </a>
                                        </div>
                                        <% if (msg.getMessage() != null && !msg.getMessage().isEmpty() && !msg.getMessage().equals(msg.getFileName())) { %>
                                            <div class="message-text"><%= HtmlUtil.escape(msg.getMessage()) %></div>
                                        <% } %>
                                    <% } else { %>
                                        <div class="message-text"><%= HtmlUtil.escape(msg.getMessage()) %></div>
                                    <% } %>

                                    <div class="message-time"><%= msg.getCreatedAt() != null && msg.getCreatedAt().length() >= 16 ? msg.getCreatedAt().substring(11, 16) : "" %></div>
                                </div>

                                <% if (!msg.isDeletedForAll()) { %>
                                    <button type="button" class="msg-menu-btn" onclick="toggleMessageMenu(event, <%= msg.getId() %>)">&#8942;</button>
                                    <div class="message-dropdown-menu" id="menu-<%= msg.getId() %>">
                                        <button type="button" class="dropdown-item" onclick="confirmDeleteMessage(<%= msg.getId() %>, false, 'me')">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                            Delete for me
                                        </button>
                                        <% if (canDeleteEveryone) { %>
                                            <button type="button" class="dropdown-item danger" onclick="confirmDeleteMessage(<%= msg.getId() %>, false, 'everyone')">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                                Delete for everyone
                                            </button>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                        </div>
            <%
                        }
                    }
                } else {
            %>
                    <div class="empty-chat-message">
                        <div class="empty-icon">
                            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                        </div>
                        <div style="font-size: 16px; font-weight: 700; margin-bottom: 6px;">Select a chat to begin</div>
                        <div>Choose a contact or group from the left sidebar to start messaging.</div>
                    </div>
            <%
                }
            %>
        </div>

        <!-- MESSAGE COMPOSER BAR -->
        <% if (selectedGroup != null || receiver != null) { %>
            <div class="chat-input-bar">
                <% boolean isBlocked = (receiver != null && (isBlockedByMe || isBlockedByThem)); %>

                <div class="attachment-menu-container">
                    <button type="button" class="btn-attachment" id="btnAttachment" onclick="toggleAttachmentMenu(event)" <%= isBlocked ? "disabled" : "" %> title="Attach photo or document">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/>
                        </svg>
                    </button>
                    <div class="attachment-dropdown" id="attachmentDropdown">
                        <button type="button" class="attachment-opt" onclick="triggerPhotoUpload()">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
                            Send Photo
                        </button>
                        <button type="button" class="attachment-opt" onclick="triggerDocUpload()">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                            Send Document
                        </button>
                    </div>
                </div>

                <form id="messageForm" style="display:flex; flex:1; gap:10px;" onsubmit="handleSendMessage(event)">
                    <input type="text"
                           id="messageInput"
                           class="message-input"
                           placeholder="<%= isBlocked ? "Messaging unavailable due to block restrictions." : "Type a message..." %>"
                           autocomplete="off"
                           <%= isBlocked ? "disabled" : "" %>>
                    <button type="submit" class="btn-send" id="btnSend" <%= isBlocked ? "disabled" : "" %>>Send</button>
                </form>

                <!-- Hidden inputs for photo and file picking -->
                <input type="file" id="hiddenPhotoInput" accept="image/jpeg,image/png,image/webp,image/gif" style="display:none;" onchange="handlePhotoSelected(this)">
                <input type="file" id="hiddenDocInput" accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar,.7z" style="display:none;" onchange="handleDocSelected(this)">
            </div>
        <% } %>

    </main>

</div>

<!-- ========================================== -->
<!-- MODALS -->
<!-- ========================================== -->

<!-- 1. CHANGE PROFILE PICTURE MODAL -->
<div class="modal-overlay" id="profileModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Change Profile Picture</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('profileModal')">&times;</button>
        </div>
        <form id="profileForm" enctype="multipart/form-data" onsubmit="handleProfileSubmit(event)">
            <div class="modal-body">
                <div class="preview-box">
                    <img id="profilePreviewImg"
                         src="media?type=profile&file=<%= profilePicture %>&name=<%= HtmlUtil.escape(currentUser.getUsername()) %>"
                         class="preview-avatar-circle"
                         alt="Preview">
                </div>
                <div style="text-align:center;">
                    <label class="modal-btn" style="cursor:pointer; display:inline-block;">
                        Choose Image
                        <input type="file" name="profilePicture" accept="image/*" style="display:none;" onchange="previewProfileImage(this)">
                    </label>
                    <div style="font-size: 11px; color: var(--text-muted); margin-top: 8px;">Supports JPG, PNG, WebP up to 5MB</div>
                </div>
                <div class="progress-bar-container" id="profileProgress">
                    <div class="progress-bar-fill" id="profileProgressFill"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="modal-btn" onclick="closeModal('profileModal')">Cancel</button>
                <button type="submit" class="modal-btn primary" id="btnSaveProfile">Save Photo</button>
            </div>
        </form>
    </div>
</div>

<!-- 2. CHANGE GROUP PICTURE MODAL -->
<% if (selectedGroup != null && isGroupAdmin) { %>
<div class="modal-overlay" id="groupPictureModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Change Group Picture</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('groupPictureModal')">&times;</button>
        </div>
        <form action="group-profile" method="post" enctype="multipart/form-data">
            <input type="hidden" name="groupId" value="<%= selectedGroup.getId() %>">
            <div class="modal-body">
                <div class="preview-box">
                    <img id="groupPreviewImg"
                         src="media?type=group&file=<%= selectedGroup.getGroupPicture() %>&name=<%= HtmlUtil.escape(selectedGroup.getGroupName()) %>"
                         class="preview-avatar-circle"
                         alt="Preview">
                </div>
                <div style="text-align:center;">
                    <label class="modal-btn" style="cursor:pointer; display:inline-block;">
                        Choose Picture
                        <input type="file" name="groupPicture" accept="image/*" style="display:none;" onchange="previewGroupImage(this)">
                    </label>
                    <div style="font-size: 11px; color: var(--text-muted); margin-top: 8px;">Supports JPG, PNG, WebP up to 5MB</div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="modal-btn" onclick="closeModal('groupPictureModal')">Cancel</button>
                <button type="submit" class="modal-btn primary">Save Picture</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<!-- 3. PHOTO UPLOAD PREVIEW MODAL -->
<div class="modal-overlay" id="photoUploadModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Send Photo</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('photoUploadModal')">&times;</button>
        </div>
        <div class="modal-body">
            <div class="preview-box">
                <img id="photoUploadPreview" class="preview-img" alt="Photo Preview">
            </div>
            <div style="margin-bottom: 12px;">
                <input type="text" id="photoCaptionInput" class="search-input" placeholder="Add an optional caption...">
            </div>
            <div style="font-size: 12px; color: var(--text-muted);" id="photoFileSizeLabel"></div>
            <div class="progress-bar-container" id="photoProgress">
                <div class="progress-bar-fill" id="photoProgressFill"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="modal-btn" onclick="closeModal('photoUploadModal')">Cancel</button>
            <button type="button" class="modal-btn primary" id="btnConfirmPhotoSend" onclick="submitPhotoUpload()">Send Photo</button>
        </div>
    </div>
</div>

<!-- 4. FILE UPLOAD CONFIRMATION MODAL -->
<div class="modal-overlay" id="docUploadModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Send File</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('docUploadModal')">&times;</button>
        </div>
        <div class="modal-body">
            <div class="file-attachment-card" style="margin-bottom: 14px;">
                <div class="file-icon-box">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                </div>
                <div class="file-meta-info">
                    <div class="file-name-label" id="docFileNameLabel">Document</div>
                    <div class="file-size-label" id="docFileSizeLabel">0 KB</div>
                </div>
            </div>
            <div>
                <input type="text" id="docCaptionInput" class="search-input" placeholder="Add an optional note...">
            </div>
            <div class="progress-bar-container" id="docProgress">
                <div class="progress-bar-fill" id="docProgressFill"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="modal-btn" onclick="closeModal('docUploadModal')">Cancel</button>
            <button type="button" class="modal-btn primary" id="btnConfirmDocSend" onclick="submitDocUpload()">Send File</button>
        </div>
    </div>
</div>

<!-- 5. CREATE GROUP MODAL -->
<div class="modal-overlay" id="createGroupModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Create New Group</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('createGroupModal')">&times;</button>
        </div>
        <form action="groups" method="post">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <label style="font-size: 13px; font-weight: 700; display: block; margin-bottom: 6px;">Group Name</label>
                <input type="text" name="groupName" class="search-input" placeholder="Enter group name..." required maxlength="100">
                <div style="font-size: 11px; color: var(--text-muted); margin-top: 6px;">You will automatically become the group administrator.</div>
            </div>
            <div class="modal-footer">
                <button type="button" class="modal-btn" onclick="closeModal('createGroupModal')">Cancel</button>
                <button type="submit" class="modal-btn primary">Create Group</button>
            </div>
        </form>
    </div>
</div>

<!-- 6. ADD MEMBERS MODAL (SEARCHABLE) -->
<% if (selectedGroup != null && isGroupAdmin) { %>
<div class="modal-overlay" id="addMemberModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Add Members to <%= HtmlUtil.escape(selectedGroup.getGroupName()) %></div>
            <button type="button" class="modal-close-btn" onclick="closeModal('addMemberModal')">&times;</button>
        </div>
        <div class="modal-body">
            <div style="margin-bottom: 12px;">
                <input type="text" class="search-input" id="addMemberSearchInput" placeholder="Search registered users..." onkeyup="filterNonMemberList()">
            </div>
            <div id="nonMemberList" style="max-height: 280px; overflow-y: auto;">
                <% if (nonMembers.isEmpty()) { %>
                    <div style="text-align:center; color:var(--text-muted); padding:20px 0;">All registered users are already members.</div>
                <% } else {
                    for (User user : nonMembers) { %>
                        <div class="member-list-item non-member-item" data-search="<%= HtmlUtil.escape(user.getUsername().toLowerCase()) %> <%= HtmlUtil.escape(user.getEmail().toLowerCase()) %>">
                            <div class="member-item-left">
                                <img src="media?type=profile&file=<%= user.getProfilePicture() %>&name=<%= HtmlUtil.escape(user.getUsername()) %>"
                                     style="width:36px; height:36px; border-radius:50%; object-fit:cover;" alt="Avatar">
                                <div>
                                    <div class="member-item-name"><%= HtmlUtil.escape(user.getUsername()) %></div>
                                    <div class="member-item-email"><%= HtmlUtil.escape(user.getEmail()) %></div>
                                </div>
                            </div>
                            <form action="group-members" method="post" style="margin:0;">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="groupId" value="<%= selectedGroup.getId() %>">
                                <input type="hidden" name="userId" value="<%= user.getId() %>">
                                <button type="submit" class="modal-btn primary" style="padding: 4px 12px; font-size: 12px;">+ Add</button>
                            </form>
                        </div>
                <%  }
                } %>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="modal-btn" onclick="closeModal('addMemberModal')">Close</button>
        </div>
    </div>
</div>
<% } %>

<!-- 7. VIEW / MANAGE GROUP MEMBERS MODAL -->
<% if (selectedGroup != null) { %>
<div class="modal-overlay" id="viewMembersModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Group Members (<%= groupMembers.size() %>)</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('viewMembersModal')">&times;</button>
        </div>
        <div class="modal-body" style="max-height: 350px; overflow-y: auto;">
            <% for (User m : groupMembers) {
                boolean isThisUserCreator = (m.getId() == selectedGroup.getCreatedBy());
                boolean canRemoveThisMember = isGroupAdmin && !isThisUserCreator && (m.getId() != currentUser.getId());
            %>
                <div class="member-list-item">
                    <div class="member-item-left">
                        <img src="media?type=profile&file=<%= m.getProfilePicture() %>&name=<%= HtmlUtil.escape(m.getUsername()) %>"
                             style="width:38px; height:38px; border-radius:50%; object-fit:cover;" alt="Avatar">
                        <div>
                            <div class="member-item-name">
                                <%= HtmlUtil.escape(m.getUsername()) %>
                                <% if (isThisUserCreator) { %>
                                    <span class="badge-admin" style="background:#fef3c7; color:#b45309;">Creator</span>
                                <% } else if (m.isGroupAdmin()) { %>
                                    <span class="badge-admin">Admin</span>
                                <% } %>
                                <% if (m.getId() == currentUser.getId()) { %>
                                    <span style="font-size: 11px; color: var(--text-muted);">(You)</span>
                                <% } %>
                            </div>
                            <div class="member-item-email"><%= HtmlUtil.escape(m.getEmail()) %></div>
                        </div>
                    </div>
                    <% if (canRemoveThisMember) { %>
                        <button type="button" class="modal-btn danger" style="padding: 4px 10px; font-size: 11px;"
                                onclick="confirmRemoveMember(<%= selectedGroup.getId() %>, <%= m.getId() %>, '<%= HtmlUtil.escape(m.getUsername()) %>')">
                            Remove
                        </button>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="modal-footer">
            <button type="button" class="modal-btn" onclick="closeModal('viewMembersModal')">Close</button>
        </div>
    </div>
</div>
<% } %>

<!-- 8. BLOCKED USERS MODAL -->
<div class="modal-overlay" id="blockedUsersModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title">Blocked Users</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('blockedUsersModal')">&times;</button>
        </div>
        <div class="modal-body" style="max-height: 350px; overflow-y: auto;">
            <% if (blockedUsers.isEmpty()) { %>
                <div style="text-align:center; color:var(--text-muted); padding:20px 0;">You have not blocked any users.</div>
            <% } else {
                for (User b : blockedUsers) { %>
                    <div class="member-list-item">
                        <div class="member-item-left">
                            <img src="media?type=profile&file=<%= b.getProfilePicture() %>&name=<%= HtmlUtil.escape(b.getUsername()) %>"
                                 style="width:38px; height:38px; border-radius:50%; object-fit:cover;" alt="Avatar">
                            <div>
                                <div class="member-item-name"><%= HtmlUtil.escape(b.getUsername()) %></div>
                                <div class="member-item-email"><%= HtmlUtil.escape(b.getEmail()) %></div>
                            </div>
                        </div>
                        <button type="button" class="modal-btn primary" style="padding: 4px 12px; font-size: 12px;"
                                onclick="confirmUnblockUser(<%= b.getId() %>, '<%= HtmlUtil.escape(b.getUsername()) %>')">
                            Unblock
                        </button>
                    </div>
            <%  }
            } %>
        </div>
        <div class="modal-footer">
            <button type="button" class="modal-btn" onclick="closeModal('blockedUsersModal')">Close</button>
        </div>
    </div>
</div>

<!-- 9. UNIVERSAL CONFIRMATION MODAL -->
<div class="modal-overlay" id="confirmModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title" id="confirmModalTitle">Confirm Action</div>
            <button type="button" class="modal-close-btn" onclick="closeModal('confirmModal')">&times;</button>
        </div>
        <div class="modal-body">
            <div id="confirmModalMessage" style="font-size: 14px; line-height: 1.5; color: var(--text-main);">Are you sure?</div>
        </div>
        <div class="modal-footer">
            <button type="button" class="modal-btn" onclick="closeModal('confirmModal')">Cancel</button>
            <button type="button" class="modal-btn danger" id="btnConfirmAction">Proceed</button>
        </div>
    </div>
</div>

<!-- 10. PHOTO LIGHTBOX -->
<div class="lightbox-modal" id="lightboxModal" onclick="closeLightbox()">
    <button type="button" class="lightbox-close" onclick="closeLightbox()">&times;</button>
    <img id="lightboxImg" class="lightbox-img" alt="Enlarged photo" onclick="event.stopPropagation()">
</div>

<!-- TOAST -->
<div class="toast" id="appToast">Notification message</div>

<!-- ========================================== -->
<!-- CLIENT JAVASCRIPT -->
<!-- ========================================== -->
<script>
    const currentUserId = <%= currentUser.getId() %>;
    const currentReceiverId = <%= receiverId != null ? receiverId : "null" %>;
    const currentGroupId = <%= groupId != null ? groupId : "null" %>;
    const isGroupChat = currentGroupId !== null;

    let socket = null;
    let selectedPhotoFile = null;
    let selectedDocFile = null;

    // ==========================================
    // 1. WEBSOCKET SETUP
    // ==========================================
    function initWebSocket() {
        const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
        const socketUrl = protocol + "//" + window.location.host + "<%= request.getContextPath() %>/chat?userId=" + currentUserId;

        socket = new WebSocket(socketUrl);

        socket.onopen = function() {
            console.log("Connected to ConnectChat WebSocket.");
        };

        socket.onmessage = function(event) {
            handleIncomingWebSocketMessage(event.data);
        };

        socket.onclose = function() {
            console.warn("WebSocket disconnected. Attempting reconnect in 3s...");
            setTimeout(initWebSocket, 3000);
        };

        socket.onerror = function(err) {
            console.error("WebSocket error:", err);
        };
    }

    function handleIncomingWebSocketMessage(data) {
        if (!data) return;

        // ONLINE STATUS
        if (data.startsWith("ONLINE|")) {
            applyOnlineStatus(data.substring(7));
            return;
        }

        // PRIVATE MESSAGE: MESSAGE|messageId|senderId|receiverId|type|fileName|fileSize|text
        if (data.startsWith("MESSAGE|")) {
            const parts = data.split("|");
            if (parts.length < 8) return;

            const msgId = parseInt(parts[1]);
            const senderId = parseInt(parts[2]);
            const recvId = parseInt(parts[3]);
            const msgType = parts[4];
            const fileName = parts[5];
            const fileSize = parts[6];
            const text = parts.slice(7).join("|");

            if (currentReceiverId !== null &&
                ((senderId === currentUserId && recvId === currentReceiverId) ||
                 (senderId === currentReceiverId && recvId === currentUserId))) {

                renderChatMessage({
                    id: msgId,
                    senderId: senderId,
                    senderName: "",
                    isGroup: false,
                    messageType: msgType,
                    fileName: fileName,
                    fileSize: fileSize,
                    text: text,
                    isSent: senderId === currentUserId,
                    time: getCurrentTimeFormatted()
                });
            }
            return;
        }

        // GROUP MESSAGE: GROUP_MESSAGE|messageId|senderId|senderName|groupId|type|fileName|fileSize|text
        if (data.startsWith("GROUP_MESSAGE|")) {
            const parts = data.split("|");
            if (parts.length < 9) return;

            const msgId = parseInt(parts[1]);
            const senderId = parseInt(parts[2]);
            const senderName = parts[3];
            const grpId = parseInt(parts[4]);
            const msgType = parts[5];
            const fileName = parts[6];
            const fileSize = parts[7];
            const text = parts.slice(8).join("|");

            if (currentGroupId !== null && grpId === currentGroupId) {
                renderChatMessage({
                    id: msgId,
                    senderId: senderId,
                    senderName: senderName,
                    isGroup: true,
                    messageType: msgType,
                    fileName: fileName,
                    fileSize: fileSize,
                    text: text,
                    isSent: senderId === currentUserId,
                    time: getCurrentTimeFormatted()
                });
            }
            return;
        }

        // DELETE MESSAGE: DELETE_MESSAGE|messageId|isGroup|forEveryone
        if (data.startsWith("DELETE_MESSAGE|")) {
            const parts = data.split("|");
            const msgId = parts[1];
            const row = document.getElementById("msg-row-" + msgId);
            if (row) {
                const bubble = row.querySelector(".message-bubble");
                if (bubble) {
                    bubble.innerHTML = '<div class="message-deleted-marker"><i>This message was deleted</i></div><div class="message-time">' + getCurrentTimeFormatted() + '</div>';
                }
                const menuBtn = row.querySelector(".msg-menu-btn");
                if (menuBtn) menuBtn.remove();
                const menu = row.querySelector(".message-dropdown-menu");
                if (menu) menu.remove();
            }
            return;
        }

        // GROUP EVENT
        if (data.startsWith("GROUP_EVENT|")) {
            const parts = data.split("|");
            const grpId = parseInt(parts[1]);
            const action = parts[2];
            const detail = parts[3] || "";

            if (currentGroupId === grpId) {
                if (action === "GROUP_DELETED") {
                    alert("This group has been deleted by an administrator.");
                    window.location.href = "messages";
                } else if (action === "REMOVED_FROM_GROUP") {
                    alert("You have been removed from this group.");
                    window.location.href = "messages";
                } else {
                    showToast(detail + " " + action.replace("_", " ").toLowerCase());
                }
            }
            return;
        }

        // ERROR
        if (data.startsWith("ERROR|")) {
            showToast(data.substring(6));
            return;
        }
    }

    function applyOnlineStatus(onlineUsersStr) {
        const ids = onlineUsersStr.split(",").filter(s => s.trim() !== "");

        document.querySelectorAll(".chat-list-item[data-user-id]").forEach(item => {
            const uId = item.getAttribute("data-user-id");
            const dot = document.getElementById("status-dot-" + uId);
            const text = document.getElementById("status-text-" + uId);

            if (ids.includes(uId)) {
                if (dot) dot.classList.add("online");
                if (text) { text.textContent = "Online"; text.style.color = "var(--success)"; }
            } else {
                if (dot) dot.classList.remove("online");
                if (text) { text.textContent = "Offline"; text.style.color = "var(--text-muted)"; }
            }
        });

        if (currentReceiverId !== null) {
            const activeStatus = document.getElementById("activeHeaderStatus");
            if (activeStatus) {
                const online = ids.includes(String(currentReceiverId));
                activeStatus.textContent = online ? "Online" : "Offline";
                activeStatus.style.color = online ? "var(--success)" : "var(--text-muted)";
            }
        }
    }

    // ==========================================
    // 2. RENDERING CHAT MESSAGES
    // ==========================================
    function renderChatMessage(msg) {
        const area = document.getElementById("messagesArea");
        if (!area) return;

        const emptyPlaceholder = area.querySelector(".empty-chat-message");
        if (emptyPlaceholder) emptyPlaceholder.remove();

        const row = document.createElement("div");
        row.className = "message-row " + (msg.isSent ? "sent" : "received");
        row.id = "msg-row-" + msg.id;
        row.setAttribute("data-message-id", msg.id);

        let contentHtml = "";

        if (msg.isGroup && !msg.isSent && msg.senderName) {
            contentHtml += '<div class="group-sender-title">' + escapeHtml(msg.senderName) + '</div>';
        }

        if (msg.messageType === "IMAGE") {
            const imgSrc = "attachment?id=" + msg.id + "&isGroup=" + (msg.isGroup ? "true" : "false");
            contentHtml += '<img src="' + imgSrc + '" class="chat-photo-thumb" alt="Photo" onclick="openLightbox(\'' + imgSrc + '\', \'' + escapeHtml(msg.fileName || "Photo") + '\')">';
            if (msg.text && msg.text !== msg.fileName) {
                contentHtml += '<div class="message-text">' + escapeHtml(msg.text) + '</div>';
            }
        } else if (msg.messageType === "FILE") {
            const downloadUrl = "attachment?id=" + msg.id + "&isGroup=" + (msg.isGroup ? "true" : "false") + "&download=true";
            contentHtml += '<div class="file-attachment-card">' +
                '<div class="file-icon-box">' +
                    '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>' +
                '</div>' +
                '<div class="file-meta-info">' +
                    '<div class="file-name-label" title="' + escapeHtml(msg.fileName) + '">' + escapeHtml(msg.fileName) + '</div>' +
                    '<div class="file-size-label">' + formatBytes(msg.fileSize) + '</div>' +
                '</div>' +
                '<a href="' + downloadUrl + '" class="file-download-action" title="Download file">' +
                    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>' +
                '</a>' +
            '</div>';
            if (msg.text && msg.text !== msg.fileName) {
                contentHtml += '<div class="message-text">' + escapeHtml(msg.text) + '</div>';
            }
        } else {
            contentHtml += '<div class="message-text">' + escapeHtml(msg.text) + '</div>';
        }

        contentHtml += '<div class="message-time">' + msg.time + '</div>';

        let menuHtml = '<button type="button" class="msg-menu-btn" onclick="toggleMessageMenu(event, ' + msg.id + ')">&#8942;</button>' +
            '<div class="message-dropdown-menu" id="menu-' + msg.id + '">' +
                '<button type="button" class="dropdown-item" onclick="confirmDeleteMessage(' + msg.id + ', ' + msg.isGroup + ', \'me\')">' +
                    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>' +
                    'Delete for me' +
                '</button>';

        const canDeleteForEveryone = msg.isSent || (<%= isGroupAdmin %> && msg.isGroup);
        if (canDeleteForEveryone) {
            menuHtml += '<button type="button" class="dropdown-item danger" onclick="confirmDeleteMessage(' + msg.id + ', ' + msg.isGroup + ', \'everyone\')">' +
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>' +
                'Delete for everyone' +
            '</button>';
        }
        menuHtml += '</div>';

        row.innerHTML = '<div class="message-bubble-wrapper"><div class="message-bubble">' + contentHtml + '</div>' + menuHtml + '</div>';

        area.appendChild(row);
        scrollToBottom();
    }

    // ==========================================
    // 3. SENDING TEXT MESSAGES
    // ==========================================
    function handleSendMessage(event) {
        event.preventDefault();
        const input = document.getElementById("messageInput");
        if (!input) return;

        const text = input.value.trim();
        if (!text) return;

        if (!socket || socket.readyState !== WebSocket.OPEN) {
            showToast("Connection is not active. Retrying...");
            return;
        }

        if (isGroupChat) {
            socket.send("GROUP|" + currentUserId + "|" + currentGroupId + "|" + text);
        } else if (currentReceiverId !== null) {
            socket.send("PRIVATE|" + currentUserId + "|" + currentReceiverId + "|" + text);
        }

        input.value = "";
        input.focus();
    }

    // ==========================================
    // 4. ATTACHMENT & PHOTO SENDING
    // ==========================================
    function toggleAttachmentMenu(event) {
        event.stopPropagation();
        const menu = document.getElementById("attachmentDropdown");
        menu.classList.toggle("show");
    }

    function triggerPhotoUpload() {
        document.getElementById("attachmentDropdown").classList.remove("show");
        document.getElementById("hiddenPhotoInput").click();
    }

    function triggerDocUpload() {
        document.getElementById("attachmentDropdown").classList.remove("show");
        document.getElementById("hiddenDocInput").click();
    }

    function handlePhotoSelected(input) {
        if (!input.files || input.files.length === 0) return;
        selectedPhotoFile = input.files[0];

        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById("photoUploadPreview").src = e.target.result;
            document.getElementById("photoFileSizeLabel").textContent = "Size: " + formatBytes(selectedPhotoFile.size);
            document.getElementById("photoCaptionInput").value = "";
            document.getElementById("photoProgress").style.display = "none";
            document.getElementById("photoProgressFill").style.width = "0%";
            openModal("photoUploadModal");
        };
        reader.readAsDataURL(selectedPhotoFile);
        input.value = "";
    }

    function submitPhotoUpload() {
        if (!selectedPhotoFile) return;

        const formData = new FormData();
        formData.append("file", selectedPhotoFile);
        formData.append("messageType", "IMAGE");
        formData.append("caption", document.getElementById("photoCaptionInput").value.trim());

        if (isGroupChat) {
            formData.append("groupId", currentGroupId);
        } else {
            formData.append("receiverId", currentReceiverId);
        }

        const btn = document.getElementById("btnConfirmPhotoSend");
        btn.disabled = true;
        const progress = document.getElementById("photoProgress");
        const progressFill = document.getElementById("photoProgressFill");
        progress.style.display = "block";

        const xhr = new XMLHttpRequest();
        xhr.open("POST", "attachment", true);

        xhr.upload.onprogress = function(e) {
            if (e.lengthComputable) {
                const percent = (e.loaded / e.total) * 100;
                progressFill.style.width = percent + "%";
            }
        };

        xhr.onload = function() {
            btn.disabled = false;
            if (xhr.status >= 200 && xhr.status < 300) {
                closeModal("photoUploadModal");
                showToast("Photo sent successfully!");
            } else {
                try {
                    const res = JSON.parse(xhr.responseText);
                    alert(res.error || "Failed to upload photo.");
                } catch(e) {
                    alert("Error uploading photo.");
                }
            }
        };

        xhr.onerror = function() {
            btn.disabled = false;
            alert("Network error occurred while uploading photo.");
        };

        xhr.send(formData);
    }

    function handleDocSelected(input) {
        if (!input.files || input.files.length === 0) return;
        selectedDocFile = input.files[0];

        document.getElementById("docFileNameLabel").textContent = selectedDocFile.name;
        document.getElementById("docFileSizeLabel").textContent = formatBytes(selectedDocFile.size);
        document.getElementById("docCaptionInput").value = "";
        document.getElementById("docProgress").style.display = "none";
        document.getElementById("docProgressFill").style.width = "0%";

        openModal("docUploadModal");
        input.value = "";
    }

    function submitDocUpload() {
        if (!selectedDocFile) return;

        const formData = new FormData();
        formData.append("file", selectedDocFile);
        formData.append("messageType", "FILE");
        formData.append("caption", document.getElementById("docCaptionInput").value.trim());

        if (isGroupChat) {
            formData.append("groupId", currentGroupId);
        } else {
            formData.append("receiverId", currentReceiverId);
        }

        const btn = document.getElementById("btnConfirmDocSend");
        btn.disabled = true;
        const progress = document.getElementById("docProgress");
        const progressFill = document.getElementById("docProgressFill");
        progress.style.display = "block";

        const xhr = new XMLHttpRequest();
        xhr.open("POST", "attachment", true);

        xhr.upload.onprogress = function(e) {
            if (e.lengthComputable) {
                const percent = (e.loaded / e.total) * 100;
                progressFill.style.width = percent + "%";
            }
        };

        xhr.onload = function() {
            btn.disabled = false;
            if (xhr.status >= 200 && xhr.status < 300) {
                closeModal("docUploadModal");
                showToast("File sent successfully!");
            } else {
                try {
                    const res = JSON.parse(xhr.responseText);
                    alert(res.error || "Failed to upload file.");
                } catch(e) {
                    alert("Error uploading file.");
                }
            }
        };

        xhr.onerror = function() {
            btn.disabled = false;
            alert("Network error occurred while uploading file.");
        };

        xhr.send(formData);
    }

    // ==========================================
    // 5. MESSAGE DELETIONS
    // ==========================================
    function toggleMessageMenu(event, msgId) {
        event.stopPropagation();
        document.querySelectorAll(".message-dropdown-menu").forEach(m => {
            if (m.id !== "menu-" + msgId) m.classList.remove("show");
        });
        const targetMenu = document.getElementById("menu-" + msgId);
        if (targetMenu) targetMenu.classList.toggle("show");
    }

    function confirmDeleteMessage(msgId, isGroup, deleteType) {
        document.querySelectorAll(".message-dropdown-menu").forEach(m => m.classList.remove("show"));

        const title = deleteType === "everyone" ? "Delete For Everyone?" : "Delete For Me?";
        const message = deleteType === "everyone"
            ? "This will delete the message for all participants in this chat. This action cannot be undone."
            : "This message will be removed from your view only.";

        showConfirmDialog(title, message, function() {
            executeDeleteMessage(msgId, isGroup, deleteType);
        });
    }

    function executeDeleteMessage(msgId, isGroup, deleteType) {
        const formData = new URLSearchParams();
        formData.append("messageId", msgId);
        formData.append("isGroup", isGroup ? "true" : "false");
        formData.append("deleteType", deleteType);

        fetch("delete-message", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest"
            },
            body: formData.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                const row = document.getElementById("msg-row-" + msgId);
                if (row) {
                    if (deleteType === "me") {
                        row.remove();
                    } else {
                        const bubble = row.querySelector(".message-bubble");
                        if (bubble) {
                            bubble.innerHTML = '<div class="message-deleted-marker"><i>This message was deleted</i></div><div class="message-time">' + getCurrentTimeFormatted() + '</div>';
                        }
                        const menuBtn = row.querySelector(".msg-menu-btn");
                        if (menuBtn) menuBtn.remove();
                    }
                }
                showToast("Message deleted.");
            } else {
                alert(data.error || "Failed to delete message.");
            }
        })
        .catch(err => {
            console.error(err);
            alert("Error deleting message.");
        });
    }

    // ==========================================
    // 6. BLOCK & UNBLOCK ACTIONS
    // ==========================================
    function confirmBlockUser(userId, username) {
        showConfirmDialog("Block " + username + "?",
            "Blocked contacts will no longer be able to send you direct messages, photos, or files. Old messages will remain preserved.",
            function() {
                postBlockAction("block", userId);
            });
    }

    function confirmUnblockUser(userId, username) {
        showConfirmDialog("Unblock " + username + "?",
            "This contact will once again be able to message you and share files.",
            function() {
                postBlockAction("unblock", userId);
            });
    }

    function postBlockAction(action, userId) {
        const formData = new URLSearchParams();
        formData.append("action", action);
        formData.append("userId", userId);
        formData.append("ajax", "true");

        fetch("block", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest"
            },
            body: formData.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                window.location.reload();
            } else {
                alert(data.message || "Failed to update block status.");
            }
        })
        .catch(err => {
            console.error(err);
            window.location.reload();
        });
    }

    // ==========================================
    // 7. GROUP ACTIONS (REMOVE, LEAVE, DELETE)
    // ==========================================
    function confirmRemoveMember(groupId, memberId, memberName) {
        showConfirmDialog("Remove " + memberName + "?",
            "Are you sure you want to remove " + memberName + " from this group?",
            function() {
                const formData = new URLSearchParams();
                formData.append("action", "remove");
                formData.append("groupId", groupId);
                formData.append("userId", memberId);

                fetch("group-members", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: formData.toString()
                }).then(() => {
                    window.location.reload();
                });
            });
    }

    function confirmLeaveGroup(groupId, groupName) {
        showConfirmDialog("Leave " + groupName + "?",
            "You will no longer receive messages or files from this group.",
            function() {
                const formData = new URLSearchParams();
                formData.append("action", "leave");
                formData.append("groupId", groupId);

                fetch("groups", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: formData.toString()
                }).then(() => {
                    window.location.href = "messages";
                });
            });
    }

    function confirmDeleteGroup(groupId, groupName) {
        showConfirmDialog("Delete " + groupName + "?",
            "This group will be permanently removed for all members. All message history will be closed. This cannot be undone.",
            function() {
                const formData = new URLSearchParams();
                formData.append("action", "delete");
                formData.append("groupId", groupId);

                fetch("groups", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: formData.toString()
                }).then(() => {
                    window.location.href = "messages";
                });
            });
    }

    // ==========================================
    // 8. PROFILE & GROUP PICTURE PREVIEWS
    // ==========================================
    function previewProfileImage(input) {
        if (!input.files || input.files.length === 0) return;
        const file = input.files[0];
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById("profilePreviewImg").src = e.target.result;
        };
        reader.readAsDataURL(file);
    }

    function previewGroupImage(input) {
        if (!input.files || input.files.length === 0) return;
        const file = input.files[0];
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById("groupPreviewImg").src = e.target.result;
        };
        reader.readAsDataURL(file);
    }

    function handleProfileSubmit(event) {
        event.preventDefault();
        const form = document.getElementById("profileForm");
        const formData = new FormData(form);
        formData.append("ajax", "true");

        const btn = document.getElementById("btnSaveProfile");
        btn.disabled = true;
        const progress = document.getElementById("profileProgress");
        const progressFill = document.getElementById("profileProgressFill");
        progress.style.display = "block";

        const xhr = new XMLHttpRequest();
        xhr.open("POST", "profile", true);

        xhr.upload.onprogress = function(e) {
            if (e.lengthComputable) {
                const percent = (e.loaded / e.total) * 100;
                progressFill.style.width = percent + "%";
            }
        };

        xhr.onload = function() {
            btn.disabled = false;
            if (xhr.status >= 200 && xhr.status < 300) {
                window.location.reload();
            } else {
                try {
                    const res = JSON.parse(xhr.responseText);
                    alert(res.message || "Failed to update profile picture.");
                } catch(e) {
                    alert("Error updating profile picture.");
                }
            }
        };

        xhr.onerror = function() {
            btn.disabled = false;
            alert("Network error.");
        };

        xhr.send(formData);
    }

    // ==========================================
    // 9. SEARCH & FILTER UTILITIES
    // ==========================================
    function filterSidebarList() {
        const query = document.getElementById("searchUsersInput").value.toLowerCase().trim();
        document.querySelectorAll(".chat-list-item").forEach(item => {
            const name = item.getAttribute("data-name") || "";
            item.style.display = name.includes(query) ? "flex" : "none";
        });
    }

    function filterNonMemberList() {
        const query = document.getElementById("addMemberSearchInput").value.toLowerCase().trim();
        document.querySelectorAll(".non-member-item").forEach(item => {
            const searchData = item.getAttribute("data-search") || "";
            item.style.display = searchData.includes(query) ? "flex" : "none";
        });
    }

    // ==========================================
    // 10. MODALS & LIGHTBOX UTILITIES
    // ==========================================
    function openModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) modal.style.display = "flex";
    }

    function closeModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) modal.style.display = "none";
    }

    function openProfileModal() { openModal("profileModal"); }
    function openGroupPictureModal() { openModal("groupPictureModal"); }
    function openCreateGroupModal() { openModal("createGroupModal"); }
    function openAddMemberModal() { openModal("addMemberModal"); }
    function openViewMembersModal() { openModal("viewMembersModal"); }
    function openBlockedModal() { openModal("blockedUsersModal"); }

    function openLightbox(src, filename) {
        document.getElementById("lightboxImg").src = src;
        document.getElementById("lightboxModal").style.display = "flex";
    }

    function closeLightbox() {
        document.getElementById("lightboxModal").style.display = "none";
    }

    function showConfirmDialog(title, message, onConfirm) {
        document.getElementById("confirmModalTitle").textContent = title;
        document.getElementById("confirmModalMessage").textContent = message;
        const btn = document.getElementById("btnConfirmAction");

        const newBtn = btn.cloneNode(true);
        btn.parentNode.replaceChild(newBtn, btn);

        newBtn.onclick = function() {
            closeModal("confirmModal");
            onConfirm();
        };

        openModal("confirmModal");
    }

    function showToast(msg) {
        const toast = document.getElementById("appToast");
        toast.textContent = msg;
        toast.style.display = "block";
        setTimeout(() => { toast.style.display = "none"; }, 3500);
    }

    function escapeHtml(str) {
        if (!str) return "";
        return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
    }

    function formatBytes(bytes) {
        const b = parseInt(bytes);
        if (isNaN(b) || b <= 0) return "";
        if (b < 1024) return b + " B";
        const exp = Math.floor(Math.log(b) / Math.log(1024));
        const pre = "KMGTPE"[exp - 1];
        return (b / Math.pow(1024, exp)).toFixed(1) + " " + pre + "B";
    }

    function getCurrentTimeFormatted() {
        const d = new Date();
        const h = String(d.getHours()).padStart(2, '0');
        const m = String(d.getMinutes()).padStart(2, '0');
        return h + ":" + m;
    }

    function scrollToBottom() {
        const area = document.getElementById("messagesArea");
        if (area) area.scrollTop = area.scrollHeight;
    }

    // Close menus on click outside
    window.addEventListener("click", function(e) {
        const attachMenu = document.getElementById("attachmentDropdown");
        if (attachMenu && !e.target.closest(".attachment-menu-container")) {
            attachMenu.classList.remove("show");
        }
        if (!e.target.closest(".message-bubble-wrapper")) {
            document.querySelectorAll(".message-dropdown-menu").forEach(m => m.classList.remove("show"));
        }
    });

    // Initialize
    window.addEventListener("load", function() {
        initWebSocket();
        scrollToBottom();
    });
</script>

</body>
</html>