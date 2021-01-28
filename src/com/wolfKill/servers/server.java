package com.wolfKill.servers;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.wolfKill.gameThread.GameThread;
import com.wolfKill.rooms.Room;
import com.wolfKill.utils.AroundInfo;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@ServerEndpoint(value = "/websockets")
public class server {
    //是否为发起者
    private static int Initiator = -1;

    //周边信息
    private AroundInfo aroundInfo = null;

    //总人数
    private static int clientSum = 0;

    //观看人数
    private static int viewerNum = 0;

    //开始人数
    private static int startNum = 4;

    //JSON操作对象
    private static JSONObject jobj = null;

    //所有session集合
    private static List<Session> list = new ArrayList<Session>();

    //房间对象
    private static Room room = new Room("测试房", "测试");

    @OnOpen
    public void open(Session session) {
        System.out.println(session.getId() + "已连接websocket");
        list.add(session);
        clientSum = list.size();
        viewerNum = clientSum - 1;

    }

    @OnClose
    public void close(Session session) {
        list.remove(session);
    }

    @OnMessage
    public void OnMessage(String message, Session session) {
        //先提取三个重要消息
        String type = handleJSONData(message, "type");
        String targetId = handleJSONData(message, "targetId");
        String username = handleJSONData(message, "username");

        System.out.println(username + " 发送消息给：" + room.getId_sessionMap().get(targetId) + "，消息类型为：" + type);

        //如果消息为以下三个类型即转发
        if (type != null || !type.equals("")) {
            boolean messageType = (type.equals("video-offer") || type.equals("video-answer") || type.equals("icecandidate"));
            if (messageType && list.size() > 1) {

                //测试用判断输出语句---start---
                if (type.equals("icecandidate")) {
                    String icecandidate = handleJSONData(message, "data");
                    System.out.println("icecandidate" + icecandidate);
                }
                //---测试end---

                sendToSomeone(targetId, message, session);
            }
            //初始化每个人进入房间
            else if (type.equals("initInfo")) {
                room.joinRoom(session.getId(), username);
                //当房间人数为多少时开始
                if (room.currentClientNum == startNum) {
                    sendEveryOneAroundInfo();

                    GameThread gt = new GameThread(list);
                    Thread t = new Thread(gt);
                    t.start();
                }
            }
        }
    }

    /**
     * 处理JSON字符串信息
     *
     * @param message
     * @param key
     * @return
     */
    private String handleJSONData(String message, String key) {
        jobj = JSONObject.parseObject(message);
        String value = jobj.getString(key);
        return value;
    }


    /**
     * 发送周边信息
     */
    private void sendEveryOneAroundInfo() {
        //给自己发送房间里其他所有人sessionId
        for (Session session : list) {
            aroundInfo = new AroundInfo();
            aroundInfo.setSelfId(session.getId());
            for (int i = 0; i < clientSum; i++) {
                if (!session.getId().equals(list.get(i).getId())) {
                    aroundInfo.setTargetId(list.get(i).getId());
                }
            }
            aroundInfo.setClientSum(String.valueOf(clientSum));
            aroundInfo.setViewerNum(String.valueOf(viewerNum));

            String message = JSON.toJSONString(aroundInfo);
            sendToSelf(message, session);
        }
    }


    /**
     * 发送信息给其他所有人
     *
     * @param message
     * @param session
     */
    private void sendEveryoneElse(String message, Session session) {
        if (list.size() > 1) {
            for (int i = 0; i < list.size(); i++) {
                if (!list.get(i).getId().equals(session.getId())) {
                    try {
                        list.get(i).getBasicRemote().sendText(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    /**
     * 发送信息给发起者
     *
     * @param message
     * @param session
     */
    private void sendToInitiator(String message, Session session) {
        if (Initiator == 0) {
            System.out.println("没有发起者");
            return;
        }
        try {
            list.get(Initiator).getBasicRemote().sendText(message);
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

    /**
     * 发送给sessionId为targetId的用户
     *
     * @param targetId
     * @param message
     * @param session
     */
    private void sendToSomeone(String targetId, String message, Session session) {
        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).getId().equals(targetId)) {
                try {
                    list.get(i).getBasicRemote().sendText(message);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void main(String[] args) {

    }
}
