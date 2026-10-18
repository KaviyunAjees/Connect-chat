package com.connectchat.dao;

import com.connectchat.model.ChatGroup;
import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class GroupDAO {

    // Create a new group
    // The creator automatically becomes ADMIN
    public int createGroup(
            String groupName,
            int createdBy) {

        String sql =
                "INSERT INTO chat_groups " +
                "(group_name, created_by, group_picture) " +
                "VALUES (?, ?, 'group-default.png')";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(
                                sql,
                                Statement.RETURN_GENERATED_KEYS
                        )
        ) {

            statement.setString(1, groupName);
            statement.setInt(2, createdBy);

            int rows =
                    statement.executeUpdate();

            if (rows == 0) {
                return -1;
            }

            try (ResultSet keys =
                         statement.getGeneratedKeys()) {

                if (keys.next()) {

                    int groupId =
                            keys.getInt(1);

                    // Creator becomes admin
                    addMember(
                            groupId,
                            createdBy,
                            true
                    );

                    return groupId;
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return -1;
    }


    // Add a member to a group
    public boolean addMember(
            int groupId,
            int userId,
            boolean admin) {

        String sql =
                "INSERT INTO group_members " +
                "(group_id, user_id, is_admin) " +
                "VALUES (?, ?, ?)";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, groupId);
            statement.setInt(2, userId);
            statement.setBoolean(3, admin);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return false;
    }


    // Check whether a user is an admin
    public boolean isAdmin(
            int groupId,
            int userId) {

        String sql =
                "SELECT is_admin " +
                "FROM group_members " +
                "WHERE group_id = ? " +
                "AND user_id = ?";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, groupId);
            statement.setInt(2, userId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                if (resultSet.next()) {

                    return resultSet.getBoolean(
                            "is_admin"
                    );
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return false;
    }


    // Check whether a user belongs to a group
    public boolean isMember(
            int groupId,
            int userId) {

        String sql =
                "SELECT 1 " +
                "FROM group_members " +
                "WHERE group_id = ? " +
                "AND user_id = ?";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, groupId);
            statement.setInt(2, userId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                return resultSet.next();
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return false;
    }


    // Get all groups that a user belongs to
    public List<ChatGroup> getGroupsForUser(
            int userId) {

        List<ChatGroup> groups =
                new ArrayList<>();

        String sql =
                "SELECT g.id, " +
                "g.group_name, " +
                "g.created_by, " +
                "u.username AS creator_name, " +
                "g.group_picture, " +
                "gm.is_admin " +
                "FROM chat_groups g " +
                "JOIN group_members gm " +
                "ON g.id = gm.group_id " +
                "JOIN users u " +
                "ON g.created_by = u.id " +
                "WHERE gm.user_id = ? " +
                "ORDER BY g.group_name";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, userId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {

                    ChatGroup group =
                            new ChatGroup();

                    group.setId(
                            resultSet.getInt("id")
                    );

                    group.setGroupName(
                            resultSet.getString(
                                    "group_name"
                            )
                    );

                    group.setCreatedBy(
                            resultSet.getInt(
                                    "created_by"
                            )
                    );

                    group.setCreatorName(
                            resultSet.getString(
                                    "creator_name"
                            )
                    );

                    String groupPicture =
                            resultSet.getString(
                                    "group_picture"
                            );

                    if (groupPicture == null ||
                            groupPicture.trim().isEmpty()) {

                        groupPicture =
                                "group-default.png";
                    }

                    group.setGroupPicture(
                            groupPicture
                    );

                    group.setAdmin(
                            resultSet.getBoolean(
                                    "is_admin"
                            )
                    );

                    groups.add(group);
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return groups;
    }


    // Get all members of a group
    public List<Integer> getGroupMembers(
            int groupId) {

        List<Integer> members =
                new ArrayList<>();

        String sql =
                "SELECT user_id " +
                "FROM group_members " +
                "WHERE group_id = ?";

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

                    members.add(
                            resultSet.getInt(
                                    "user_id"
                            )
                    );
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return members;
    }


    // Update group profile picture
    // Only an admin can update it
    public boolean updateGroupPicture(
            int groupId,
            int userId,
            String fileName) {

        String sql =
                "UPDATE chat_groups " +
                "SET group_picture = ? " +
                "WHERE id = ? " +
                "AND EXISTS (" +
                "SELECT 1 FROM group_members " +
                "WHERE group_id = ? " +
                "AND user_id = ? " +
                "AND is_admin = TRUE" +
                ")";

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setString(1, fileName);
            statement.setInt(2, groupId);
            statement.setInt(3, groupId);
            statement.setInt(4, userId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return false;
    }
}