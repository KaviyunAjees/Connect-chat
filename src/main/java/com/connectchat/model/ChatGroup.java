package com.connectchat.model;

public class ChatGroup {

    private int id;
    private String groupName;
    private int createdBy;
    private String creatorName;
    private String groupPicture;
    private boolean admin;

    public ChatGroup() {
    }

    public ChatGroup(
            int id,
            String groupName,
            int createdBy) {

        this.id = id;
        this.groupName = groupName;
        this.createdBy = createdBy;
        this.groupPicture = "group-default.png";
    }

    public ChatGroup(
            int id,
            String groupName,
            int createdBy,
            String creatorName,
            String groupPicture,
            boolean admin) {

        this.id = id;
        this.groupName = groupName;
        this.createdBy = createdBy;
        this.creatorName = creatorName;
        this.groupPicture = groupPicture;
        this.admin = admin;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public String getGroupPicture() {
        return groupPicture;
    }

    public void setGroupPicture(String groupPicture) {
        this.groupPicture = groupPicture;
    }

    public boolean isAdmin() {
        return admin;
    }

    public void setAdmin(boolean admin) {
        this.admin = admin;
    }
}