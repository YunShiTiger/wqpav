<%--
  Created by IntelliJ IDEA.
  User: WANGQINGPING
  Date: 2018-01-31
  Time: 9:54
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="/WEB-INF/views/include/taglib.jsp"%>
<html>
<head>
    <title>音视频聊天</title>
    <%--<script type="text/javascript" src="/static/js/jquery/jquery-1.9.1.js"></script>--%>
    <script type="text/javascript" src="/static/js/sockjs/sockjs-1.1.4.min.js"></script>
</head>
<body onload="loadInit()">
<div id="container">
    <div style="text-align: center;">
        <video id="video" width="480" height="320" controls autoplay></video><br>
        <button id="record" onclick="onRecordClick()" disabled>Record</button>
        <button id="pause" onclick="onPauseClick()" disabled>Pause</button>
        <button id="stop" onclick="onStopClick()" disabled>Stop</button>
    </div>
    <button id="wsBtn" onclick="onWebSocketClick()" >Stop</button>
</div>

<script type="text/javascript">
    var video = document.querySelector('video#video');
    var recordBtn = document.querySelector('button#record');
    var pauseBtn = document.querySelector('button#pause');
    var stopBtn = document.querySelector('button#stop');

    var mediaRecorder = null;//MediaRecorder对象
    var chunks = [];//缓存


    /**开始记录*/
    function onRecordClick(){
        var constraints = {audio:true,video:{width:480,height:320}};
        if(navigator.mediaDevices.getUserMedia){
            //最新的标准API
            navigator.mediaDevices.getUserMedia(constraints).then(userMediaSuccess).catch(userMediaError);
        }else if(navigator.webkitGetUserMedia){
            //webkit核心浏览器
            navigator.webkitGetUserMedia(constraints,userMediaSuccess,userMediaError);
        }else if(navigator.mozGetUserMedia){
            //firfox浏览器
            navigator.mozGetUserMedia(constraints, userMediaSuccess, userMediaError);
        }else if(navigator.getUserMedia){
            //旧版API
            navigator.getUserMedia(constraints, userMediaSuccess, userMediaError);
        }else{
            alert("该浏览器不支持访问用户媒体");
            return;
        }
    }

    /**停止记录*/
    function onStopClick(){
        if(mediaRecorder == null){
            alert("记录未开启");
            return;
        }
        mediaRecorder.stop();
        recordBtn.disabled = false;
        pauseBtn.disabled = true;
        stopBtn.disabled = true;
    }

    /**暂停、继续记录*/
    function onPauseClick(){
        if(mediaRecorder == null){
            alert("记录未开启");
            return;
        }
        if(pauseBtn.textContent == 'Pause'){
            pauseBtn.textContent = 'Resume';
            mediaRecorder.pause();
        }else{
            pauseBtn.textContent = 'Pause';
            mediaRecorder.resume();
        }
    }



    /*音视频调用成功回调*/
    function userMediaSuccess(stream){
        if(typeof MediaRecorder.isTypeSupported == 'function'){
            var options = null;
            if(MediaRecorder.isTypeSupported('video/webm;codecs=vp8')){
                options = {mimeType:'video/webm;codecs=vp8',audioBitsPerSecond:128000,videoBitsPerSecond:2500000};
            }else if(MediaRecorder.isTypeSupported('video/webm;codecs=vp9')){
                options = {mimeType:'video/webm;codecs=h264',audioBitsPerSecond:128000,videoBitsPerSecond:2500000};
            }else if(MediaRecorder.isTypeSupported('video/webm;codecs=h264')){
                options = {mimeType:'video/webm;codecs=h264',audioBitsPerSecond:128000,videoBitsPerSecond:2500000};
            }else{
                options = {mimeType:'video/mp4',audioBitsPerSecond:128000,videoBitsPerSecond:2500000};
            }
            console.log('Using '+options.mimeType);
            mediaRecorder = new MediaRecorder(stream,options);
        }else{
            console.log('isTypeSupported is not supported, using default codecs for browser');
            mediaRecorder = new MediaRecorder(stream);
        }

        recordBtn.disabled = true;//设置记录按钮不可点击
        pauseBtn.disabled = false;//设置暂停按钮可以点击
        stopBtn.disabled = false;//设置停止按钮可以点击

        mediaRecorder.start(5);//10毫秒记录一个Blob

        if ("srcObject" in video) {
            // Older browsers may not have srcObject
            video.srcObject = stream;
        } else {
            // Avoid using this in new browsers, as it is going away.
            video.src = window.URL.createObjectURL(stream);
        }
        video.onloadedmetadata = function(e){
            video.play();
        }

        /*
        1.视频捕获好之后会触发MediaRecorder的dataavailable的event
        2.采集到的视频数据主要基于Blob格式进行转写，利用FileReader进行读取，FileReader一定要注册loadend监听器，或者写onload函数
          在loadend函数里面进行格式转换，方便websocket进行传输（websocket的数据类型支持blob、arrayBuffer）
        3.此应用使用arrayBuffer，所以将视频数据的Blob转写为Unit8Buffer,便于websocket的后台服务用ByteBuffer接收
         */
        mediaRecorder.onstart = function(){
            console.log('MediaRecorder service has started = '+mediaRecorder.state);
        }
        mediaRecorder.onresume = function(){
            console.log('MediaRecorder service has resumed = '+mediaRecorder.state);
        }
        mediaRecorder.onpause = function() {
            console.log('MediaRecorder service has paused = '+mediaRecorder.state);
        }
        mediaRecorder.onstop = function(){
            console.log('MediaRecorder service has stoped = '+mediaRecorder.state);
            var blob = new Blob(chunks,{type:'video/webm'});
            chunks = [];//清空数组
            var videoURL = window.URL.createObjectURL(blob);
            video.src = videoURL;
        }
        mediaRecorder.onerror = function(e){
            console.log('MediaRecorder service has errored = '+mediaRecorder.state+',error:'+e.message);
        }
        mediaRecorder.ondataavailable = function(stream){
            console.log('MediaRecorder service has dataavailabled = '+mediaRecorder.state);
            console.log(stream.data);
            console.log(stream.data.type);
            var state = ws.readyState;

            var fileReader = new FileReader();//创建FileReader对象
            fileReader.addEventListener('loadend',function(){
                var buffer = new Uint8Array(fileReader.result);
                console.log('ws待传数据为='+fileReader.result);
                if(buffer.length > 0){
                    //调用ws发送数据
                    ws.send(buffer);
                }
            });
            fileReader.readAsArrayBuffer(stream.data);
            chunks.push(stream.data);
        }
    }

    /*音视频调用错误回调*/
    function userMediaError(error){
        console.log(error.name + ": " + error.message);
    }

    /*在FileReader加载完成则通过WS发送数据到后台服务(注:数据是在mediaRecorder.ondataavailable回调当中添加)*/
    function wsSendDataToService(fileReader){
        var buffer = new Uint8Array(fileReader.result);
        console.log('ws待传数据为='+fileReader.result);
        if(buffer.length > 0){
            //调用ws发送数据
            ws.send(buffer);
        }
    }

