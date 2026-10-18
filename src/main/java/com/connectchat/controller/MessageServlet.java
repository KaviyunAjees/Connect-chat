package com.connectchat.controller;

import com.connectchat.dao.GroupDAO;
import com.connectchat.dao.MessageDAO;
import com.connectchat.dao.UserDAO;
import com.connectchat.model.ChatGroup;
import com.connectchat.model.Message;
import com.connectchat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/messages")
public class MessageServlet extends HttpServlet {

    private final MessageDAO messageDAO =
            new MessageDAO();

    private final UserDAO userDAO =
            new UserDAO();

    private final GroupDAO groupDAO =
            new GroupDAO();


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        // Check login
        if (session == null ||
                session.getAttribute("user") == null) {

            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser =
                (User) session.getAttribute("user");


        // =========================
        // AVAILABLE USERS
        // =========================

        List<User> users =
                userDAO.getAllUsers(
                        currentUser.getId()
                );


        // =========================
        // USER CHAT
        // =========================

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


        User receiver = null;

        List<Message> messages =
                new ArrayList<>();


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


        // =========================
        // GROUPS
        // =========================

        List<ChatGroup> groups =
                groupDAO.getGroupsForUser(
                        currentUser.getId()
                );


        // =========================
        // SELECTED GROUP
        // =========================

        String groupIdParameter =
                request.getParameter("groupId");

        Integer groupId = null;

        ChatGroup selectedGroup = null;

        List<Message> groupMessages =
                new ArrayList<>();


        if (groupIdParameter != null &&
                !groupIdParameter.isEmpty()) {

            try {

                groupId =
                        Integer.parseInt(
                                groupIdParameter
                        );

            } catch (NumberFormatException e) {

                groupId = null;
            }
        }


        if (groupId != null) {

            // Security check:
            // user must belong to group
            if (groupDAO.isMember(
                    groupId,
                    currentUser.getId())) {

                groupMessages =
                        messageDAO.getGroupMessages(
                                groupId
                        );

                // Find selected group
                for (ChatGroup group : groups) {

                    if (group.getId() == groupId) {

                        selectedGroup = group;
                        break;
                    }
                }
            } else {

                groupId = null;
            }
        }


        // =========================
        // SEND DATA TO JSP
        // =========================

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

        request.setAttribute(
                "groups",
                groups
        );

        request.setAttribute(
                "selectedGroup",
                selectedGroup
        );

        request.setAttribute(
                "groupMessages",
                groupMessages
        );

        request.setAttribute(
                "groupId",
                groupId
        );


        // Open chat page
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

        String receiverId =
                request.getParameter(
                        "receiverId"
                );

        String groupId =
                request.getParameter(
                        "groupId"
                );


        // Private chat
        if (receiverId != null &&
                !receiverId.isEmpty()) {

            response.sendRedirect(
                    "messages?receiverId=" +
                    receiverId
            );

            return;
        }


        // Group chat
        if (groupId != null &&
                !groupId.isEmpty()) {

            response.sendRedirect(
                    "messages?groupId=" +
                    groupId
            );

            return;
        }


        response.sendRedirect("messages");
    }
}