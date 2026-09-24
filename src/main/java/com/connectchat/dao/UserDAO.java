package com.connectchat.dao;

import com.connectchat.model.User;
import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public boolean registerUser(User user) {

        String sql =
                "INSERT INTO users (username, email, password) " +
                "VALUES (?, ?, ?)";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPassword());

            return statement.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

            return false;
        }
    }


    public User loginUser(String email, String password) {

        String sql =
                "SELECT * FROM users " +
                "WHERE email = ? AND password = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setString(1, email);
            statement.setString(2, password);

            ResultSet resultSet =
                    statement.executeQuery();

            if (resultSet.next()) {

                return new User(
                        resultSet.getInt("id"),
                        resultSet.getString("username"),
                        resultSet.getString("email"),
                        resultSet.getString("password")
                );
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return null;
    }


    // Get all registered users except current user

    public List<User> getAllUsers(int currentUserId) {

        List<User> users = new ArrayList<>();

        String sql =
                "SELECT id, username, email " +
                "FROM users " +
                "WHERE id != ? " +
                "ORDER BY username ASC";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, currentUserId);

            ResultSet resultSet =
                    statement.executeQuery();

            while (resultSet.next()) {

                User user = new User();

                user.setId(
                        resultSet.getInt("id")
                );

                user.setUsername(
                        resultSet.getString("username")
                );

                user.setEmail(
                        resultSet.getString("email")
                );

                users.add(user);
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return users;
    }


    // Get one user by ID

    public User getUserById(int userId) {

        String sql =
                "SELECT id, username, email " +
                "FROM users " +
                "WHERE id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, userId);

            ResultSet resultSet =
                    statement.executeQuery();

            if (resultSet.next()) {

                User user = new User();

                user.setId(
                        resultSet.getInt("id")
                );

                user.setUsername(
                        resultSet.getString("username")
                );

                user.setEmail(
                        resultSet.getString("email")
                );

                return user;
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return null;
    }
}