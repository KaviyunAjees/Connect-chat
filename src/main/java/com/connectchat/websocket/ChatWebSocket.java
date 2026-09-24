package com.connectchat.websocket;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

@ServerEndpoint("/chat")
public class ChatWebSocket {

    private static final Set<Session> sessions =
            new CopyOnWriteArraySet<>();

    @OnOpen
    public void onOpen(Session session) {

        sessions.add(session);

        System.out.println(
                "User connected: " + session.getId()
        );

        broadcast(
                "A user joined the chat"
        );
    }

    @OnMessage
    public void onMessage(String message, Session sender) {

        System.out.println(
                "Message received: " + message
        );

        broadcast(message);
    }

    @OnClose
    public void onClose(Session session) {

        sessions.remove(session);

        System.out.println(
                "User disconnected: " + session.getId()
        );

        broadcast(
                "A user left the chat"
        );
    }

    @OnError
    public void onError(Session session, Throwable error) {

        System.out.println(
                "WebSocket error: " + error.getMessage()
        );
    }

    private void broadcast(String message) {

        for (Session session : sessions) {

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
}