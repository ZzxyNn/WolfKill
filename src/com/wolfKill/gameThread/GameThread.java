package com.wolfKill.gameThread;

import com.alibaba.fastjson.JSON;
import com.wolfKill.utils.WhoseTurn;

import javax.websocket.Session;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class GameThread implements Runnable {
    public static ArrayList<String> idList = new ArrayList<String>();

    public static WhoseTurn wt = new WhoseTurn();

    public static String message = "";

    public List<Session> list = null;

    public int index = 2;

    static {
        message = JSON.toJSONString(wt);
    }

    public GameThread(List<Session> list) {
        this.list = list;
    }

    @Override
    public void run() {
        while (true) {
            try {
                if (index == list.size()) {
                    index = 0;
                }
                list.get(index).getBasicRemote().sendText(message);
                index++;
                Thread.sleep(13000);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

}
