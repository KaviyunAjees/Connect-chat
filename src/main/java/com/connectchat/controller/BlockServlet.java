package com.connectchat.controller;

import com.connectchat.dao.BlockDAO;
import com.connectchat.dao.UserDAO;
import com.connectchat.model.User;
import com.google.gson.Gson;
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

@WebServlet("/block")
public class BlockServlet extends HttpServlet {

    private final BlockDAO blockDAO = new BlockDAO();
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action"); // "block" or "unblock"
        String targetUserIdParam = request.getParameter("userId");

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getContentType() != null && request.getContentType().contains("application/json"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"));

        if (targetUserIdParam == null || targetUserIdParam.trim().isEmpty()) {
            sendResponse(response, isAjax, false, "Missing user ID", null);
            return;
        }

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(targetUserIdParam.trim());
        } catch (NumberFormatException e) {
            sendResponse(response, isAjax, false, "Invalid user ID", null);
            return;
        }

        if (targetUserId == currentUser.getId()) {
            sendResponse(response, isAjax, false, "Cannot block yourself", targetUserId);
            return;
        }

        boolean success = false;
        String message;

        if ("unblock".equalsIgnoreCase(action)) {
            success = blockDAO.unblockUser(currentUser.getId(), targetUserId);
            message = success ? "User unblocked successfully." : "Failed to unblock user.";
        } else {
            success = blockDAO.blockUser(currentUser.getId(), targetUserId);
            message = success ? "User blocked successfully." : "Failed to block user.";
        }

        sendResponse(response, isAjax, success, message, targetUserId);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        List<User> blockedUsers = blockDAO.getBlockedUsers(currentUser.getId());

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JsonArray array = new JsonArray();
        for (User u : blockedUsers) {
            JsonObject obj = new JsonObject();
            obj.addProperty("id", u.getId());
            obj.addProperty("username", u.getUsername());
            obj.addProperty("email", u.getEmail());
            obj.addProperty("profilePicture", u.getProfilePicture());
            array.add(obj);
        }

        PrintWriter out = response.getWriter();
        out.print(array.toString());
    }

    private void sendResponse(HttpServletResponse response, boolean isAjax, boolean success, String message, Integer targetId)
            throws IOException {
        if (isAjax) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            JsonObject json = new JsonObject();
            json.addProperty("success", success);
            json.addProperty("message", message);
            if (targetId != null) {
                json.addProperty("userId", targetId);
            }
            PrintWriter out = response.getWriter();
            out.print(json.toString());
        } else {
            String redirectUrl = "messages" + (targetId != null ? "?receiverId=" + targetId : "");
            response.sendRedirect(redirectUrl);
        }
    }
}
