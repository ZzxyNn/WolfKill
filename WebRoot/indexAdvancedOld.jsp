<%@ page language="java" pageEncoding="UTF-8" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
            + path + "/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <base href="<%=basePath%>">
    <title>WolfKill</title>
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="expires" content="0">
    <meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
    <meta http-equiv="description" content="This is my page">

    <script type="text/javascript">
        //定义用户名
        var username;

        //是否加入房间
        var isJoined = false;

        //当前用户SessionId
        var selfId;

        //目标用户SessionId
        var targetId;

        //目标id数组
        var targetIdList;

        //当前传输通道Id
        var selfPcId;

        //对方传输通道Id
        var targetPcId;

        //总人数
        var clientSum;

        //观看人数
        var viewerNum;

        //是否创建PeerConnection
        var isPeerEstablished = false;

        //是否为发起者
        var isInitiator = false;

        //本地视频流
        var localstream = null;

        //初始化candidate
        var candidate = null;

        //初始化offer
        var Myoffer = null;

        //打开webSocket连接
        var Websocket;

        //设置视频流约束
        var constraints;

        //stun Server
        var servers;

        //建立流通道的兼容方法
        var PeerConnection;

        //定义浏览器描述类型兼容
        var RTCSessionDescription;

        //定义传输通道数组
        var pcArray;


        /**
         *初始化PC数组事件绑定
         */
        function initPcArray(pc, index, tId) {
            //onaddStream事件
            pc.onaddstream = handleOnAddStream;

            //收到iceCandidate事件
            pc.onicecandidate = function (event) {
                //用pc通道的idp值判断该pc是否已经对它的目标发送过icecandidate
                if (typeof(pc.peerIdentity.idp) == "undefined")
                    handleIcecandidate(pc, event, index, tId);
            }

            //创建了媒体流，并将媒体流添加到传输通道中触发事件
            pc.onnegotiationneeded = function () {
                console.log("方法外面的pc的状态：" + pc.iceConnectionState);
                handleNegotiationNeededEvent(pc, index, tId);
            }
        }

        /**
         *将本地流绑定到本地video上
         */
        function getUserStream(stream) {
            document.getElementById("smallOne").src = window.URL.createObjectURL(stream);
            localstream = stream;
            console.log("当前视频流状态：" + localstream.active);
        };


        /**
         *处理传输通道上有视频流加入的事件
         */
        function handleOnAddStream(event) {
            console.log(event.stream);
            document.getElementById("bigOne").src = window.URL.createObjectURL(event.stream);
            console.log("获取远程媒体成功");
        }

        /**
         *处理流加入传输通道事件  发送Offer
         */
        function handleNegotiationNeededEvent(pc, index, tId) {
            console.log("方法里面的pc的状态：" + pc.iceConnectionState);
            pc.createOffer().then(function (offer) {
                return pc.setLocalDescription(offer);
            })
                .then(function () {
                    var msg = JSON.stringify({
                        'username': username,
                        'selfId': selfId,
                        'targetId': tId,
                        'selfPcId': index,
                        'targetPcId': targetPcId,
                        'type': "video-offer",
                        'sdp': pc.localDescription
                    });

                    console.log("发送offer信息，自己的SessionId为：" + selfId +
                        "，目的地的SessionId为：" + tId +
                        "，自己的PCId为：" + index +
                        "，目的地的PCId为：" + targetPcId);

                    Websocket.send(msg);
                })
        }

        /**
         *处理OnIcecandidate事件
         */
        function handleIcecandidate(pc, event, index, tId) {
            console.log(username + "：获取到Stun Server 的 candidate");
            if (event.candidate == null) {
                console.log("candidate为null");
                return;
            }

            var msg = JSON.stringify({
                'username': username,
                'type': "icecandidate",
                'state': "con",
                'selfId': selfId,
                'targetId': tId,
                'selfPcId': index,
                'targetPcId': targetPcId,
                'data': {
                    'candidate': event.candidate
                }
            });
            console.log("准备发送candidate信息，自己的SessionId为：" + selfId +
                "，目的地的SessionId为：" + tId +
                "，自己的PCId为：" + index +
                "，目的地的PCId为：" + targetPcId);

            Websocket.send(msg);
            //自己定义给该pc通道的idp赋值，即说明该pc通道已对它的目标发送过icecandidate
            pc.peerIdentity.idp = index;

            console.log(username + " ：发送Candidate到websocket：");
        };

        /**
         *处理服务器发来的消息
         */
        function handleOnMessage(Message) {
            try {
                var obj = JSON.parse(Message.data);
            } catch (e) {
                console.log("非JSON数据");
                console.log(e.message);
            }

            var type = obj.type;

            //处理接收消息
            switch (type) {
                case "video-offer":
                    console.log(username + "：获得 " + obj.username +
                        " 发来的offer，发送者的sessionId是：" + obj.selfId +
                        "，目的地的SessionId是：" + obj.targetId +
                        "，我自己的PCId是：" + obj.targetPcId +
                        "，对方的PCId是：" + obj.selfPcId);

                    var index = pcArray.length;
                    var rtcs = new RTCSessionDescription(obj.sdp);

                    targetId = obj.selfId;
                    selfPcId = index;
                    targetPcId = obj.selfPcId;

                    console.log("获得offer之后索引数据index，也是这个PC数组的大小：" + index);

                    pcArray[index] = new RTCPeerConnection(servers);
                    initPcArray(pcArray[index], index, targetId);

                    //准备answer回复
                    pcArray[index].setRemoteDescription(rtcs).then(function () {
                        return pcArray[index].createAnswer();
                    }).then(function (answer) {
                        return pcArray[index].setLocalDescription(answer);
                    }).then(function () {
                        var msg = JSON.stringify({
                            'username': username,
                            'selfId': selfId,
                            'selfPcId': index,
                            'targetId': targetId,
                            'targetPcId': targetPcId,
                            'type': "video-answer",
                            'sdp': pcArray[index].localDescription
                        });

                        Websocket.send(msg);
                        console.log(username + "：回复answer");
                    })

                    break;

                case "video-answer":
                    console.log(username + "：获得 " + obj.username +
                        "发来的answer，发送者的sessionId是：" + obj.selfId +
                        "，目的地的SessionId是：" + obj.targetId +
                        "，对方自己的PCId是：" + obj.selfPcId +
                        "，我的PCId是：" + obj.targetPcId);

                    var rtcs = new RTCSessionDescription(obj.sdp);

                    selfPcId = obj.targetPcId;
                    targetId = obj.selfId;

                    pcArray[selfPcId].setRemoteDescription(rtcs);
                    break;

                case "icecandidate":
                    console.log(username + "：获得 " + obj.username +
                        " 发来的icecandidate，发送者的SessionId为：" + obj.selfId +
                        "，我自己的SessionId为：" + obj.targetId +
                        "，发送者的PCId为：" + obj.selfPcId +
                        "，我自己的PCId为：" + obj.targetPcId);

                    console.log(obj.data.candidate);

                    console.log("收到icecandidate后当前的selfPcId为：" + selfPcId);
                    pcArray[selfPcId].addIceCandidate(new RTCIceCandidate(obj.data.candidate));
                    break;

                case "aroundInfo":
                    console.log("websocket发来的自己的SessionId： " + obj.selfId +
                        "，和周边信息：" + obj.targetIdList +
                        "，总人数： " + obj.clientSum +
                        "，观众数：" + obj.viewerNum);

                    selfId = obj.selfId;
                    targetIdList = obj.targetIdList;
                    clientSum = obj.clientSum;
                    viewerNum = obj.viewerNum;
                    break;

                case "Your Turn":
                    start();
                    console.log("服务器告诉我该我了.....");
                    break;

                /* default:
                    console.log(Message.data); */
            }
        }

        /**
         *设置用户名
         */
        function setUsername() {
            username = document.getElementById("username").value;
            joinBtn = document.getElementById("joinBtn").disabled = false;
            console.log(username + "：设置username成功");
        }

        /**
         *将本地视频流添加到传输通道
         */
        function start() {
            document.getElementById("bigOne").src = window.URL.createObjectURL(localstream);

            pcArray.length = 0;

            //将本地视频流添加到通道
            for (i = 0; i < viewerNum; i++) {
                pcArray[i] = new RTCPeerConnection(servers);

                initPcArray(pcArray[i], i, targetIdList[i]);

                pcArray[i].addStream(localstream);
            }
        };

        /**
         *加入房间
         */
        function join() {
            var msg = JSON.stringify({
                'username': username,
                'type': "initInfo",
            })
            Websocket.send(msg);
            isJoined = true;
            if (isJoined) {
                //加入房间按钮不可点
                joinBtn = document.getElementById("joinBtn").disabled = true;
            }
        }


        /*-------------------初始化↓-------------------*/

        //定义通道数组
        pcArray = new Array();

        //打开webSocket连接
        Websocket = new WebSocket("ws://172.16.71.36:8080/WolfKill/websocket");

        //设置视频流约束
        constraints = {
            //audio:true,
            video: {
                mandatory: {
                    maxWidth: 352,
                    maxHeight: 320,
                    maxFrameRate: 10
                }
            }
        };

        //stun Server
        servers = {
            iceServers: [
                {
                    "urls": "stun:stun.ideasip.com"
                },
            ]
        };

        /* //浏览器兼容  获取摄像头
        navigator.getUserMedia = (navigator.getUserMedia ||
            navigator.webkitGetUserMedia ||
            navigator.mozGetUserMedia ||
            navigator.msGetUserMedia); */

        //建立流通道的兼容方法
        PeerConnection = (window.webkitRTCPeerConnection ||
            window.mozRTCPeerConnection ||
            window.RTCPeerConnection ||
            undefined);

        //定义浏览器描述类型兼容
        RTCSessionDescription = (window.webkitRTCSessionDescription ||
            window.mozRTCSessionDescription ||
            window.RTCSessionDescription ||
            undefined);

        //将本地流绑定到本地video上
        navigator.mediaDevices.getUserMedia(constraints)
            .then(function (stream) {
                getUserStream(stream)
            })
            .catch(function error(error) {
                console.log(error);
            });

        //-----------websocket事件注册--------------
        //websocket连接事件
        Websocket.onopen = function (evt) {
            console.log("websocket已连接");
        };

        //websocket关闭事件
        Websocket.onclose = function (evt) {
            console.log(evt);
        };

        //websocket消息响应事件
        Websocket.onmessage = handleOnMessage;
        //-------------end-----------------------


    </script>
</head>

<body>
<div>
    <video id="smallOne" width="320" height="240" autoplay></video>
    <video id="bigOne" width="640" height="480" autoplay></video>
</div>
<div algin="center">
    MyUsername:<input id="username" type="text"/><input type="button"
                                                        value="确定" onclick="setUsername()"/>
    <input id="joinBtn" type="button" value="加入" onclick="join()"/>
    <input type="button" value="开始" onclick="start()"/>
</div>
</body>
</html>
