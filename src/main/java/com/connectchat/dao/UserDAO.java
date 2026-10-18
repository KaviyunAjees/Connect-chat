package com.connectchat.dao;

import com.connectchat.model.User;
import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // Register a new user
    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (username, email, password, profile_picture) VALUES (?, ?, ?, 'default.png')";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getUsername() != null ? user.getUsername().trim() : "");
            statement.setString(2, user.getEmail() != null ? user.getEmail().trim().toLowerCase() : "");
            statement.setString(3, user.getPassword());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Login user
    public User loginUser(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, email != null ? email.trim().toLowerCase() : "");
            statement.setString(2, password);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    User user = new User(
                            resultSet.getInt("id"),
                            resultSet.getString("username"),
                            resultSet.getString("email"),
                            resultSet.getString("password")
                    );

                    String pic = resultSet.getString("profile_picture");
                    user.setProfilePicture((pic == null || pic.trim().isEmpty()) ? "default.png" : pic);

                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get all users except the currently logged-in user
    public List<User> getAllUsers(int currentUserId) {
        List<User> users = new ArrayList<>();

        String sql = "SELECT u.id, u.username, u.email, u.profile_picture, " +
                "EXISTS(SELECT 1 FROM blocked_users b WHERE b.blocker_id = ? AND b.blocked_id = u.id) AS is_blocked " +
                "FROM users u " +
                "WHERE u.id != ? " +
                "ORDER BY u.username ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, currentUserId);
            statement.setInt(2, currentUserId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    User user = new User();
                    user.setId(resultSet.getInt("id"));
                    user.setUsername(resultSet.getString("username"));
                    user.setEmail(resultSet.getString("email"));
                    String pic = resultSet.getString("profile_picture");
                    user.setProfilePicture((pic == null || pic.trim().isEmpty()) ? "default.png" : pic);
                    user.setBlocked(resultSet.getBoolean("is_blocked"));

                    users.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    // Get one user by ID
    public User getUserById(int userId) {
        return getUserById(userId, 0);
    }

    // Get user by ID with blocked status relative to viewer
    public User getUserById(int userId, int viewerId) {
        String sql = "SELECT u.id, u.username, u.email, u.profile_picture, " +
                "EXISTS(SELECT 1 FROM blocked_users b WHERE b.blocker_id = ? AND b.blocked_id = u.id) AS is_blocked " +
                "FROM users u " +
                "WHERE u.id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, viewerId);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    User user = new User();
                    user.setId(resultSet.getInt("id"));
                    user.setUsername(resultSet.getString("username"));
                    user.setEmail(resultSet.getString("email"));
                    String pic = resultSet.getString("profile_picture");
                    user.setProfilePicture((pic == null || pic.trim().isEmpty()) ? "default.png" : pic);
                    user.setBlocked(resultSet.getBoolean("is_blocked"));

                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Update the user's profile picture
    public boolean updateProfilePicture(int userId, String fileName) {
        String sql = "UPDATE users SET profile_picture = ? WHERE id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, fileName);
            statement.setInt(2, userId);

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}