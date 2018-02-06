package com.wqp.av.websocket.core.av;

import com.wqp.av.common.utils.EmptyUtil;
import com.wqp.av.websocket.core.Constant;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.lang.Nullable;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import javax.servlet.http.HttpSession;
import java.util.Map;

/**
 * AV拦截器
 */
public class AVInterceptor implements HandshakeInterceptor{

    /**
     * WebSocket握手前回调监听
     * @param request
     * @param response
     * @param wsHandler
     * @param attributes
     * @return
     * @throws Exception
     */
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        if(request instanceof ServletServerHttpRequest){
            ServletServerHttpRequest servletServerHttpRequest = (ServletServerHttpRequest) request;
            HttpSession session = servletServerHttpRequest.getServletRequest().getSession();
            String ws_server_id = servletServerHttpRequest.getServletRequest().getParameter(Constant.WS_SERVER_ID);
            if(!EmptyUtil.isEmpty(session)) {
                attributes.put(session.getId(),session.getId());
            }
        }
        return true;
    }

    /**
     * WebSocket握手后回调监听
     * @param request
     * @param response
     * @param wsHandler
     * @param exception
     */
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, @Nullable Exception exception) {

    }
}
