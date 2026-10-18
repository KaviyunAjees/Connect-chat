package com.connectchat;

import com.connectchat.dao.BlockDAO;
import com.connectchat.dao.GroupDAO;
import com.connectchat.dao.MessageDAO;
import com.connectchat.dao.UserDAO;
import com.connectchat.model.ChatGroup;
import com.connectchat.model.Message;
import com.connectchat.model.User;
import com.connectchat.util.DBConnection;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

public class DatabaseDAOTest {

    private static boolean dbAvailable = false;
    private final UserDAO userDAO = new UserDAO();
    private final BlockDAO blockDAO = new BlockDAO();
    private final GroupDAO groupDAO = new GroupDAO();
    private final MessageDAO messageDAO = new MessageDAO();

    @BeforeAll
    public static void checkDbConnection() {
        try (Connection conn = DBConnection.getConnection()) {
            dbAvailable = (conn != null && !conn.isClosed());
        } catch (SQLException e) {
            System.err.println("Database is not reachable for test: " + e.getMessage());
            dbAvailable = false;
        }
    }

    @Test
    public void testUserRegistrationAndLogin() {
        if (!dbAvailable) return;

        String testUsername = "testuser_" + UUID.randomUUID().toString().substring(0, 8);
        String testEmail = testUsername + "@example.com";
        String password = "securePassword123";

        User newUser = new User(testUsername, testEmail, password);
        boolean registered = userDAO.registerUser(newUser);
        assertTrue(registered, "User should register successfully.");

        User loggedInUser = userDAO.loginUser(testEmail, password);
        assertNotNull(loggedInUser, "User should be able to login.");
        assertEquals(testUsername, loggedInUser.getUsername());

        // Test profile picture update
        boolean picUpdated = userDAO.updateProfilePicture(loggedInUser.getId(), "avatar123.png");
        assertTrue(picUpdated, "Profile picture should update successfully.");

        User refreshed = userDAO.getUserById(loggedInUser.getId());
        assertEquals("avatar123.png", refreshed.getProfilePicture());
    }

    @Test
    public void testBlockAndUnblock() {
        if (!dbAvailable) return;

        // Create two temporary test users
        String u1Name = "blocker_" + UUID.randomUUID().toString().substring(0, 8);
        String u2Name = "blocked_" + UUID.randomUUID().toString().substring(0, 8);

        userDAO.registerUser(new User(u1Name, u1Name + "@test.com", "pass"));
        userDAO.registerUser(new User(u2Name, u2Name + "@test.com", "pass"));

        User u1 = userDAO.loginUser(u1Name + "@test.com", "pass");
        User u2 = userDAO.loginUser(u2Name + "@test.com", "pass");

        assertNotNull(u1);
        assertNotNull(u2);

        // Initially not blocked
        assertFalse(blockDAO.isBlockedBy(u1.getId(), u2.getId()));
        assertFalse(blockDAO.isBlockActiveBetween(u1.getId(), u2.getId()));

        // Block user 2
        boolean blocked = blockDAO.blockUser(u1.getId(), u2.getId());
        assertTrue(blocked, "User 1 should block user 2 successfully.");
        assertTrue(blockDAO.isBlockedBy(u1.getId(), u2.getId()));
        assertTrue(blockDAO.isBlockActiveBetween(u1.getId(), u2.getId()));

        List<User> blockedList = blockDAO.getBlockedUsers(u1.getId());
        assertTrue(blockedList.stream().anyMatch(u -> u.getId() == u2.getId()), "User 2 should appear in User 1's blocked list.");

        // Unblock user 2
        boolean unblocked = blockDAO.unblockUser(u1.getId(), u2.getId());
        assertTrue(unblocked, "User 1 should unblock user 2 successfully.");
        assertFalse(blockDAO.isBlockedBy(u1.getId(), u2.getId()));
        assertFalse(blockDAO.isBlockActiveBetween(u1.getId(), u2.getId()));
    }

