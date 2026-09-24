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

    private MessageDAO messageDAO;
    private UserDAO userDAO;


    @Override
    public void init() {

        messageDAO = new MessageDAO();
        userDAO = new UserDAO();
    }


    // SEND MESSAGE

    @Override
    protected void doPost(
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


        String receiverIdText =
                request.getParameter("receiverId");

        String messageText =
                request.getParameter("message");


        if (receiverIdText == null ||
            messageText == null ||
            messageText.trim().isEmpty()) {

            response.sendRedirect("chat.jsp");
            return;
        }


        int receiverId =
                Integer.parseInt(receiverIdText);


        Message message =
                new Message(
                        currentUser.getId(),
                        receiverId,
                        messageText.trim()
                );


        boolean sent =
                messageDAO.sendMessage(message);


        // After sending, open same conversation

        response.sendRedirect(
                "messages?receiverId=" + receiverId
        );
    }


    // LOAD CONVERSATION

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


        String receiverIdText =
                request.getParameter("receiverId");


        if (receiverIdText == null) {

            response.sendRedirect("chat.jsp");
            return;
        }


        int receiverId =
                Integer.parseInt(receiverIdText);


        // Get messages

        List<Message> messages =
                messageDAO.getConversation(
                        currentUser.getId(),
                        receiverId
                );


        // Get receiver information

        User receiver =
                userDAO.getUserById(receiverId);


        // Get all users

        List<User> users =
                userDAO.getAllUsers(
                        currentUser.getId()
                );


        request.setAttribute(
                "messages",
                messages
        );


        request.setAttribute(
                "receiverId",
                receiverId
        );


        request.setAttribute(
                "receiver",
                receiver
        );


        request.setAttribute(
                "users",
                users
        );


        request.getRequestDispatcher(
                "chat.jsp"
        ).forward(request, response);
    }
}