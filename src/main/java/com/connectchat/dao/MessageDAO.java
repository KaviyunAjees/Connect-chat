package com.connectchat.dao;

import com.connectchat.model.Message;
import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {

    public boolean sendMessage(Message message) {

        String sql =
                "INSERT INTO messages " +
                "(sender_id, receiver_id, message) " +
                "VALUES (?, ?, ?)";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(
                    1,
                    message.getSenderId()
            );

            statement.setInt(
                    2,
                    message.getReceiverId()
            );

            statement.setString(
                    3,
                    message.getMessage()
            );

            return statement.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

            return false;
        }
    }

    public List<Message> getConversation(
            int user1,
            int user2
    ) {

        List<Message> messages =
                new ArrayList<>();

        String sql =
                "SELECT id, sender_id, receiver_id, message " +
                "FROM messages " +
                "WHERE (sender_id = ? AND receiver_id = ?) " +
                "OR (sender_id = ? AND receiver_id = ?) " +
                "ORDER BY id ASC";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, user1);
            statement.setInt(2, user2);
            statement.setInt(3, user2);
            statement.setInt(4, user1);

            ResultSet resultSet =
                    statement.executeQuery();

            while (resultSet.next()) {

                Message message =
                        new Message(
                                resultSet.getInt("id"),
                                resultSet.getInt("sender_id"),
                                resultSet.getInt("receiver_id"),
                                resultSet.getString("message")
                        );

                messages.add(message);
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return messages;
    }
}