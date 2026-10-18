package com.connectchat.controller;

import com.connectchat.dao.UserDAO;
import com.connectchat.model.User;

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
import java.util.UUID;

@WebServlet("/profile")
@MultipartConfig(
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

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

        Part filePart =
                request.getPart("profilePicture");

        if (filePart == null ||
                filePart.getSize() == 0) {

            response.sendRedirect("messages");
            return;
        }

        String contentType =
                filePart.getContentType();

        if (contentType == null ||
                !contentType.startsWith("image/")) {

            response.sendRedirect(
                    "messages?error=invalidImage"
            );

            return;
        }

        String originalName =
                filePart.getSubmittedFileName();

        String extension = "";

        if (originalName != null &&
                originalName.contains(".")) {

            extension =
                    originalName.substring(
                            originalName.lastIndexOf(".")
                    );
        }

        String fileName =
                UUID.randomUUID().toString()
                + extension;

        String uploadPath =
                getServletContext()
                .getRealPath("/uploads/profiles");

        File uploadDirectory =
                new File(uploadPath);

        if (!uploadDirectory.exists()) {
            uploadDirectory.mkdirs();
        }

        File uploadedFile =
                new File(uploadDirectory, fileName);

        filePart.write(
                uploadedFile.getAbsolutePath()
        );

        boolean updated =
                userDAO.updateProfilePicture(
                        currentUser.getId(),
                        fileName
                );

        if (updated) {

            currentUser.setProfilePicture(fileName);

            session.setAttribute(
                    "user",
                    currentUser
            );

            response.sendRedirect("messages");

        } else {

            if (uploadedFile.exists()) {
                uploadedFile.delete();
            }

            response.sendRedirect(
                    "messages?error=uploadFailed"
            );
        }
    }
}