package com.wqp.av.websocket.core;

import org.springframework.web.socket.WebSocketSession;

import java.util.HashMap;
import java.util.Map;

/**
 * 常量类
 */
public class Constant {
    /**WebSocket访问用户*/
    public static final Map<Object,WebSocketSession> websocketUsers = new HashMap<Object, WebSocketSession>();

    public static final String WS_SERVER_ID = "wsserverid";



}
