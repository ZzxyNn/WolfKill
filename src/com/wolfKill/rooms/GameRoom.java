package com.wolfKill.rooms;

import com.alibaba.fastjson.JSON;
import com.wolfKill.utils.AroundInfo;
import com.wolfKill.utils.JsonDataOperation;

import javax.websocket.Session;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;

public class GameRoom {
    //所有人sessionId和用户名的集合  sessionId => username
    public final HashMap<String, String> id_nameMap = new HashMap<String, String>();

    //所有人username和session的集合 username => session
    public final HashMap<String, Session> name_sessionMap = new HashMap<String, Session>();

    //name_sessionMap的迭代器
    public Iterator<Entry<String, Session>> itorName_sessionMap;//= name_sessionMap.entrySet().iterator();

    //id_sessionMap的迭代器
    public Iterator<Entry<String, String>> itorId_sessionMap;//= id_sessionMap.entrySet().iterator();

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

    //当前视频流发起者的sessionId
    public String initorId = "";

    //房间状态
    public String roomState = CLOSED;

    //最大人数
    public int maxClientNum = 8;

    //最少人数
    public int minClientNum = 0;

    //当前人数
    public int currentClientNum = 0;

    //开始人数
    private static int startNum = 2;


    public GameRoom(String roomName, String roomFuncInfo) {
        this.roomName = roomName;
        this.roomFuncInfo = roomFuncInfo;
        this.openRoom();
        System.out.println("房间名：" + roomName + " 创建并打开。");
    }

    /**
     * 游戏开始
     */
    public void gameStart() {

    }

    /**
     * 处理连接信息
     *
     * @param message
     * @return
     */
    public boolean handleConnectedInfo(String message, String type) {
        String targetId = JsonDataOperation.handleJSONData(message, "targetId");
        String username = JsonDataOperation.handleJSONData(message, "username");
        System.out.println(username + " 发送消息给：" + id_nameMap.get(targetId) + "，消息类型为：" + type);

        if (id_nameMap.size() > 1) {

            //测试用判断输出语句---start---
            if (type.equals("icecandidate")) {
                String icecandidate = JsonDataOperation.handleJSONData(message, "data");
                System.out.println("icecandidate" + icecandidate);
            }
            //---测试end---

            sendToSomeone(targetId, message);
        }

        return false;
    }

    /**
     * 加入房间
     */
    public void joinRoom(String message, Session session) {
        String username = JsonDataOperation.handleJSONData(message, "username");
        if (currentClientNum <= maxClientNum) {
            this.id_nameMap.put(session.getId(), username);
            this.name_sessionMap.put(username, session);

            currentClientNum++;
            if (currentClientNum == startNum) {
                sendEveryOneAroundInfo();
            }
            System.out.println("加入信息：房间名：" + this.roomName + " ，用户名为：" + username + " ，sessionId为：" + session.getId() + " ，已经加入，当前人数为：" + currentClientNum);
        } else
            System.out.println("人数已达上限");
    }

    /**
     * 离开房间
     */
    public void leaveRoom(String sessionId) {
        try {
            this.id_nameMap.remove(sessionId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        currentClientNum--;
        System.out.println("离开信息：房间名：" + this.roomName + " ，用户名为：" + id_nameMap.get(sessionId) + " ，sessionId为：" + sessionId + " ，已经离开，当前人数为：" + currentClientNum);
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


    /**
     * 转发消息给某个人
     *
     * @param targetId
     * @param message
     */
    private void sendToSomeone(String targetId, String message) {
        try {
            String targetUsername = id_nameMap.get(targetId);
            name_sessionMap.get(targetUsername).getBasicRemote().sendText(message);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    /**
     * 发送周边信息给自己
     *
     * @param session
     */
    private void sendEveryOneAroundInfo() {

        //给自己发送房间里其他所有人sessionId
        for (Entry<String, Session> entry : name_sessionMap.entrySet()) {
            AroundInfo aroundInfo = new AroundInfo();
            aroundInfo.setSelfId(entry.getValue().getId());
            //只要和自己的username不同的sessionId都装起来
            for (Entry<String, String> en : id_nameMap.entrySet()) {
                if (entry.getKey() != en.getValue()) {
                    aroundInfo.setTargetId(en.getKey());
                }
            }


            aroundInfo.setClientSum(String.valueOf(currentClientNum));
            aroundInfo.setViewerNum(String.valueOf(currentClientNum - 1));

            String message = JSON.toJSONString(aroundInfo);
            sendToSelf(message, entry.getValue());
        }
    }

    /**
     * 发送信息给其他所有人
     *
     * @param message
     * @param session
     */
    private void sendEveryoneElse(String message, Session session) {
        try {
            if (id_nameMap.size() > 1 && name_sessionMap.size() > 1) {
                for (Entry<String, Session> entry : name_sessionMap.entrySet()) {
                    if (entry.getValue() != session) {
                        entry.getValue().getBasicRemote().sendText(message);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 发送信息给发起者
     *
     * @param message
     * @param session
     */
    private void sendToInitiator(String message) {
        if (initorId.equals("")) {
            System.out.println("没有发起者");
            return;
        }
        try {
            name_sessionMap.get(initorId).getBasicRemote().sendText(message);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    /**
     * 发送信息给自己
     *
     * @param message
     * @param session
     */
    private void sendToSelf(String message, Session session) {
        try {
            session.getBasicRemote().sendText(message);
        } catch (IOException e) {
            e.printStackTrace();
        }
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
        return id_nameMap;
    }


}
