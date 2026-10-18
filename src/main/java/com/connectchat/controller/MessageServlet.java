package com.connectchat.controller;

import com.connectchat.dao.BlockDAO;
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

    private final MessageDAO messageDAO = new MessageDAO();
    private final UserDAO userDAO = new UserDAO();
    private final GroupDAO groupDAO = new GroupDAO();
    private final BlockDAO blockDAO = new BlockDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int currentUserId = currentUser.getId();

        // Refresh user profile picture from DB in session
        User refreshedUser = userDAO.getUserById(currentUserId);
        if (refreshedUser != null) {
            currentUser = refreshedUser;
            session.setAttribute("user", currentUser);
        }

        // =========================
        // AVAILABLE USERS
        // =========================
        List<User> users = userDAO.getAllUsers(currentUserId);

        // =========================
        // BLOCKED USERS LIST
        // =========================
        List<User> blockedUsers = blockDAO.getBlockedUsers(currentUserId);

        // =========================
        // USER PRIVATE CHAT
        // =========================
        String receiverParameter = request.getParameter("receiverId");
        Integer receiverId = null;

        if (receiverParameter != null && !receiverParameter.trim().isEmpty()) {
            try {
                receiverId = Integer.parseInt(receiverParameter.trim());
            } catch (NumberFormatException e) {
                receiverId = null;
            }
        }

        User receiver = null;
        List<Message> messages = new ArrayList<>();
        boolean isBlockedByMe = false;
        boolean isBlockedByThem = false;

        if (receiverId != null && receiverId != currentUserId) {
            receiver = userDAO.getUserById(receiverId, currentUserId);
            if (receiver != null) {
                messages = messageDAO.getConversation(currentUserId, receiverId);
                isBlockedByMe = blockDAO.isBlockedBy(currentUserId, receiverId);
                isBlockedByThem = blockDAO.isBlockedBy(receiverId, currentUserId);
            } else {
                receiverId = null;
            }
        } else {
            receiverId = null;
        }

        // =========================
        // GROUPS
        // =========================
        List<ChatGroup> groups = groupDAO.getGroupsForUser(currentUserId);

        // =========================
        // SELECTED GROUP
        // =========================
        String groupIdParameter = request.getParameter("groupId");
        Integer groupId = null;
        ChatGroup selectedGroup = null;
        List<Message> groupMessages = new ArrayList<>();
        List<User> groupMembers = new ArrayList<>();
        List<User> nonMembers = new ArrayList<>();
        boolean isGroupAdmin = false;

        if (groupIdParameter != null && !groupIdParameter.trim().isEmpty()) {
            try {
                groupId = Integer.parseInt(groupIdParameter.trim());
            } catch (NumberFormatException e) {
                groupId = null;
            }
        }

        if (groupId != null) {
            // Check group membership and existence
            if (groupDAO.isMember(groupId, currentUserId)) {
                selectedGroup = groupDAO.getGroupById(groupId);
                if (selectedGroup != null && !selectedGroup.isDeleted()) {
                    isGroupAdmin = groupDAO.isAdmin(groupId, currentUserId);
                    selectedGroup.setAdmin(isGroupAdmin);

                    groupMessages = messageDAO.getGroupMessages(groupId, currentUserId);
                    groupMembers = groupDAO.getGroupMembersDetails(groupId);
                    nonMembers = groupDAO.getNonMembers(groupId, null);
                } else {
                    groupId = null;
                    selectedGroup = null;
                }
            } else {
                groupId = null;
            }
        }

        // =========================
        // SET ATTRIBUTES FOR JSP
        // =========================
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("users", users);
        request.setAttribute("blockedUsers", blockedUsers);
        request.setAttribute("messages", messages);
        request.setAttribute("receiver", receiver);
        request.setAttribute("receiverId", receiverId);
        request.setAttribute("isBlockedByMe", isBlockedByMe);
        request.setAttribute("isBlockedByThem", isBlockedByThem);

        request.setAttribute("groups", groups);
        request.setAttribute("selectedGroup", selectedGroup);
        request.setAttribute("groupMessages", groupMessages);
        request.setAttribute("groupId", groupId);
        request.setAttribute("groupMembers", groupMembers);
        request.setAttribute("nonMembers", nonMembers);
        request.setAttribute("isGroupAdmin", isGroupAdmin);

        request.getRequestDispatcher("chat.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String receiverId = request.getParameter("receiverId");
        String groupId = request.getParameter("groupId");

        if (receiverId != null && !receiverId.trim().isEmpty()) {
            response.sendRedirect("messages?receiverId=" + receiverId.trim());
            return;
        }

        if (groupId != null && !groupId.trim().isEmpty()) {
            response.sendRedirect("messages?groupId=" + groupId.trim());
            return;
        }

        response.sendRedirect("messages");
    }
}