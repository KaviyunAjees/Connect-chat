package com.connectchat.controller;

import com.connectchat.dao.UserDAO;
import com.connectchat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || email == null || email.trim().isEmpty() || !email.contains("@")
                || password == null || password.trim().isEmpty()) {
            response.sendRedirect("register.jsp?error=invalid_input");
            return;
        }

        User user = new User(username.trim(), email.trim().toLowerCase(), password);

        boolean registered = userDAO.registerUser(user);

        if (registered) {
            response.sendRedirect("login.jsp?success=registered");
        } else {
            response.sendRedirect("register.jsp?error=registration_failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }
}