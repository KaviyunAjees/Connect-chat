package com.connectchat.controller;

import com.connectchat.dao.MessageDAO;
import com.connectchat.dao.UserDAO;
import com.connectchat.model.Message;
import com.connectchat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/messages")
public class MessageServlet extends HttpServlet {

    private final MessageDAO messageDAO =
            new MessageDAO();

    private final UserDAO userDAO =
            new UserDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null ||
                session.getAttribute("user") == null) {

            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser =
                (User) session.getAttribute("user");

        String receiverParameter =
                request.getParameter("receiverId");

        Integer receiverId = null;

        if (receiverParameter != null &&
                !receiverParameter.isEmpty()) {

            try {

                receiverId =
                        Integer.parseInt(
                                receiverParameter
                        );

            } catch (NumberFormatException e) {

                receiverId = null;
            }
        }

        List<User> users =
                userDAO.getAllUsers(
                        currentUser.getId()
                );

        List<Message> messages =
                new java.util.ArrayList<>();

        User receiver = null;

        if (receiverId != null) {

            messages =
                    messageDAO.getConversation(
                            currentUser.getId(),
                            receiverId
                    );

            receiver =
                    userDAO.getUserById(
                            receiverId
                    );
        }

        request.setAttribute(
                "users",
                users
        );

        request.setAttribute(
                "messages",
                messages
        );

        request.setAttribute(
                "receiver",
                receiver
        );

        request.setAttribute(
                "receiverId",
                receiverId
        );

        request.getRequestDispatcher(
                "chat.jsp"
        ).forward(
                request,
                response
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        /*
         * Message saving is now handled by WebSocket.
         * This POST is intentionally not used for messages.
         */

        String receiverId =
                request.getParameter(
                        "receiverId"
                );

        response.sendRedirect(
                "messages?receiverId="
                        + receiverId
        );
    }
}