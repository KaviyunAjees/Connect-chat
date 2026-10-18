package com.connectchat.dao;

import com.connectchat.model.User;
import com.connectchat.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class BlockDAO {

    public boolean blockUser(int blockerId, int blockedId) {
        if (blockerId == blockedId) {
            return false;
        }
        String sql = "INSERT IGNORE INTO blocked_users (blocker_id, blocked_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, blockerId);
            ps.setInt(2, blockedId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean unblockUser(int blockerId, int blockedId) {
        String sql = "DELETE FROM blocked_users WHERE blocker_id = ? AND blocked_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, blockerId);
            ps.setInt(2, blockedId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isBlockedBy(int blockerId, int targetId) {
        String sql = "SELECT 1 FROM blocked_users WHERE blocker_id = ? AND blocked_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, blockerId);
            ps.setInt(2, targetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isBlockActiveBetween(int userA, int userB) {
        String sql = "SELECT 1 FROM blocked_users WHERE (blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userA);
            ps.setInt(2, userB);
            ps.setInt(3, userB);
            ps.setInt(4, userA);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<User> getBlockedUsers(int blockerId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.email, u.profile_picture " +
                     "FROM blocked_users b " +
                     "JOIN users u ON b.blocked_id = u.id " +
                     "WHERE b.blocker_id = ? " +
                     "ORDER BY u.username ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, blockerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setProfilePicture(rs.getString("profile_picture"));
                    u.setBlocked(true);
                    list.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Set<Integer> getBlockedUserIds(int blockerId) {
        Set<Integer> set = new HashSet<>();
        String sql = "SELECT blocked_id FROM blocked_users WHERE blocker_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, blockerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    set.add(rs.getInt("blocked_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return set;
    }
}
