package com.connectchat.controller;

import com.connectchat.dao.GroupDAO;
import com.connectchat.model.User;
import com.connectchat.util.FileStorageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;

@WebServlet("/group-profile")
@MultipartConfig(
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class GroupProfileServlet extends HttpServlet {

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
        String groupIdParam = request.getParameter("groupId");

        if (groupIdParam == null || groupIdParam.trim().isEmpty()) {
            response.sendRedirect("messages?error=missingGroup");
            return;
        }

        int groupId;
        try {
            groupId = Integer.parseInt(groupIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("messages?error=invalidGroup");
            return;
        }

        // Authorization check: only group admin can update picture
        if (!groupDAO.isAdmin(groupId, currentUser.getId())) {
            response.sendRedirect("messages?groupId=" + groupId + "&error=notAdmin");
            return;
        }

        Part filePart = request.getPart("groupPicture");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("messages?groupId=" + groupId);
            return;
        }

        String originalName = FileStorageUtil.sanitizeFileName(filePart.getSubmittedFileName());
        String contentType = filePart.getContentType();

        if (!FileStorageUtil.isAllowedImage(originalName, contentType)) {
            response.sendRedirect("messages?groupId=" + groupId + "&error=invalidImage");
            return;
        }

        try {
            String fileName = FileStorageUtil.storeFile(filePart, "groups");
            boolean updated = groupDAO.updateGroupPicture(groupId, currentUser.getId(), fileName);

            if (updated) {
                response.sendRedirect("messages?groupId=" + groupId + "&success=groupPictureUpdated");
            } else {
                File savedFile = FileStorageUtil.getFile("groups", fileName);
                if (savedFile != null && savedFile.exists()) {
                    savedFile.delete();
                }
                response.sendRedirect("messages?groupId=" + groupId + "&error=updateFailed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("messages?groupId=" + groupId + "&error=uploadFailed");
        }
    }
}
