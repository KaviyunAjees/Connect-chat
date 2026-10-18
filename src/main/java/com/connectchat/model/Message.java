package com.connectchat.model;

import com.connectchat.util.FileStorageUtil;

public class Message {

    private int id;
    private int senderId;
    private int receiverId;
    private int groupId;
    private String message;
    private String messageType = "TEXT"; // TEXT, FILE, IMAGE
    private String fileName;
    private String filePath;
    private Long fileSize;
    private String fileType;
    private boolean deletedForAll;
    private String senderName;
    private String createdAt;

    public Message() {
    }

    public Message(int id, int senderId, int receiverId, String message) {
        this.id = id;
        this.senderId = senderId;
        this.receiverId = receiverId;
        this.message = message;
    }

    public Message(int senderId, int receiverId, String message) {
        this.senderId = senderId;
        this.receiverId = receiverId;
        this.message = message;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public int getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(int receiverId) {
        this.receiverId = receiverId;
    }

    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getMessageType() {
        return messageType != null ? messageType : "TEXT";
    }

    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public boolean isDeletedForAll() {
        return deletedForAll;
    }

    public void setDeletedForAll(boolean deletedForAll) {
        this.deletedForAll = deletedForAll;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getFormattedFileSize() {
        if (fileSize == null || fileSize <= 0) {
            return "";
        }
        return FileStorageUtil.formatFileSize(fileSize);
    }
}