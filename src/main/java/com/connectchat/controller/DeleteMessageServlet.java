package com.connectchat.controller;

import com.connectchat.dao.GroupDAO;
import com.connectchat.dao.MessageDAO;
import com.connectchat.model.Message;
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

@WebServlet("/delete-message")
public class DeleteMessageServlet extends HttpServlet {

    private final MessageDAO messageDAO = new MessageDAO();
    private final GroupDAO groupDAO = new GroupDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject json = new JsonObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.addProperty("success", false);
            json.addProperty("error", "Authentication required.");
            out.print(json.toString());
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int currentUserId = currentUser.getId();

        String messageIdParam = request.getParameter("messageId");
        String isGroupParam = request.getParameter("isGroup");
        String deleteType = request.getParameter("deleteType"); // "me" or "everyone"

        if (messageIdParam == null || messageIdParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "Missing message ID.");
            out.print(json.toString());
            return;
        }

        int messageId;
        try {
            messageId = Integer.parseInt(messageIdParam.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "Invalid message ID.");
            out.print(json.toString());
            return;
        }

        boolean isGroup = "true".equalsIgnoreCase(isGroupParam) || "1".equals(isGroupParam);
        if (deleteType == null || (!deleteType.equalsIgnoreCase("me") && !deleteType.equalsIgnoreCase("everyone"))) {
            deleteType = "me";
        }

        // ===================================
        // DELETE FOR ME
        // ===================================
        if ("me".equalsIgnoreCase(deleteType)) {
            boolean deleted = messageDAO.deleteForMe(currentUserId, messageId, isGroup);
            json.addProperty("success", deleted);
            json.addProperty("deleteType", "me");
            json.addProperty("messageId", messageId);
            json.addProperty("isGroup", isGroup);
            out.print(json.toString());
            return;
        }

        // ===================================
        // DELETE FOR EVERYONE
        // ===================================
        if (isGroup) {
            Message groupMsg = messageDAO.getGroupMessageById(messageId);
            if (groupMsg == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                json.addProperty("success", false);
                json.addProperty("error", "Group message not found.");
                out.print(json.toString());
                return;
            }

            // Only original sender OR group admin can delete for everyone
            boolean isSender = (groupMsg.getSenderId() == currentUserId);
            boolean isAdmin = groupDAO.isAdmin(groupMsg.getGroupId(), currentUserId);

            if (!isSender && !isAdmin) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                json.addProperty("success", false);
                json.addProperty("error", "Only the sender or a group admin can delete this message for everyone.");
                out.print(json.toString());
                return;
            }

            boolean deleted = messageDAO.deleteGroupMessageForEveryone(messageId, currentUserId);
            if (deleted) {
                // Synchronize via WebSocket to all members of the group
                ChatWebSocket.notifyMessageDeleted(messageId, true, groupMsg.getGroupId());
                json.addProperty("success", true);
                json.addProperty("deleteType", "everyone");
                json.addProperty("messageId", messageId);
                json.addProperty("isGroup", true);
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                json.addProperty("success", false);
                json.addProperty("error", "Failed to delete group message.");
            }
            out.print(json.toString());

        } else {
            Message privMsg = messageDAO.getMessageById(messageId);
            if (privMsg == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                json.addProperty("success", false);
                json.addProperty("error", "Message not found.");
                out.print(json.toString());
                return;
            }

            // Only original sender can delete private message for everyone
            if (privMsg.getSenderId() != currentUserId) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                json.addProperty("success", false);
                json.addProperty("error", "You can only delete your own messages for everyone.");
                out.print(json.toString());
                return;
            }

            boolean deleted = messageDAO.deleteForEveryone(messageId, currentUserId);
            if (deleted) {
                // Synchronize via WebSocket to both sender and receiver
                ChatWebSocket.notifyMessageDeleted(messageId, false, privMsg.getSenderId());
                ChatWebSocket.notifyMessageDeleted(messageId, false, privMsg.getReceiverId());
                json.addProperty("success", true);
                json.addProperty("deleteType", "everyone");
                json.addProperty("messageId", messageId);
                json.addProperty("isGroup", false);
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                json.addProperty("success", false);
                json.addProperty("error", "Failed to delete message.");
            }
            out.print(json.toString());
        }
    }
}
