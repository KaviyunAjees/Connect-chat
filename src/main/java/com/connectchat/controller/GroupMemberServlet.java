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

@WebServlet("/group-members")
public class GroupMemberServlet extends HttpServlet {

    private final GroupDAO groupDAO =
            new GroupDAO();


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);


        // Check login
        if (session == null ||
                session.getAttribute("user") == null) {

            response.sendRedirect("login.jsp");
            return;
        }


        User currentUser =
                (User) session.getAttribute("user");


        String groupIdParameter =
                request.getParameter("groupId");

        String userIdParameter =
                request.getParameter("userId");


        // Validate parameters
        if (groupIdParameter == null ||
                userIdParameter == null) {

            response.sendRedirect(
                    "messages"
            );

            return;
        }


        int groupId;

        int userId;


        try {

            groupId =
                    Integer.parseInt(
                            groupIdParameter
                    );

            userId =
                    Integer.parseInt(
                            userIdParameter
                    );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    "messages"
            );

            return;
        }


        /*
         * IMPORTANT:
         *
         * Only the group ADMIN can add members.
         */
        boolean admin =
                groupDAO.isAdmin(
                        groupId,
                        currentUser.getId()
                );


        if (!admin) {

            response.sendRedirect(
                    "messages?groupId=" +
                    groupId +
                    "&error=notAdmin"
            );

            return;
        }


        /*
         * Check whether the user
         * is already a member.
         */
        if (groupDAO.isMember(
                groupId,
                userId
        )) {

            response.sendRedirect(
                    "messages?groupId=" +
                    groupId +
                    "&error=alreadyMember"
            );

            return;
        }


        /*
         * New members are always
         * normal members.
         *
         * Only the creator is ADMIN.
         */
        boolean added =
                groupDAO.addMember(
                        groupId,
                        userId,
                        false
                );


        if (added) {

            response.sendRedirect(
                    "messages?groupId=" +
                    groupId
            );

        } else {

            response.sendRedirect(
                    "messages?groupId=" +
                    groupId +
                    "&error=addMember"
            );
        }
    }
}