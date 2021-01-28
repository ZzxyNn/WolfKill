<%@ page language="java" pageEncoding="UTF-8" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <base href="<%=basePath%>">

    <title>游戏开始</title>

    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="expires" content="0">
    <meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
    <meta http-equiv="description" content="This is my page">
    <script type="text/javascript" src="statics/js/game.js"></script>
</head>

<body>
<div id="up">
    <div id="floatl">
        <img src="statics/images/1.png" class="himg">
        <img src="statics/images/2.png" class="himg">
    </div>
    <div id="floatr">
        <img src="statics/images/3.png" class="himg">
        <img src="statics/images/4.png" class="himg">
    </div>
    <div id="container">
        <div class="video">
            <video id="bigOne" width="600" height="500" autoplay></video>
        </div>
        <textarea class="text1"></textarea>
    </div>
</div>
<div id="down">
    <textarea class="text2"></textarea>
    <img src="statics/images/女巫.png" class="sfimg">
    <div>
        <video class="video2" id="smallOne" width="320" height="240" autoplay></video>
    </div>
    <input type="submit" value="上警" class="btn">
</div>
</body>

<!-- --------------css↓----------------- -->
<style type="text/css">
    body {
        margin: 0px;
        padding: 0px;
        background-size: cover;
        background-image: url("statics/images/bg001.jpg");
    }

    #up {
        position: relative;
        width: 100%;
        height: 70%;
    }

    #floatl {
        position: absolute;
        top: 30px;
        z-index: 2;
        left: 0px;
        height: 500px;
        width: 120px;
    }

    #floatr {
        position: absolute;
        top: 30px;
        z-index: 2;
        right: 0px;
        height: 500px;
        width: 110px;
    }

    .himg {
        cursor: pointer;
        height: 100px;
        width: 100px;
        margin: 5px;
        overflow: hidden;
    }

    #container {
        position: relative;
        width: 800px;
        height: 500px;
        margin: 30px auto 0;
    }

    .video {
        position: absolute;
        width: 600px;
        height: 500px;
        margin-right: 5px;
        background-color: #0f0f0f;
    }

    .text1 {
        position: absolute;
        padding: 0px;
        border: 0px;
        left: 605px;
        width: 180px;
        height: 500px;
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        font-size: 18px;
        color: white;
        background-color: rgba(101, 101, 101, 0.5);
    }

    #down {
        position: absolute;
        top: 70%;
        width: 100%;
        height: 30%;
        background-color: grey;
    }

    .text2 {
        border: 0px;
        margin: 0px;
        position: absolute;
        height: 98%;
        width: 300px;
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        font-size: 18px;
        color: white;
        background-color: #0f0f0f;
    }

    .sfimg {
        position: absolute;
        left: 305px;
        height: 100%;
        width: 160px;
        background-color: gold;
    }

    .video2 {
        position: absolute;
        right: 5px;
        height: 100%;
        width: 400px;
        background-color: whitesmoke;
    }

    .btn {
        position: absolute;
        margin-top: 10%;
        right: 410px;
        height: 60px;
        width: 100px;
        font-size: 24px;
        color: white;;
        background-color: goldenrod;
    }
</style>

</html>
