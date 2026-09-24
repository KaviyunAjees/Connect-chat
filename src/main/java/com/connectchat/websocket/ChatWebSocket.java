package com.connectchat.websocket;

import com.connectchat.dao.MessageDAO;
import com.connectchat.model.Message;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/chat")
public class ChatWebSocket {

    private static final Map<Integer, Set<Session>> onlineUsers =
            new ConcurrentHashMap<>();

    private final MessageDAO messageDAO = new MessageDAO();

    @OnOpen
    public void onOpen(Session session) {

        String userIdParameter =
                session.getRequestParameterMap()
                        .getOrDefault(
                                "userId",
                                java.util.Collections.emptyList()
                        )
                        .stream()
                        .findFirst()
                        .orElse(null);

        if (userIdParameter == null) {
            return;
        }

        try {

            int userId =
                    Integer.parseInt(userIdParameter);

            session.getUserProperties()
                    .put("userId", userId);

            onlineUsers
                    .computeIfAbsent(
                            userId,
                            key -> ConcurrentHashMap.newKeySet()
                    )
                    .add(session);

            System.out.println(
                    "User online: " + userId
            );

            broadcastOnlineStatus();

        } catch (NumberFormatException e) {

            System.out.println(
                    "Invalid user ID"
            );
        }
    }

    @OnMessage
    public void onMessage(
            String message,
            Session senderSession) {

        try {

            if (!message.startsWith("PRIVATE|")) {
                return;
            }

            String[] parts =
                    message.split("\\|", 4);

            if (parts.length < 4) {
                return;
            }

            int senderId =
                    Integer.parseInt(parts[1]);

            int receiverId =
                    Integer.parseInt(parts[2]);

            String text =
                    parts[3];

            Message chatMessage =
                    new Message(
                            senderId,
                            receiverId,
                            text
                    );

            boolean saved =
                    messageDAO.sendMessage(
                            chatMessage
                    );

            if (!saved) {
                return;
            }

            String responseMessage =
                    "MESSAGE|" +
                    senderId +
                    "|" +
                    receiverId +
                    "|" +
                    text;

            sendToUser(
                    senderId,
                    responseMessage
            );

            sendToUser(
                    receiverId,
                    responseMessage
            );

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session session) {

        Object userIdObject =
                session.getUserProperties()
                        .get("userId");

        if (userIdObject == null) {
            return;
        }

        int userId =
                (Integer) userIdObject;

        Set<Session> userSessions =
                onlineUsers.get(userId);

        if (userSessions != null) {

            userSessions.remove(session);

            if (userSessions.isEmpty()) {

                onlineUsers.remove(userId);

                System.out.println(
                        "User offline: " + userId
                );
            }
        }

        broadcastOnlineStatus();
    }

    @OnError
    public void onError(
            Session session,
            Throwable error) {

        System.out.println(
                "WebSocket error: "
                + error.getMessage()
        );
    }

    private void sendToUser(
            int userId,
            String message) {

        Set<Session> userSessions =
                onlineUsers.get(userId);

        if (userSessions == null) {
            return;
        }

        for (Session session : userSessions) {

            if (session.isOpen()) {

                try {

                    session.getBasicRemote()
                            .sendText(message);

                } catch (IOException e) {

                    e.printStackTrace();
                }
            }
        }
    }

    private void broadcastOnlineStatus() {

        StringBuilder onlineIds =
                new StringBuilder(
                        "ONLINE|"
                );

        for (Integer userId :
                onlineUsers.keySet()) {

            if (onlineIds.length() > 7) {
                onlineIds.append(",");
            }

            onlineIds.append(userId);
        }

        String status =
                onlineIds.toString();

        for (Set<Session> sessions :
                onlineUsers.values()) {

            for (Session session : sessions) {

                if (session.isOpen()) {

                    try {

                        session.getBasicRemote()
                                .sendText(status);

                    } catch (IOException e) {

                        e.printStackTrace();
                    }
                }
            }
        }
    }
}