package com.wqp.av.websocket.core.av;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.*;

/**
 * WebSocket配置
 */
@Configuration
@EnableWebSocket
public class AVConfig implements WebSocketConfigurer {

    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(new AVHandler(),"/avMessageWebSocketServer").setAllowedOrigins("*").addInterceptors(new AVInterceptor());
        registry.addHandler(new AVHandler(),"/avMessageWebSocketServer").setAllowedOrigins("*").addInterceptors(new AVInterceptor()).withSockJS();
    }
}
