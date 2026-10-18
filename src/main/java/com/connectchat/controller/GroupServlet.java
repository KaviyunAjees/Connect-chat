package com.connectchat.controller;

import com.connectchat.dao.GroupDAO;
import com.connectchat.model.ChatGroup;
import com.connectchat.model.User;
import com.connectchat.websocket.ChatWebSocket;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/groups")
public class GroupServlet extends HttpServlet {

    private final GroupDAO groupDAO = new GroupDAO();

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

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getContentType() != null && request.getContentType().contains("application/json"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"));

        // ===================================
        // 1. CREATE GROUP
        // ===================================
        if ("create".equalsIgnoreCase(action)) {
            String groupName = request.getParameter("groupName");
            if (groupName == null || groupName.trim().isEmpty()) {
                sendResult(response, isAjax, false, "Group name is required.", "messages?error=groupName", null);
                return;
            }

            groupName = groupName.trim();
            int groupId = groupDAO.createGroup(groupName, currentUser.getId());

            if (groupId > 0) {
                sendResult(response, isAjax, true, "Group created successfully.", "messages?groupId=" + groupId, groupId);
            } else {
                sendResult(response, isAjax, false, "Failed to create group.", "messages?error=groupCreate", null);
            }
            return;
        }

        // ===================================
        // 2. LEAVE GROUP
        // ===================================
        if ("leave".equalsIgnoreCase(action)) {
            String groupIdParam = request.getParameter("groupId");
            if (groupIdParam == null || groupIdParam.trim().isEmpty()) {
                sendResult(response, isAjax, false, "Missing group ID.", "messages", null);
                return;
            }

            int groupId;
            try {
                groupId = Integer.parseInt(groupIdParam.trim());
            } catch (NumberFormatException e) {
                sendResult(response, isAjax, false, "Invalid group ID.", "messages", null);
                return;
            }

            boolean left = groupDAO.leaveGroup(groupId, currentUser.getId());
            if (left) {
                ChatWebSocket.notifyGroupEvent(groupId, "MEMBER_LEFT", currentUser.getUsername());
                sendResult(response, isAjax, true, "You have left the group.", "messages?success=leftGroup", null);
            } else {
                sendResult(response, isAjax, false, "Failed to leave group.", "messages?groupId=" + groupId + "&error=leaveFailed", null);
            }
            return;
        }

        // ===================================
        // 3. DELETE GROUP (ADMIN ONLY)
        // ===================================
        if ("delete".equalsIgnoreCase(action)) {
            String groupIdParam = request.getParameter("groupId");
            if (groupIdParam == null || groupIdParam.trim().isEmpty()) {
                sendResult(response, isAjax, false, "Missing group ID.", "messages", null);
                return;
            }

            int groupId;
            try {
                groupId = Integer.parseInt(groupIdParam.trim());
            } catch (NumberFormatException e) {
                sendResult(response, isAjax, false, "Invalid group ID.", "messages", null);
                return;
            }

            // Verify authorization
            if (!groupDAO.isAdmin(groupId, currentUser.getId())) {
                sendResult(response, isAjax, false, "Only group administrators can delete this group.", "messages?groupId=" + groupId + "&error=notAdmin", null);
                return;
            }

            boolean deleted = groupDAO.deleteGroup(groupId, currentUser.getId());
            if (deleted) {
                ChatWebSocket.notifyGroupEvent(groupId, "GROUP_DELETED", "The group has been deleted by an administrator.");
                sendResult(response, isAjax, true, "Group deleted successfully.", "messages?success=groupDeleted", null);
            } else {
                sendResult(response, isAjax, false, "Failed to delete group.", "messages?groupId=" + groupId + "&error=deleteFailed", null);
            }
            return;
        }

        // Unknown action
        response.sendRedirect("messages");
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