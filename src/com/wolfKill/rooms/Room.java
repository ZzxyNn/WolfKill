package com.wolfKill.rooms;

import java.util.HashMap;

public class Room {
    //所有人sessionId和用户名的集合  sessionId => username
    public final HashMap<String, String> id_sessionMap = new HashMap<String, String>();

    //房间开启
    public final String OPENING = "OPENING";

    //房间关闭
    public final String CLOSED = "CLOSED";

    //房间功能描述
    public String roomFuncInfo = "";

    //房间名称
    public String roomName = "";

    //房间Id
    public String roomId = "";

    //房主sessionId
    public String initorId = "";

    //房间状态
    public String roomState = CLOSED;

    //最大人数
    public int maxClientNum = 8;

    //最少人数
    public int minClientNum = 0;

    //当前人数
    public int currentClientNum = 0;


    public Room(String roomName, String roomFuncInfo) {
        this.roomName = roomName;
        this.roomFuncInfo = roomFuncInfo;
        this.openRoom();
        System.out.println("房间名：" + roomName + " 创建并打开。");
    }

    public void gameStart() {

    }

    /**
     * 加入房间
     */
    public void joinRoom(String sessionId, String username) {
        if (currentClientNum <= maxClientNum) {
            this.id_sessionMap.put(sessionId, username);
            currentClientNum++;
            System.out.println("加入信息：房间名：" + this.roomName + " ，用户名为：" + username + " ，sessionId为：" + sessionId + " ，已经加入，当前人数为：" + currentClientNum);
        } else
            System.out.println("人数已达上限");
    }

    /**
     * 离开房间
     */
    public void leaveRoom(String sessionId, String username) {
        try {
            this.id_sessionMap.remove(sessionId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        currentClientNum--;
        System.out.println("离开信息：房间名：" + this.roomName + " ，用户名为：" + username + " ，sessionId为：" + sessionId + " ，已经离开，当前人数为：" + currentClientNum);
    }

    /**
     * 开启房间
     */
    public void openRoom() {
        this.roomState = OPENING;
    }

    /**
     * 关闭房间
     */
    public void closeRoom() {
        this.roomState = CLOSED;
    }


    //---------Getters & Setters-------------

    public String getRoomFuncInfo() {
        return roomFuncInfo;
    }

    public void setRoomFuncInfo(String roomFuncInfo) {
        this.roomFuncInfo = roomFuncInfo;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public int getMaxClientNum() {
        return maxClientNum;
    }

    public void setMaxClientNum(int maxClientNum) {
        this.maxClientNum = maxClientNum;
    }

    public int getMinClientNum() {
        return minClientNum;
    }

    public void setMinClientNum(int minClientNum) {
        this.minClientNum = minClientNum;
    }

    public int getCurrentClientNum() {
        return currentClientNum;
    }

    public void setCurrentClientNum(int currentClientNum) {
        this.currentClientNum = currentClientNum;
    }

    public String getRoomState() {
        return roomState;
    }

    public HashMap<String, String> getId_sessionMap() {
        return id_sessionMap;
    }


}