</script>
<script type="text/javascript">
    var wsurl = 'ws://'+window.location.host+'/avMessageWebSocketServer?wsserverid=test';//WebSocket服务地址
//    var wsurl = 'ws://192.168.59.114:8080/avMessageWebSocketServer?wsserverid=test';//WebSocket服务地址
    var ws = null;//WebSocket对象

    /**创建WebSocket对象*/
    function createWS(){
        if('WebSocket' in window){
            ws = new WebSocket(wsurl);
        }else if('MozWebSocket' in window){
            ws = new MozWebSocket(wsurl);
        }else{
            console.log("您的浏览器不支持WebSocket,采用SockJS方式支持");
            ws = new SockJs("http://"+window.location.host+"/wqpav/avMessageWebSocketServer?wsserverid=test");
        }
    }

    function loadInit(){
        if(ws != null){
            console.log("WebSocket已经连接成功");
            return;
        }

        createWS();

        ws.onopen = function(){
            console.log('WebSocket service has opened success');
            ws.binaryType = 'arraybuffer';//设置WebSocket发送数据类型为ArrayBuffer
            recordBtn.disabled = false;
        }
        ws.onmessage = function(d){
            console.log('WebSocket service has messaged =' + d.data);
        }
        ws.onclose = function(d){
            console.log('WebSocket service has closed =' + d.reason);
            ws = null;
            createWS();
        }
        ws.onerror = function(e){
            console.log('WebSocket service has errored =' + e.message);
            ws = null;
            createWS();
        }
    }
</script>
<script type="text/javascript">
    var wsBtn = document.querySelector("button#wsBtn");

    function onWebSocketClick(){
        if(wsBtn.textContent == 'Stop'){
            wsBtn.textContent = 'Start';
            loadInit();
        }else{
            wsBtn.textContent = 'Stop';
            ws.close();
        }
    }


</script>

</body>
</html>