    @Test
    public void testGroupAdminFeaturesAndPermissions() {
        if (!dbAvailable) return;

        // Create creator and member
        String creatorName = "creator_" + UUID.randomUUID().toString().substring(0, 8);
        String memberName = "member_" + UUID.randomUUID().toString().substring(0, 8);

        userDAO.registerUser(new User(creatorName, creatorName + "@test.com", "pass"));
        userDAO.registerUser(new User(memberName, memberName + "@test.com", "pass"));

        User creator = userDAO.loginUser(creatorName + "@test.com", "pass");
        User member = userDAO.loginUser(memberName + "@test.com", "pass");

        // 1. Creator creates group
        int groupId = groupDAO.createGroup("Test Team " + UUID.randomUUID().toString().substring(0, 6), creator.getId());
        assertTrue(groupId > 0, "Group should be created successfully.");

        // Creator should automatically be admin and member
        assertTrue(groupDAO.isAdmin(groupId, creator.getId()), "Creator must be admin.");
        assertTrue(groupDAO.isMember(groupId, creator.getId()), "Creator must be member.");

        // Member initially not member
        assertFalse(groupDAO.isMember(groupId, member.getId()));

        // 2. Creator adds member
        boolean added = groupDAO.addMember(groupId, member.getId(), false);
        assertTrue(added, "Member should be added.");
        assertTrue(groupDAO.isMember(groupId, member.getId()), "User should now be a member.");
        assertFalse(groupDAO.isAdmin(groupId, member.getId()), "Added user should not be admin.");

        // 3. Ordinary member cannot remove creator or other members
        boolean unauthorizedRemove = groupDAO.removeMember(groupId, creator.getId(), member.getId());
        assertFalse(unauthorizedRemove, "Ordinary member should NOT be authorized to remove creator.");

        // 4. Creator removes member
        boolean removed = groupDAO.removeMember(groupId, member.getId(), creator.getId());
        assertTrue(removed, "Creator should be able to remove ordinary member.");
        assertFalse(groupDAO.isMember(groupId, member.getId()), "Removed user should no longer be a member.");

        // 5. Creator deletes group
        boolean deleted = groupDAO.deleteGroup(groupId, creator.getId());
        assertTrue(deleted, "Admin should be able to delete group.");

        ChatGroup group = groupDAO.getGroupById(groupId);
        assertTrue(group.isDeleted(), "Group should be marked as deleted.");
        assertFalse(groupDAO.isMember(groupId, creator.getId()), "Deleted group should not report active membership.");
    }

    @Test
    public void testMessageSendingAndDeletion() {
        if (!dbAvailable) return;

        String sName = "sender_" + UUID.randomUUID().toString().substring(0, 8);
        String rName = "receiver_" + UUID.randomUUID().toString().substring(0, 8);

        userDAO.registerUser(new User(sName, sName + "@test.com", "pass"));
        userDAO.registerUser(new User(rName, rName + "@test.com", "pass"));

        User sender = userDAO.loginUser(sName + "@test.com", "pass");
        User receiver = userDAO.loginUser(rName + "@test.com", "pass");

        // Send normal message
        Message msg = new Message();
        msg.setSenderId(sender.getId());
        msg.setReceiverId(receiver.getId());
        msg.setMessage("Hello, this is a test message!");
        msg.setMessageType("TEXT");

        int msgId = messageDAO.saveMessageWithId(msg);
        assertTrue(msgId > 0, "Message ID should be generated and returned.");

        // Send attachment message
        Message fileMsg = new Message();
        fileMsg.setSenderId(sender.getId());
        fileMsg.setReceiverId(receiver.getId());
        fileMsg.setMessage("Project specs");
        fileMsg.setMessageType("FILE");
        fileMsg.setFileName("specs.pdf");
        fileMsg.setFilePath("uuid_specs.pdf");
        fileMsg.setFileSize(204800L);
        fileMsg.setFileType("application/pdf");

        int fileMsgId = messageDAO.saveMessageWithId(fileMsg);
        assertTrue(fileMsgId > 0, "File attachment message should be saved with ID.");

        // Retrieve conversation
        List<Message> convo = messageDAO.getConversation(sender.getId(), receiver.getId());
        assertTrue(convo.stream().anyMatch(m -> m.getId() == msgId), "Normal message should be present in conversation.");
        assertTrue(convo.stream().anyMatch(m -> m.getId() == fileMsgId), "File message should be present in conversation.");

        // Test "Delete for me" by sender
        boolean deletedForMe = messageDAO.deleteForMe(sender.getId(), msgId, false);
        assertTrue(deletedForMe, "Sender should be able to delete message for themselves.");

        // Sender's view should no longer include msgId
        List<Message> senderView = messageDAO.getConversation(sender.getId(), receiver.getId());
        assertFalse(senderView.stream().anyMatch(m -> m.getId() == msgId), "Message should be hidden from sender.");

        // Receiver's view should STILL include msgId
        List<Message> receiverView = messageDAO.getConversation(receiver.getId(), sender.getId());
        assertTrue(receiverView.stream().anyMatch(m -> m.getId() == msgId), "Message should still be visible to receiver.");

        // Test "Delete for everyone" on fileMsg
        boolean deletedEveryone = messageDAO.deleteForEveryone(fileMsgId, sender.getId());
        assertTrue(deletedEveryone, "Sender should be able to delete message for everyone.");

        Message updatedFileMsg = messageDAO.getMessageById(fileMsgId);
        assertTrue(updatedFileMsg.isDeletedForAll(), "Message should have deletedForAll flag set.");
        assertEquals("This message was deleted", updatedFileMsg.getMessage());
        assertNull(updatedFileMsg.getFilePath(), "File path should be cleared from deleted message.");
    }

    @org.junit.jupiter.api.AfterAll
    public static void cleanUpTestData() {
        if (!dbAvailable) return;
        try (Connection conn = DBConnection.getConnection();
             java.sql.Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("DELETE FROM users WHERE username LIKE 'testuser_%' OR username LIKE 'blocker_%' OR username LIKE 'blocked_%' OR username LIKE 'sender_%' OR username LIKE 'receiver_%' OR username LIKE 'creator_%' OR username LIKE 'member_%'");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
