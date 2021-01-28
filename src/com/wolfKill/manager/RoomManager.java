package com.wolfKill.manager;

import com.wolfKill.rooms.Room;

import java.util.HashMap;

public class RoomManager {
    public static int roomSum = 0;

    //�?有房间的Map集合
    public static final HashMap<String, Room> roomMap = new HashMap<String, Room>();

    /**
     * 有房间创建并将其加入Map
     *
     * @param room
     */
    public void addRoom(Room room) {
        roomMap.put(room.getRoomId(), room);
        roomSum = roomMap.size();
        System.out.println("RoomManager： 房间号为 " + room.getRoomId() + "创建并加入房间Map");
    }

    /**
     * 有房间关闭并将其移除Map
     *
     * @param room
     */
    public void removeRoom(Room room) {
        roomMap.remove(room).getRoomId();
        roomSum = roomMap.size();
        System.out.println("RoomManager： 房间号为 " + room.getRoomId() + "关闭并被删除房间Map");
    }

    /**
     * 获取房间数量
     *
     * @return
     */
    public int getRoomMapSize() {
        if (roomSum == roomMap.size()) {
            return roomSum;
        } else {
            System.err.println("RoomManager：房间数量可能出现异常，roomSum=" + roomSum + "，Map集合大小=" + roomMap.size());
            roomSum = roomMap.size();
            return roomSum;
        }
    }
}
