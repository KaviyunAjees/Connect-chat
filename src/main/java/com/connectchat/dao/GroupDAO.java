package com.connectchat.dao;

import com.connectchat.model.ChatGroup;
import com.connectchat.model.User;
import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class GroupDAO {

    // Create a new group; creator automatically becomes ADMIN
    public int createGroup(String groupName, int createdBy) {
        String sql = "INSERT INTO chat_groups (group_name, created_by, group_picture, is_deleted) " +
                "VALUES (?, ?, 'group-default.png', 0)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            statement.setString(1, groupName);
            statement.setInt(2, createdBy);

            int rows = statement.executeUpdate();
            if (rows == 0) {
                return -1;
            }

            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    int groupId = keys.getInt(1);
                    // Creator becomes admin
                    addMember(groupId, createdBy, true);
                    return groupId;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Add a member to a group
    public boolean addMember(int groupId, int userId, boolean admin) {
        String sql = "INSERT INTO group_members (group_id, user_id, is_admin) VALUES (?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            statement.setInt(2, userId);
            statement.setBoolean(3, admin);

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Remove a member (enforcing admin permissions and creator protection)
    public boolean removeMember(int groupId, int memberId, int requesterId) {
        if (!isAdmin(groupId, requesterId)) {
            return false;
        }

        ChatGroup group = getGroupById(groupId);
        if (group == null || group.isDeleted()) {
            return false;
        }

        // An ordinary admin cannot remove the original group creator
        if (memberId == group.getCreatedBy() && requesterId != group.getCreatedBy()) {
            return false;
        }

        String sql = "DELETE FROM group_members WHERE group_id = ? AND user_id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            statement.setInt(2, memberId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Leave a group (with admin reassignment if creator leaves)
    public boolean leaveGroup(int groupId, int userId) {
        if (!isMember(groupId, userId)) {
            return false;
        }

        ChatGroup group = getGroupById(groupId);
        if (group == null) {
            return false;
        }

        String sql = "DELETE FROM group_members WHERE group_id = ? AND user_id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            statement.setInt(2, userId);
            boolean removed = statement.executeUpdate() > 0;

            if (removed) {
                List<Integer> remainingMembers = getGroupMembers(groupId);
                if (remainingMembers.isEmpty()) {
                    // Soft delete group when empty
                    softDeleteGroup(groupId);
                } else {
                    // If no admin left, promote the first remaining member
                    boolean hasAdmin = false;
                    for (int memberId : remainingMembers) {
                        if (isAdmin(groupId, memberId)) {
                            hasAdmin = true;
                            break;
                        }
                    }
                    if (!hasAdmin && !remainingMembers.isEmpty()) {
                        promoteToAdmin(groupId, remainingMembers.get(0));
                    }
                }
            }
            return removed;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void promoteToAdmin(int groupId, int userId) {
        String sql = "UPDATE group_members SET is_admin = 1 WHERE group_id = ? AND user_id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, groupId);
            statement.setInt(2, userId);
            statement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void softDeleteGroup(int groupId) {
        String sql = "UPDATE chat_groups SET is_deleted = 1 WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, groupId);
            statement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Delete a group (by group creator or admin)
    public boolean deleteGroup(int groupId, int requesterId) {
        if (!isAdmin(groupId, requesterId)) {
            return false;
        }

        String sql = "UPDATE chat_groups SET is_deleted = 1 WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Check whether a user is an admin
    public boolean isAdmin(int groupId, int userId) {
        String sql = "SELECT is_admin FROM group_members WHERE group_id = ? AND user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getBoolean("is_admin");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Check whether a user belongs to a group and group is not deleted
    public boolean isMember(int groupId, int userId) {
        String sql = "SELECT 1 FROM group_members gm " +
                "JOIN chat_groups g ON gm.group_id = g.id " +
                "WHERE gm.group_id = ? AND gm.user_id = ? AND g.is_deleted = 0";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public ChatGroup getGroupById(int groupId) {
        String sql = "SELECT g.id, g.group_name, g.created_by, COALESCE(u.username, 'Unknown') AS creator_name, " +
                "g.group_picture, g.is_deleted, " +
                "(SELECT COUNT(*) FROM group_members gm WHERE gm.group_id = g.id) AS member_count " +
                "FROM chat_groups g " +
                "LEFT JOIN users u ON g.created_by = u.id " +
                "WHERE g.id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    ChatGroup group = new ChatGroup();
                    group.setId(resultSet.getInt("id"));
                    group.setGroupName(resultSet.getString("group_name"));
                    group.setCreatedBy(resultSet.getInt("created_by"));
                    group.setCreatorName(resultSet.getString("creator_name"));
                    String pic = resultSet.getString("group_picture");
                    group.setGroupPicture((pic == null || pic.trim().isEmpty()) ? "group-default.png" : pic);
                    group.setDeleted(resultSet.getBoolean("is_deleted"));
                    group.setMemberCount(resultSet.getInt("member_count"));
                    return group;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get all groups that a user belongs to
    public List<ChatGroup> getGroupsForUser(int userId) {
        List<ChatGroup> groups = new ArrayList<>();

        String sql = "SELECT g.id, g.group_name, g.created_by, " +
                "COALESCE(u.username, 'Unknown') AS creator_name, " +
                "g.group_picture, gm.is_admin, " +
                "(SELECT COUNT(*) FROM group_members gm2 WHERE gm2.group_id = g.id) AS member_count " +
                "FROM chat_groups g " +
                "JOIN group_members gm ON g.id = gm.group_id " +
                "LEFT JOIN users u ON g.created_by = u.id " +
                "WHERE gm.user_id = ? AND g.is_deleted = 0 " +
                "ORDER BY g.group_name ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    ChatGroup group = new ChatGroup();
                    group.setId(resultSet.getInt("id"));
                    group.setGroupName(resultSet.getString("group_name"));
                    group.setCreatedBy(resultSet.getInt("created_by"));
                    group.setCreatorName(resultSet.getString("creator_name"));

                    String groupPicture = resultSet.getString("group_picture");
                    if (groupPicture == null || groupPicture.trim().isEmpty()) {
                        groupPicture = "group-default.png";
                    }
                    group.setGroupPicture(groupPicture);
                    group.setAdmin(resultSet.getBoolean("is_admin"));
                    group.setMemberCount(resultSet.getInt("member_count"));
                    groups.add(group);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return groups;
    }

    // Get all member IDs of a group
    public List<Integer> getGroupMembers(int groupId) {
        List<Integer> members = new ArrayList<>();
        String sql = "SELECT user_id FROM group_members WHERE group_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    members.add(resultSet.getInt("user_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return members;
    }

    // Get full user details for all members of a group
    public List<User> getGroupMembersDetails(int groupId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.email, u.profile_picture, gm.is_admin " +
                "FROM group_members gm " +
                "JOIN users u ON gm.user_id = u.id " +
                "WHERE gm.group_id = ? " +
                "ORDER BY gm.is_admin DESC, u.username ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, groupId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    User u = new User();
                    u.setId(resultSet.getInt("id"));
                    u.setUsername(resultSet.getString("username"));
                    u.setEmail(resultSet.getString("email"));
                    String pic = resultSet.getString("profile_picture");
                    u.setProfilePicture((pic == null || pic.trim().isEmpty()) ? "default.png" : pic);
                    u.setGroupAdmin(resultSet.getBoolean("is_admin"));
                    list.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Get non-members eligible to be added to a group
    public List<User> getNonMembers(int groupId, String search) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT u.id, u.username, u.email, u.profile_picture " +
                "FROM users u " +
                "WHERE u.id NOT IN (SELECT gm.user_id FROM group_members gm WHERE gm.group_id = ?) "
        );

        boolean hasSearch = (search != null && !search.trim().isEmpty());
        if (hasSearch) {
            sql.append("AND (LOWER(u.username) LIKE ? OR LOWER(u.email) LIKE ?) ");
        }
        sql.append("ORDER BY u.username ASC");

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {

            statement.setInt(1, groupId);
            if (hasSearch) {
                String pattern = "%" + search.trim().toLowerCase() + "%";
                statement.setString(2, pattern);
                statement.setString(3, pattern);
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    User u = new User();
                    u.setId(resultSet.getInt("id"));
                    u.setUsername(resultSet.getString("username"));
                    u.setEmail(resultSet.getString("email"));
                    String pic = resultSet.getString("profile_picture");
                    u.setProfilePicture((pic == null || pic.trim().isEmpty()) ? "default.png" : pic);
                    list.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Update group profile picture (admin only)
    public boolean updateGroupPicture(int groupId, int userId, String fileName) {
        if (!isAdmin(groupId, userId)) {
            return false;
        }

        String sql = "UPDATE chat_groups SET group_picture = ? WHERE id = ? AND is_deleted = 0";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, fileName);
            statement.setInt(2, groupId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}