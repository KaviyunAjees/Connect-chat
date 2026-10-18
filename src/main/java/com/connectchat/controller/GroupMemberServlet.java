package com.connectchat.controller;

import com.connectchat.dao.GroupDAO;
import com.connectchat.dao.UserDAO;
import com.connectchat.model.User;
import com.connectchat.websocket.ChatWebSocket;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/group-members")
public class GroupMemberServlet extends HttpServlet {

    private final GroupDAO groupDAO = new GroupDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        String groupIdParameter = request.getParameter("groupId");
        String userIdParameter = request.getParameter("userId");

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getContentType() != null && request.getContentType().contains("application/json"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"));

        if (groupIdParameter == null || userIdParameter == null) {
            sendResult(response, isAjax, false, "Missing parameters.", "messages", null);
            return;
        }

        int groupId;
        int targetUserId;
        try {
            groupId = Integer.parseInt(groupIdParameter.trim());
            targetUserId = Integer.parseInt(userIdParameter.trim());
        } catch (NumberFormatException e) {
            sendResult(response, isAjax, false, "Invalid group or user ID.", "messages", null);
            return;
        }

        // Authorization check: Only group admin can add or remove members
        boolean isAdmin = groupDAO.isAdmin(groupId, currentUser.getId());
        if (!isAdmin) {
            sendResult(response, isAjax, false, "Only group administrators can manage members.",
                    "messages?groupId=" + groupId + "&error=notAdmin", groupId);
            return;
        }

        // ===================================
        // 1. REMOVE MEMBER
        // ===================================
        if ("remove".equalsIgnoreCase(action)) {
            boolean removed = groupDAO.removeMember(groupId, targetUserId, currentUser.getId());
            if (removed) {
                User targetUser = userDAO.getUserById(targetUserId);
                String targetName = (targetUser != null) ? targetUser.getUsername() : "Member";

                // Notify removed member and remaining members via WebSocket
                ChatWebSocket.sendToUser(targetUserId, "GROUP_EVENT|" + groupId + "|REMOVED_FROM_GROUP|" + targetName);
                ChatWebSocket.notifyGroupEvent(groupId, "MEMBER_REMOVED", targetName);

                sendResult(response, isAjax, true, "Member removed successfully.",
                        "messages?groupId=" + groupId, groupId);
            } else {
                sendResult(response, isAjax, false, "Failed to remove member. Group creator cannot be removed.",
                        "messages?groupId=" + groupId + "&error=removeMember", groupId);
            }
            return;
        }

        // ===================================
        // 2. ADD MEMBER
        // ===================================
        if (groupDAO.isMember(groupId, targetUserId)) {
            sendResult(response, isAjax, false, "User is already a member.",
                    "messages?groupId=" + groupId + "&error=alreadyMember", groupId);
            return;
        }

        boolean added = groupDAO.addMember(groupId, targetUserId, false);
        if (added) {
            User targetUser = userDAO.getUserById(targetUserId);
            String targetName = (targetUser != null) ? targetUser.getUsername() : "Member";

            // Real-time notification to the added user and to the group
            ChatWebSocket.sendToUser(targetUserId, "GROUP_EVENT|" + groupId + "|ADDED_TO_GROUP|" + targetName);
            ChatWebSocket.notifyGroupEvent(groupId, "MEMBER_JOINED", targetName);

            sendResult(response, isAjax, true, "Member added successfully.",
                    "messages?groupId=" + groupId, groupId);
        } else {
            sendResult(response, isAjax, false, "Failed to add member.",
                    "messages?groupId=" + groupId + "&error=addMember", groupId);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String groupIdParam = request.getParameter("groupId");
        String type = request.getParameter("type"); // "members" or "nonmembers"
        String search = request.getParameter("search");

        if (groupIdParam == null || groupIdParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int groupId;
        try {
            groupId = Integer.parseInt(groupIdParam.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JsonArray array = new JsonArray();

        if ("nonmembers".equalsIgnoreCase(type)) {
            List<User> nonMembers = groupDAO.getNonMembers(groupId, search);
            for (User u : nonMembers) {
                JsonObject obj = new JsonObject();
                obj.addProperty("id", u.getId());
                obj.addProperty("username", u.getUsername());
                obj.addProperty("email", u.getEmail());
                obj.addProperty("profilePicture", u.getProfilePicture());
                array.add(obj);
            }
        } else {
            List<User> members = groupDAO.getGroupMembersDetails(groupId);
            for (User u : members) {
                JsonObject obj = new JsonObject();
                obj.addProperty("id", u.getId());
                obj.addProperty("username", u.getUsername());
                obj.addProperty("email", u.getEmail());
                obj.addProperty("profilePicture", u.getProfilePicture());
                obj.addProperty("isAdmin", u.isGroupAdmin());
                array.add(obj);
            }
        }

        PrintWriter out = response.getWriter();
        out.print(array.toString());
    }

    private void sendResult(HttpServletResponse response, boolean isAjax, boolean success, String message, String redirectUrl, Integer groupId)
            throws IOException {
        if (isAjax) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            JsonObject json = new JsonObject();
            json.addProperty("success", success);
            json.addProperty("message", message);
            if (groupId != null) {
                json.addProperty("groupId", groupId);
            }
            PrintWriter out = response.getWriter();
            out.print(json.toString());
        } else {
            response.sendRedirect(redirectUrl);
        }
    }
}