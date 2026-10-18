package com.connectchat.websocket;

import com.connectchat.dao.GroupDAO;
import com.connectchat.dao.GroupMessageDAO;
import com.connectchat.dao.MessageDAO;
import com.connectchat.model.Message;

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

    /*
     * Stores all currently connected users.
     *
     * One user can have multiple browser sessions,
     * so each user has a Set of WebSocket sessions.
     */
    private static final Map<Integer, Set<Session>> onlineUsers =
            new ConcurrentHashMap<>();


    private final MessageDAO messageDAO =
            new MessageDAO();

    private final GroupDAO groupDAO =
            new GroupDAO();

    private final GroupMessageDAO groupMessageDAO =
            new GroupMessageDAO();


    // =========================================================
    // USER CONNECTS
    // =========================================================

    @OnOpen
    public void onOpen(Session session) {

        String userIdParameter =
                session.getRequestParameterMap()
                        .getOrDefault(
                                "userId",
                                Collections.emptyList()
                        )
                        .stream()
                        .findFirst()
                        .orElse(null);


        if (userIdParameter == null) {

            System.out.println(
                    "WebSocket opened without user ID"
            );

            return;
        }


        try {

            int userId =
                    Integer.parseInt(
                            userIdParameter
                    );


            // Store user ID inside this session
            session.getUserProperties()
                    .put(
                            "userId",
                            userId
                    );


            // Add session to online users
            onlineUsers
                    .computeIfAbsent(
                            userId,
                            key ->
                                    ConcurrentHashMap.newKeySet()
                    )
                    .add(session);


            System.out.println(
                    "User online: " + userId
            );


            // Tell all connected users about
            // current online status
            broadcastOnlineStatus();


        } catch (NumberFormatException e) {

            System.out.println(
                    "Invalid user ID: "
                            + userIdParameter
            );
        }
    }


    // =========================================================
    // RECEIVE MESSAGE
    // =========================================================

    @OnMessage
    public void onMessage(
            String message,
            Session senderSession) {

        try {

            if (message == null ||
                    message.trim().isEmpty()) {

                return;
            }


            // =================================================
            // PRIVATE CHAT
            // Format:
            //
            // PRIVATE|senderId|receiverId|message
            // =================================================

            if (message.startsWith("PRIVATE|")) {

                handlePrivateMessage(
                        message
                );

                return;
            }


            // =================================================
            // GROUP CHAT
            // Format:
            //
            // GROUP|senderId|groupId|message
            // =================================================

            if (message.startsWith("GROUP|")) {

                handleGroupMessage(
                        message
                );

                return;
            }


        } catch (Exception e) {

            e.printStackTrace();
        }
    }


    // =========================================================
    // PRIVATE MESSAGE
    // =========================================================

    private void handlePrivateMessage(
            String message) {

        String[] parts =
                message.split(
                        "\\|",
                        4
                );


        if (parts.length < 4) {

            return;
        }


        int senderId =
                Integer.parseInt(
                        parts[1]
                );


        int receiverId =
                Integer.parseInt(
                        parts[2]
                );


        String text =
                parts[3];


        // Create message object
        Message chatMessage =
                new Message(
                        senderId,
                        receiverId,
                        text
                );


        // Save message in database
        boolean saved =
                messageDAO.sendMessage(
                        chatMessage
                );


        if (!saved) {

            System.out.println(
                    "Private message could not be saved"
            );

            return;
        }


        /*
         * Send message to sender.
         */
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


        /*
         * Send message to receiver.
         */
        sendToUser(
                receiverId,
                responseMessage
        );
    }


    // =========================================================
    // GROUP MESSAGE
    // =========================================================

    private void handleGroupMessage(
            String message) {

        String[] parts =
                message.split(
                        "\\|",
                        4
                );


        if (parts.length < 4) {

            return;
        }


        int senderId =
                Integer.parseInt(
                        parts[1]
                );


        int groupId =
                Integer.parseInt(
                        parts[2]
                );


        String text =
                parts[3];


        /*
         * SECURITY CHECK:
         *
         * Only a user who belongs to the group
         * can send a group message.
         */
        if (!groupDAO.isMember(
                groupId,
                senderId
        )) {

            System.out.println(
                    "User " +
                    senderId +
                    " is not a member of group " +
                    groupId
            );

            return;
        }


        /*
         * Save group message.
         */
        boolean saved =
                groupMessageDAO.saveMessage(
                        groupId,
                        senderId,
                        text
                );


        if (!saved) {

            System.out.println(
                    "Group message could not be saved"
            );

            return;
        }


        /*
         * Format sent to all group members:
         *
         * GROUP_MESSAGE|senderId|groupId|message
         */
        String responseMessage =
                "GROUP_MESSAGE|" +
                senderId +
                "|" +
                groupId +
                "|" +
                text;


        /*
         * Send the message to every
         * member of the group.
         */
        sendToGroup(
                groupId,
                responseMessage
        );
    }


    // =========================================================
    // SEND TO ONE USER
    // =========================================================

    private void sendToUser(
            int userId,
            String message) {

        Set<Session> userSessions =
                onlineUsers.get(
                        userId
                );


        if (userSessions == null) {

            return;
        }


        for (Session session :
                userSessions) {

            if (!session.isOpen()) {

                continue;
            }


            try {

                session.getBasicRemote()
                        .sendText(
                                message
                        );

            } catch (IOException e) {

                e.printStackTrace();
            }
        }
    }


    // =========================================================
    // SEND TO GROUP
    // =========================================================

    private void sendToGroup(
            int groupId,
            String message) {

        List<Integer> members =
                groupDAO.getGroupMembers(
                        groupId
                );


        for (Integer userId :
                members) {

            sendToUser(
                    userId,
                    message
            );
        }
    }


    // =========================================================
    // USER DISCONNECTS
    // =========================================================

    @OnClose
    public void onClose(
            Session session) {

        Object userIdObject =
                session.getUserProperties()
                        .get(
                                "userId"
                        );


        if (userIdObject == null) {

            return;
        }


        int userId =
                (Integer)
                        userIdObject;


        Set<Session> userSessions =
                onlineUsers.get(
                        userId
                );


        if (userSessions != null) {

            userSessions.remove(
                    session
            );


            /*
             * If the user has no more
             * open sessions, mark offline.
             */
            if (userSessions.isEmpty()) {

                onlineUsers.remove(
                        userId
                );


                System.out.println(
                        "User offline: "
                                + userId
                );
            }
        }


        // Update online status
        broadcastOnlineStatus();
    }


    // =========================================================
    // WEBSOCKET ERROR
    // =========================================================

    @OnError
    public void onError(
            Session session,
            Throwable error) {

        System.out.println(
                "WebSocket error: "
                        + error.getMessage()
        );
    }


    // =========================================================
    // ONLINE STATUS
    // =========================================================

    private void broadcastOnlineStatus() {

        /*
         * Format:
         *
         * ONLINE|1,2,3
         *
         * Example:
         *
         * ONLINE|1,2
         */
        StringBuilder onlineIds =
                new StringBuilder(
                        "ONLINE|"
                );


        for (Integer userId :
                onlineUsers.keySet()) {

            if (onlineIds.length() > 7) {

                onlineIds.append(",");
            }


            onlineIds.append(
                    userId
            );
        }


        String status =
                onlineIds.toString();


        /*
         * Send status to every
         * currently connected user.
         */
        for (Set<Session> sessions :
                onlineUsers.values()) {

            for (Session session :
                    sessions) {

                if (!session.isOpen()) {

                    continue;
                }


                try {

                    session.getBasicRemote()
                            .sendText(
                                    status
                            );

                } catch (IOException e) {

                    e.printStackTrace();
                }
            }
        }
    }
}