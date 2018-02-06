package com.wqp.av.websocket.core.av;

import com.wqp.av.common.utils.EmptyUtil;
import com.wqp.av.websocket.core.Constant;
import org.springframework.web.socket.BinaryMessage;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.AbstractWebSocketHandler;

import java.nio.ByteBuffer;
import java.util.Iterator;
import java.util.Map;

public class AVHandler extends AbstractWebSocketHandler {
    /**
     * 接收二进制消息
     * @param session
     * @param message
     * @throws Exception
     */
    @Override
    protected void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws Exception {
        ByteBuffer byteBuffer = message.getPayload();
        byte [] bytes = byteBuffer.array();

        System.out.println("Binary Received:"+bytes+",bytes length:"+bytes.length);

        //做后续视频转发处理

    }

    /**
     * 连接成功之后回调
     * @param session
     * @throws Exception
     */
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        session.setBinaryMessageSizeLimit(1024*100);
        session.setTextMessageSizeLimit(1024*100);
        System.out.println("WebSocket成功建立连接");

        Map<String, Object> map = session.getAttributes();
        Iterator<String > iterator = map.keySet().iterator();
        while (iterator.hasNext()){
            String key = iterator.next();
            Object value = map.get(key);
            if(!Constant.websocketUsers.containsKey(value)){
                Constant.websocketUsers.put(value,session);
                session.sendMessage(new TextMessage("成功建立socket连接"));
            }

        }
    }

    /**
     * 连接关闭之后回调
     * @param session
     * @param status
     * @throws Exception
     */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        System.out.println("WebSocket成功关闭连接："+status);
        Constant.websocketUsers.remove(session.getId());
    }

    /**
     * 连接运行产生错误回调
     * @param session
     * @param exception
     * @throws Exception
     */
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        System.out.println("WebSocket连接错误");
        Constant.websocketUsers.remove(session.getId());
    }
}
