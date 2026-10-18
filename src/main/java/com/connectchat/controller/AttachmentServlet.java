package com.connectchat.controller;

import com.connectchat.dao.BlockDAO;
import com.connectchat.dao.GroupDAO;
import com.connectchat.dao.MessageDAO;
import com.connectchat.dao.UserDAO;
import com.connectchat.model.Message;
import com.connectchat.model.User;
import com.connectchat.util.FileStorageUtil;
import com.connectchat.websocket.ChatWebSocket;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/attachment")
@MultipartConfig(
        maxFileSize = 25 * 1024 * 1024,
        maxRequestSize = 30 * 1024 * 1024
)
public class AttachmentServlet extends HttpServlet {

    private final MessageDAO messageDAO = new MessageDAO();
    private final GroupDAO groupDAO = new GroupDAO();
    private final BlockDAO blockDAO = new BlockDAO();
    private final UserDAO userDAO = new UserDAO();

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
            json.addProperty("error", "User not authenticated.");
            out.print(json.toString());
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int senderId = currentUser.getId();

        String receiverIdParam = request.getParameter("receiverId");
        String groupIdParam = request.getParameter("groupId");
        String messageType = request.getParameter("messageType"); // "IMAGE" or "FILE"

        if (messageType == null || (!messageType.equalsIgnoreCase("IMAGE") && !messageType.equalsIgnoreCase("FILE"))) {
            messageType = "FILE";
        }
        messageType = messageType.toUpperCase();

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "No file uploaded.");
            out.print(json.toString());
            return;
        }

        long fileSize = filePart.getSize();
        if (messageType.equals("IMAGE") && fileSize > FileStorageUtil.MAX_PHOTO_MESSAGE_SIZE) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "Photo size exceeds 10MB limit.");
            out.print(json.toString());
            return;
        }
        if (fileSize > FileStorageUtil.MAX_ATTACHMENT_SIZE) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "File size exceeds 25MB limit.");
            out.print(json.toString());
            return;
        }

        String originalName = FileStorageUtil.sanitizeFileName(filePart.getSubmittedFileName());
        String mimeType = filePart.getContentType();

        if (FileStorageUtil.isForbidden(originalName)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "File type not allowed for security reasons.");
            out.print(json.toString());
            return;
        }

        if (messageType.equals("IMAGE") && !FileStorageUtil.isAllowedImage(originalName, mimeType)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "Invalid image format. Supported formats: JPEG, PNG, WebP, GIF.");
            out.print(json.toString());
            return;
        }

        if (!FileStorageUtil.isAllowedFile(originalName)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "Unsupported file type.");
            out.print(json.toString());
            return;
        }

        // Check destination: Private or Group
        Integer receiverId = null;
        Integer groupId = null;

        if (receiverIdParam != null && !receiverIdParam.trim().isEmpty()) {
            try {
                receiverId = Integer.parseInt(receiverIdParam.trim());
            } catch (NumberFormatException ignored) {}
        }
        if (groupIdParam != null && !groupIdParam.trim().isEmpty()) {
            try {
                groupId = Integer.parseInt(groupIdParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        if (receiverId == null && groupId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("error", "Missing recipient or group.");
            out.print(json.toString());
            return;
        }

        // Validate Private Chat Restrictions
        if (receiverId != null) {
            if (blockDAO.isBlockActiveBetween(senderId, receiverId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                json.addProperty("success", false);
                json.addProperty("error", "Cannot send attachment. Block restriction in effect.");
                out.print(json.toString());
                return;
            }
        }

        // Validate Group Chat Membership
        if (groupId != null) {
            if (!groupDAO.isMember(groupId, senderId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                json.addProperty("success", false);
                json.addProperty("error", "You are not a member of this group.");
                out.print(json.toString());
                return;
            }
        }

        // Save file to storage
        String storedFileName;
        try {
            storedFileName = FileStorageUtil.storeFile(filePart, "attachments");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            json.addProperty("success", false);
            json.addProperty("error", "Failed to store file on server.");
            out.print(json.toString());
            return;
        }

        String caption = request.getParameter("caption");
        if (caption == null || caption.trim().isEmpty()) {
            caption = originalName;
        }

        Message msg = new Message();
        msg.setSenderId(senderId);
        msg.setMessage(caption);
        msg.setMessageType(messageType);
        msg.setFileName(originalName);
        msg.setFilePath(storedFileName);
        msg.setFileSize(fileSize);
        msg.setFileType(mimeType);

        int messageId;
        if (groupId != null) {
            msg.setGroupId(groupId);
            messageId = messageDAO.saveGroupMessageWithId(msg);
        } else {
            msg.setReceiverId(receiverId);
            messageId = messageDAO.saveMessageWithId(msg);
        }

        if (messageId <= 0) {
            // Rollback stored file if DB insertion failed
            File storedFile = FileStorageUtil.getFile("attachments", storedFileName);
            if (storedFile != null && storedFile.exists()) {
                storedFile.delete();
            }
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            json.addProperty("success", false);
            json.addProperty("error", "Failed to save attachment metadata.");
            out.print(json.toString());
            return;
        }

        msg.setId(messageId);

        // Notify participants in real-time via WebSocket
        if (groupId != null) {
            String senderName = currentUser.getUsername();
            String wsMsg = "GROUP_MESSAGE|" + messageId + "|" + senderId + "|" + senderName + "|" + groupId + "|"
                    + messageType + "|" + originalName + "|" + fileSize + "|" + caption;
            ChatWebSocket.sendToGroup(groupId, wsMsg);
        } else {
            String wsMsg = "MESSAGE|" + messageId + "|" + senderId + "|" + receiverId + "|"
                    + messageType + "|" + originalName + "|" + fileSize + "|" + caption;
            ChatWebSocket.sendToUser(senderId, wsMsg);
            ChatWebSocket.sendToUser(receiverId, wsMsg);
        }

        json.addProperty("success", true);
        json.addProperty("messageId", messageId);
        json.addProperty("messageType", messageType);
        json.addProperty("fileName", originalName);
        json.addProperty("fileSize", fileSize);
        json.addProperty("formattedSize", FileStorageUtil.formatFileSize(fileSize));
        json.addProperty("caption", caption);
        json.addProperty("isGroup", groupId != null);
        out.print(json.toString());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authentication required.");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int currentUserId = currentUser.getId();

        String idParam = request.getParameter("id");
        String isGroupParam = request.getParameter("isGroup");
        boolean isGroup = "true".equalsIgnoreCase(isGroupParam) || "1".equals(isGroupParam);
        boolean download = "true".equalsIgnoreCase(request.getParameter("download")) || "1".equals(request.getParameter("download"));

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing message ID.");
            return;
        }

        int messageId;
        try {
            messageId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid message ID.");
            return;
        }

        Message message;
        if (isGroup) {
            message = messageDAO.getGroupMessageById(messageId);
        } else {
            message = messageDAO.getMessageById(messageId);
        }

        if (message == null || message.isDeletedForAll()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Attachment not found or deleted.");
            return;
        }

        // Authorization check: User must be an intended participant
        if (isGroup) {
            if (!groupDAO.isMember(message.getGroupId(), currentUserId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. You are not a member of this group.");
                return;
            }
        } else {
            if (message.getSenderId() != currentUserId && message.getReceiverId() != currentUserId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. You are not a participant in this conversation.");
                return;
            }
        }

        String storedPath = message.getFilePath();
        if (storedPath == null || storedPath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Attachment file missing.");
            return;
        }

        File file = FileStorageUtil.getFile("attachments", storedPath);
        if (file == null || !file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Physical file not found.");
            return;
        }

        String mimeType = message.getFileType();
        if (mimeType == null || mimeType.trim().isEmpty()) {
            mimeType = getServletContext().getMimeType(message.getFileName());
        }
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }

        response.setContentType(mimeType);
        response.setContentLengthLong(file.length());

        String originalName = message.getFileName() != null ? message.getFileName() : "attachment";
        String encodedFilename = URLEncoder.encode(originalName, StandardCharsets.UTF_8).replace("+", "%20");

        if (download || (!mimeType.startsWith("image/") && !mimeType.equals("application/pdf"))) {
            response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFilename);
        } else {
            response.setHeader("Content-Disposition", "inline; filename*=UTF-8''" + encodedFilename);
        }

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            in.transferTo(out);
        }
    }
}
