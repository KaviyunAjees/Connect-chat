package com.connectchat.model;

public class Group {

    private int id;
    private String groupName;
    private int createdBy;

    public Group() {
    }

    public Group(int id, String groupName, int createdBy) {
        this.id = id;
        this.groupName = groupName;
        this.createdBy = createdBy;
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
}