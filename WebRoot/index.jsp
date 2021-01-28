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
    <title>My JSP 'index.jsp' starting page</title>
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="expires" content="0">
    <meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
    <meta http-equiv="description" content="This is my page">
    <!--
        <link rel="stylesheet" type="text/css" href="styles.css">
        -->
    <script type="text/javascript">
        //当前用户名
        var username;

        //是否创建PeerConnection
        var isPeerEstablished = false;

        //是否为发起者
        var isInitiator = false;

        //本地视频流
        var locatstream = null;

        //初始化candidate
        var candidate = null;

        //初始化offer
        var Myoffer = null;

        //打开webSocket连接
        var Websocket;

        //设置视频流约束
        var tstream;

        //stun Server
        var servers;

        //定义传输通道
        var pc;

        //建立流通道的兼容方法
        var PeerConnection;

        //定义浏览器描述类型兼容
        var RTCSessionDescription;

        //设置用户名
        function setUsername() {
            username = document.getElementById("username").value;
            console.log(username + "：设置username成功");
        }

        //将本地流绑定到本地video上
        function getUserStream(stream) {
            document.getElementById("my").src = window.URL.createObjectURL(stream);
            locatstream = stream;
            console.log("当前流状态：" + locatstream.active);
        }
        ;

        //发送candidate信息
        function sendCandidate() {
            var msg = JSON.stringify({
                'name': username,
                'type': "icecandidate",
                'state': "con",
                'isInitiator': isInitiator,
                'data': {
                    'candidate': candidate
                }
            });

            Websocket.send(msg);

            console.log(username + " ：发送Candidate到websocket：");
        }

        //处理传输通道上有视频流加入的事件
        function handleOnAddStream(event) {
            console.log(event.stream);
            document.getElementById("him").src = window.URL.createObjectURL(event.stream);
            console.log("获取远程媒体成功");
        }

        //处理流加入传输通道事件  发送Offer
        function handleNegotiationNeededEvent() {
            pc.createOffer().then(function (offer) {
                return pc.setLocalDescription(offer);
            })
                .then(function () {
                    var msg = JSON.stringify({
                        'name': username,
                        'target': "everyone",
                        'type': "video-offer",
                        'sdp': pc.localDescription
                    });

                    Websocket.send(msg);
                })
        }

        //处理OnIcecandidate事件
        function handleIcecandidate(event) {
            console.log(username + "：获取到Stun Server 的 candidate");

            if (event.candidate == null) {
                return;
            }

            candidate = event.candidate;

            sendCandidate();
        }
        ;

        //处理服务器发来的消息
        function handleOnMessage(Message) {
            console.log("由webSocket发来的信息：" + Message.data);

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
                    console.log(username + "：获得 " + obj.name + " 发来的offer");
                    var rtcs = new RTCSessionDescription(obj.sdp);
                    var targetName = obj.name;

                    //准备answer回复
                    pc.setRemoteDescription(rtcs).then(function () {
                        console.log(username + " 的远端PC通道RemoteDescription " + pc.remoteDescription);
                        return pc.createAnswer();
                    }).then(function (answer) {
                        return pc.setLocalDescription(answer);
                    }).then(function () {
                        console.log(username + " 的本地PC通道LocalDescription " + pc.remoteDescription);
                        var msg = JSON.stringify({
                            'name': username,
                            'target': targetName,
                            'type': "video-answer",
                            'sdp': pc.localDescription
                        });

                        Websocket.send(msg);
                        console.log(username + "：回复answer");
                    })

                    break;

                case "video-answer":
                    var rtcs = new RTCSessionDescription(obj.sdp);
                    console.log(username + "：获得answer");
                    pc.setRemoteDescription(rtcs);
                    break;

                case "icecandidate":
                    console.log(username + "：获得 " + obj.name + " 发来的icecandidate");
                    console.log(obj.data.candidate);
                    pc.addIceCandidate(new RTCIceCandidate(obj.data.candidate));
                    break;

                default:
                    console.log(Message.data);
            }
        }

        //将本地视频流添加到传输通道
        function Start() {
            isInitiator = true;

            pc.addStream(locatstream);

            console.log("发起者：" + username + "已将流装载");
        }
        ;

        function join() {
            var msg = JSON.stringify({
                'name': username,
                'type': "viewer",
            });
            Websocket.send(msg);
        }


        //打开webSocket连接
        Websocket = new WebSocket("ws://172.18.10.77:8080/webtests/websocket");

        //设置视频流约束
        tstream = {
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

        //定义传输通道
        pc = new RTCPeerConnection(servers);

        //浏览器兼容  获取摄像头
        navigator.getUserMedia = (navigator.getUserMedia ||
            navigator.webkitGetUserMedia ||
            navigator.mozGetUserMedia ||
            navigator.msGetUserMedia);

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
        navigator.getUserMedia(tstream, getUserStream,
            function error(error) {
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


        //创建了媒体流，并将媒体流添加到传输通道中触发事件
        pc.onnegotiationneeded = handleNegotiationNeededEvent;

        //收到iceCandidate事件
        pc.onicecandidate = handleIcecandidate;

        //onaddStream事件
        pc.onaddstream = handleOnAddStream;
    </script>
</head>

<body>
<div>
    <video id="my" width="640" height="480" autoplay></video>
    <video id="him" width="640" height="480" autoplay></video>
</div>
<div algin="center">
    MyUsername:<input id="username" type="text"/><input type="button"
                                                        value="确定" onclick="setUsername()"/> <input type="button"
                                                                                                    value="开始"
                                                                                                    onclick="Start()"/>
    <input type="button" value="加入"
           onclick="join()"/>
</div>
</body>
</html>
