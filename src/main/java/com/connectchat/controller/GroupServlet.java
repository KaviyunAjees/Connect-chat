package com.connectchat.controller;

import com.connectchat.dao.GroupDAO;
import com.connectchat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/groups")
public class GroupServlet extends HttpServlet {

    private final GroupDAO groupDAO =
            new GroupDAO();


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        // User must be logged in
        if (session == null ||
                session.getAttribute("user") == null) {

            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser =
                (User) session.getAttribute("user");

        String action =
                request.getParameter("action");


        // CREATE GROUP
        if ("create".equals(action)) {

            String groupName =
                    request.getParameter("groupName");


            // Validate group name
            if (groupName == null ||
                    groupName.trim().isEmpty()) {

                response.sendRedirect(
                        "messages?error=groupName"
                );

                return;
            }


            groupName =
                    groupName.trim();


            // Create group
            // Creator automatically becomes ADMIN
            int groupId =
                    groupDAO.createGroup(
                            groupName,
                            currentUser.getId()
                    );


            if (groupId > 0) {

                response.sendRedirect(
                        "messages?groupId=" +
                        groupId
                );

            } else {

                response.sendRedirect(
                        "messages?error=groupCreate"
                );
            }

            return;
        }


        // Unknown action
        response.sendRedirect("messages");
    }
}