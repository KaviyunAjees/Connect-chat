package com.connectchat.websocket;

import com.connectchat.dao.BlockDAO;
import com.connectchat.dao.GroupDAO;
import com.connectchat.dao.MessageDAO;
import com.connectchat.dao.UserDAO;
import com.connectchat.model.Message;
import com.connectchat.model.User;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/chat")
public class ChatWebSocket {

    private static final Map<Integer, Set<Session>> onlineUsers = new ConcurrentHashMap<>();

    private final MessageDAO messageDAO = new MessageDAO();
    private final GroupDAO groupDAO = new GroupDAO();
    private final BlockDAO blockDAO = new BlockDAO();
    private final UserDAO userDAO = new UserDAO();

    @OnOpen
    public void onOpen(Session session) {
        String userIdParameter = session.getRequestParameterMap()
                .getOrDefault("userId", Collections.emptyList())
                .stream()
                .findFirst()
                .orElse(null);

        if (userIdParameter == null) {
            return;
        }

        try {
            int userId = Integer.parseInt(userIdParameter);
            session.getUserProperties().put("userId", userId);

            onlineUsers.computeIfAbsent(userId, key -> ConcurrentHashMap.newKeySet()).add(session);
            broadcastOnlineStatus();
        } catch (NumberFormatException e) {
            System.err.println("Invalid user ID on WebSocket open: " + userIdParameter);
        }
    }

    @OnMessage
    public void onMessage(String message, Session senderSession) {
        if (message == null || message.trim().isEmpty()) {
            return;
        }

        Integer authenticatedUserId = (Integer) senderSession.getUserProperties().get("userId");
        if (authenticatedUserId == null) {
            return;
        }

        try {
            // PRIVATE|senderId|receiverId|message
            if (message.startsWith("PRIVATE|")) {
                handlePrivateMessage(authenticatedUserId, message);
                return;
            }

            // GROUP|senderId|groupId|message
            if (message.startsWith("GROUP|")) {
                handleGroupMessage(authenticatedUserId, message);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void handlePrivateMessage(int authenticatedSenderId, String message) {
        String[] parts = message.split("\\|", 4);
        if (parts.length < 4) {
            return;
        }

        int receiverId;
        try {
            receiverId = Integer.parseInt(parts[2]);
        } catch (NumberFormatException e) {
            return;
        }

        String text = parts[3];
        if (text == null || text.trim().isEmpty()) {
            return;
        }

        // Enforce Block restrictions
        if (blockDAO.isBlockActiveBetween(authenticatedSenderId, receiverId)) {
            sendToUser(authenticatedSenderId, "ERROR|Cannot send message. A block restriction is in effect.");
            return;
        }

        Message chatMessage = new Message();
        chatMessage.setSenderId(authenticatedSenderId);
        chatMessage.setReceiverId(receiverId);
        chatMessage.setMessage(text);
        chatMessage.setMessageType("TEXT");

        int messageId = messageDAO.saveMessageWithId(chatMessage);
        if (messageId <= 0) {
            sendToUser(authenticatedSenderId, "ERROR|Message could not be saved.");
            return;
        }

        // Format: MESSAGE|messageId|senderId|receiverId|TEXT||0|text
        String responseMessage = "MESSAGE|" + messageId + "|" + authenticatedSenderId + "|" + receiverId + "|TEXT||0|" + text;

        sendToUser(authenticatedSenderId, responseMessage);
        sendToUser(receiverId, responseMessage);
    }

    private void handleGroupMessage(int authenticatedSenderId, String message) {
        String[] parts = message.split("\\|", 4);
        if (parts.length < 4) {
            return;
        }

        int groupId;
        try {
            groupId = Integer.parseInt(parts[2]);
        } catch (NumberFormatException e) {
            return;
        }

        String text = parts[3];
        if (text == null || text.trim().isEmpty()) {
            return;
        }

        // Security check: only member of active group can send
        if (!groupDAO.isMember(groupId, authenticatedSenderId)) {
            sendToUser(authenticatedSenderId, "ERROR|You are not a member of this group.");
            return;
        }

        Message groupMsg = new Message();
        groupMsg.setGroupId(groupId);
        groupMsg.setSenderId(authenticatedSenderId);
        groupMsg.setMessage(text);
        groupMsg.setMessageType("TEXT");

        int messageId = messageDAO.saveGroupMessageWithId(groupMsg);
        if (messageId <= 0) {
            sendToUser(authenticatedSenderId, "ERROR|Group message could not be saved.");
            return;
        }

        User sender = userDAO.getUserById(authenticatedSenderId);
        String senderName = (sender != null) ? sender.getUsername() : "Member";

        // Format: GROUP_MESSAGE|messageId|senderId|senderName|groupId|TEXT||0|text
        String responseMessage = "GROUP_MESSAGE|" + messageId + "|" + authenticatedSenderId + "|" + senderName + "|" + groupId + "|TEXT||0|" + text;

        sendToGroup(groupId, responseMessage);
    }

    public static void sendToUser(int userId, String message) {
        Set<Session> sessions = onlineUsers.get(userId);
        if (sessions == null) {
            return;
        }

        for (Session session : sessions) {
            if (session != null && session.isOpen()) {
                synchronized (session) {
                    try {
                        session.getBasicRemote().sendText(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    public static void sendToGroup(int groupId, String message) {
        GroupDAO groupDAO = new GroupDAO();
        List<Integer> members = groupDAO.getGroupMembers(groupId);
        for (Integer userId : members) {
            sendToUser(userId, message);
        }
    }

    public static void notifyMessageDeleted(int messageId, boolean isGroup, int targetId) {
        String event = "DELETE_MESSAGE|" + messageId + "|" + (isGroup ? "1" : "0") + "|1";
        if (isGroup) {
            sendToGroup(targetId, event);
        } else {
            sendToUser(targetId, event);
        }
    }

    public static void notifyGroupEvent(int groupId, String eventType, String detail) {
        String event = "GROUP_EVENT|" + groupId + "|" + eventType + "|" + (detail != null ? detail : "");
        sendToGroup(groupId, event);
    }

    @OnClose
    public void onClose(Session session) {
        Object userIdObject = session.getUserProperties().get("userId");
        if (userIdObject == null) {
            return;
        }

        int userId = (Integer) userIdObject;
        Set<Session> userSessions = onlineUsers.get(userId);

        if (userSessions != null) {
            userSessions.remove(session);
            if (userSessions.isEmpty()) {
                onlineUsers.remove(userId);
            }
        }

        broadcastOnlineStatus();
    }

    @OnError
    public void onError(Session session, Throwable error) {
        System.err.println("WebSocket error: " + (error != null ? error.getMessage() : "unknown"));
    }

    private void broadcastOnlineStatus() {
        StringBuilder onlineIds = new StringBuilder("ONLINE|");
        for (Integer userId : onlineUsers.keySet()) {
            if (onlineIds.length() > 7) {
                onlineIds.append(",");
            }
            onlineIds.append(userId);
        }

        String status = onlineIds.toString();

        for (Set<Session> sessions : onlineUsers.values()) {
            for (Session session : sessions) {
                if (session != null && session.isOpen()) {
                    synchronized (session) {
                        try {
                            session.getBasicRemote().sendText(status);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
    }
}