package com.connectchat.dao;

import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class GroupMessageDAO {

    // Save a group message
    public boolean saveMessage(
            int groupId,
            int senderId,
            String message) {

        String sql =
                "INSERT INTO group_messages " +
                "(group_id, sender_id, message) " +
                "VALUES (?, ?, ?)";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, groupId);
            statement.setInt(2, senderId);
            statement.setString(3, message);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return false;
    }


    // Get all messages from a group
    public List<String[]> getMessages(
            int groupId) {

        List<String[]> messages =
                new ArrayList<>();

        String sql =
                "SELECT gm.sender_id, " +
                "u.username, " +
                "gm.message, " +
                "gm.sent_at " +
                "FROM group_messages gm " +
                "JOIN users u " +
                "ON gm.sender_id = u.id " +
                "WHERE gm.group_id = ? " +
                "ORDER BY gm.sent_at ASC";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, groupId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {

                    String[] messageData =
                            new String[4];

                    messageData[0] =
                            String.valueOf(
                                    resultSet.getInt(
                                            "sender_id"
                                    )
                            );

                    messageData[1] =
                            resultSet.getString(
                                    "username"
                            );

                    messageData[2] =
                            resultSet.getString(
                                    "message"
                            );

                    messageData[3] =
                            resultSet.getString(
                                    "sent_at"
                            );

                    messages.add(messageData);
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return messages;
    }
}