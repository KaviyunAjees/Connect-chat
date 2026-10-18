package com.connectchat.controller;

import com.connectchat.dao.UserDAO;
import com.connectchat.model.User;
import com.connectchat.util.FileStorageUtil;
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
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/profile")
@MultipartConfig(
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class ProfileServlet extends HttpServlet {

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

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getContentType() != null && request.getContentType().contains("application/json"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"));

        Part filePart = request.getPart("profilePicture");
        if (filePart == null || filePart.getSize() == 0) {
            sendResponse(response, isAjax, false, "No image file provided.", "messages");
            return;
        }

        String originalName = FileStorageUtil.sanitizeFileName(filePart.getSubmittedFileName());
        String contentType = filePart.getContentType();

        if (!FileStorageUtil.isAllowedImage(originalName, contentType)) {
            sendResponse(response, isAjax, false, "Invalid image format. Supported formats: JPEG, PNG, WebP, GIF.", "messages?error=invalidImage");
            return;
        }

        try {
            String fileName = FileStorageUtil.storeFile(filePart, "profiles");
            boolean updated = userDAO.updateProfilePicture(currentUser.getId(), fileName);

            if (updated) {
                currentUser.setProfilePicture(fileName);
                session.setAttribute("user", currentUser);
                sendResponse(response, isAjax, true, "Profile picture updated successfully.", "messages?success=profileUpdated");
            } else {
                File stored = FileStorageUtil.getFile("profiles", fileName);
                if (stored != null && stored.exists()) {
                    stored.delete();
                }
                sendResponse(response, isAjax, false, "Failed to update profile picture in database.", "messages?error=uploadFailed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(response, isAjax, false, "Error during profile picture upload.", "messages?error=uploadFailed");
        }
    }

    private void sendResponse(HttpServletResponse response, boolean isAjax, boolean success, String message, String redirectUrl)
            throws IOException {
        if (isAjax) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            JsonObject json = new JsonObject();
            json.addProperty("success", success);
            json.addProperty("message", message);
            PrintWriter out = response.getWriter();
            out.print(json.toString());
        } else {
            response.sendRedirect(redirectUrl);
        }
    }
}