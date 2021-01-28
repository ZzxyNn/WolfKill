package com.wolfKill.utils;

import java.util.ArrayList;
import java.util.List;

public class AroundInfo {
    private String selfId;

    private List<String> targetIdList = new ArrayList<String>();

    private String type = "aroundInfo";

    private String clientSum = "";

    private String viewerNum = "";

    public void setTargetId(String targetId) {
        targetIdList.add(targetId);
    }

    public String getSelfId() {
        return selfId;
    }

    public void setSelfId(String selfId) {
        this.selfId = selfId;
    }

    public List<String> getTargetIdList() {
        return targetIdList;
    }

    public void setTargetIdList(List<String> targetIdList) {
        this.targetIdList = targetIdList;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getClientSum() {
        return clientSum;
    }

    public void setClientSum(String clientSum) {
        this.clientSum = clientSum;
    }

    public String getViewerNum() {
        return viewerNum;
    }

    public void setViewerNum(String viewerNum) {
        this.viewerNum = viewerNum;
    }


}
