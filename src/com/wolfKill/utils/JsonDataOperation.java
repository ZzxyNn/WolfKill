package com.wolfKill.utils;

import com.alibaba.fastjson.JSONObject;

public class JsonDataOperation {
    public static JSONObject jobj = null;

    /**
     * 根据key值提取JSON数据里的value值
     *
     * @param message
     * @param key
     * @return
     */
    public static String handleJSONData(String message, String key) {
        jobj = JSONObject.parseObject(message);
        String value = jobj.getString(key);
        return value;
    }
}
