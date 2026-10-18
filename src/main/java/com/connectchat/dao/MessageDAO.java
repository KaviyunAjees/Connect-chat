package com.connectchat.dao;

import com.connectchat.model.Message;
import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {

    // =========================
    // PRIVATE CHAT
    // =========================

    public boolean sendMessage(Message message) {
        return saveMessageWithId(message) > 0;
    }

    public int saveMessageWithId(Message message) {
        String sql = "INSERT INTO messages " +
                "(sender_id, receiver_id, message, message_type, file_name, file_path, file_size, file_type, deleted_for_all) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, message.getSenderId());
            statement.setInt(2, message.getReceiverId());
            statement.setString(3, message.getMessage() != null ? message.getMessage() : "");
            statement.setString(4, message.getMessageType() != null ? message.getMessageType() : "TEXT");
            statement.setString(5, message.getFileName());
            statement.setString(6, message.getFilePath());

            if (message.getFileSize() != null) {
                statement.setLong(7, message.getFileSize());
            } else {
                statement.setNull(7, Types.BIGINT);
            }

            statement.setString(8, message.getFileType());
            statement.setBoolean(9, message.isDeletedForAll());

            int affected = statement.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = statement.getGeneratedKeys()) {
                    if (keys.next()) {
                        int id = keys.getInt(1);
                        message.setId(id);
                        return id;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Get private conversation (excluding messages deleted by current user)
    public List<Message> getConversation(int user1, int user2) {
        List<Message> messages = new ArrayList<>();

        String sql = "SELECT m.id, m.sender_id, m.receiver_id, m.message, m.message_type, " +
                "m.file_name, m.file_path, m.file_size, m.file_type, m.deleted_for_all, m.created_at, " +
                "u.username AS sender_name " +
                "FROM messages m " +
                "JOIN users u ON m.sender_id = u.id " +
                "WHERE ((m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?)) " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 FROM message_deletions md " +
                "    WHERE md.user_id = ? AND md.message_id = m.id AND md.is_group = 0 " +
                ") " +
                "ORDER BY m.id ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, user1);
            statement.setInt(2, user2);
            statement.setInt(3, user2);
            statement.setInt(4, user1);
            statement.setInt(5, user1); // Exclude messages deleted by current viewing user

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Message message = mapResultSetToMessage(resultSet, false);
                    messages.add(message);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return messages;
    }

    public Message getMessageById(int id) {
        String sql = "SELECT m.id, m.sender_id, m.receiver_id, m.message, m.message_type, " +
                "m.file_name, m.file_path, m.file_size, m.file_type, m.deleted_for_all, m.created_at, " +
                "u.username AS sender_name " +
                "FROM messages m " +
                "JOIN users u ON m.sender_id = u.id " +
                "WHERE m.id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToMessage(resultSet, false);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // =========================
    // GROUP CHAT
    // =========================

    public boolean sendGroupMessage(int groupId, int senderId, String message) {
        Message msg = new Message();
        msg.setGroupId(groupId);
        msg.setSenderId(senderId);
        msg.setMessage(message);
        msg.setMessageType("TEXT");
        return saveGroupMessageWithId(msg) > 0;
    }

    public int saveGroupMessageWithId(Message message) {
        String sql = "INSERT INTO group_messages " +
                "(group_id, sender_id, message, message_type, file_name, file_path, file_size, file_type, deleted_for_all) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, message.getGroupId());
            statement.setInt(2, message.getSenderId());
            statement.setString(3, message.getMessage() != null ? message.getMessage() : "");
            statement.setString(4, message.getMessageType() != null ? message.getMessageType() : "TEXT");
            statement.setString(5, message.getFileName());
            statement.setString(6, message.getFilePath());

            if (message.getFileSize() != null) {
                statement.setLong(7, message.getFileSize());
            } else {
                statement.setNull(7, Types.BIGINT);
            }

            statement.setString(8, message.getFileType());
            statement.setBoolean(9, message.isDeletedForAll());

            int affected = statement.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = statement.getGeneratedKeys()) {
                    if (keys.next()) {
                        int id = keys.getInt(1);
                        message.setId(id);
                        return id;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<Message> getGroupMessages(int groupId) {
        return getGroupMessages(groupId, 0);
    }

    public List<Message> getGroupMessages(int groupId, int currentUserId) {
        List<Message> messages = new ArrayList<>();

        String sql = "SELECT gm.id, gm.group_id, gm.sender_id, gm.message, gm.message_type, " +
                "gm.file_name, gm.file_path, gm.file_size, gm.file_type, gm.deleted_for_all, gm.sent_at AS created_at, " +
                "u.username AS sender_name " +
                "FROM group_messages gm " +
                "JOIN users u ON gm.sender_id = u.id " +
                "WHERE gm.group_id = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 FROM message_deletions md " +
                "    WHERE md.user_id = ? AND md.message_id = gm.id AND md.is_group = 1 " +
                ") " +
                "ORDER BY gm.id ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            statement.setInt(2, currentUserId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Message message = mapResultSetToMessage(resultSet, true);
                    messages.add(message);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return messages;
    }

    public Message getGroupMessageById(int id) {
        String sql = "SELECT gm.id, gm.group_id, gm.sender_id, gm.message, gm.message_type, " +
                "gm.file_name, gm.file_path, gm.file_size, gm.file_type, gm.deleted_for_all, gm.sent_at AS created_at, " +
                "u.username AS sender_name " +
                "FROM group_messages gm " +
                "JOIN users u ON gm.sender_id = u.id " +
                "WHERE gm.id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToMessage(resultSet, true);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // =========================
    // DELETIONS
    // =========================

    public boolean deleteForMe(int userId, int messageId, boolean isGroup) {
        String sql = "INSERT IGNORE INTO message_deletions (user_id, message_id, is_group) VALUES (?, ?, ?)";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, messageId);
            statement.setInt(3, isGroup ? 1 : 0);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteForEveryone(int messageId, int userId) {
        // Enforce ownership: only the original sender can delete private messages for everyone
        String sql = "UPDATE messages SET deleted_for_all = 1, message = 'This message was deleted' " +
                "WHERE id = ? AND sender_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, messageId);
            statement.setInt(2, userId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteGroupMessageForEveryone(int messageId, int userId) {
        // Sender OR group admin can delete for everyone
        String sql = "UPDATE group_messages gm " +
                "SET gm.deleted_for_all = 1, gm.message = 'This message was deleted' " +
                "WHERE gm.id = ? " +
                "AND (gm.sender_id = ? OR EXISTS (" +
                "    SELECT 1 FROM group_members gm2 " +
                "    WHERE gm2.group_id = gm.group_id AND gm2.user_id = ? AND gm2.is_admin = 1" +
                "))";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, messageId);
            statement.setInt(2, userId);
            statement.setInt(3, userId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Message mapResultSetToMessage(ResultSet resultSet, boolean isGroup) throws SQLException {
        Message message = new Message();
        message.setId(resultSet.getInt("id"));
        message.setSenderId(resultSet.getInt("sender_id"));

        if (isGroup) {
            message.setGroupId(resultSet.getInt("group_id"));
        } else {
            message.setReceiverId(resultSet.getInt("receiver_id"));
        }

        boolean deletedForAll = resultSet.getBoolean("deleted_for_all");
        message.setDeletedForAll(deletedForAll);

        if (deletedForAll) {
            message.setMessage("This message was deleted");
            message.setMessageType("TEXT");
            message.setFileName(null);
            message.setFilePath(null);
            message.setFileSize(null);
            message.setFileType(null);
        } else {
            message.setMessage(resultSet.getString("message"));
            message.setMessageType(resultSet.getString("message_type"));
            message.setFileName(resultSet.getString("file_name"));
            message.setFilePath(resultSet.getString("file_path"));
            long size = resultSet.getLong("file_size");
            if (!resultSet.wasNull()) {
                message.setFileSize(size);
            }
            message.setFileType(resultSet.getString("file_type"));
        }

        message.setSenderName(resultSet.getString("sender_name"));
        message.setCreatedAt(resultSet.getString("created_at"));
        return message;
    }
}