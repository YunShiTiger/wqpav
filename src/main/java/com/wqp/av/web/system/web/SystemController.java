package com.wqp.av.web.system.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpServletRequest;

@Controller
@RequestMapping(value = "${ctx}/system")
public class SystemController {

    @RequestMapping(value = "/jump",method = RequestMethod.GET)
    public String jump(HttpServletRequest request){
        String link = "";
        String way = request.getParameter("way");
        if("1".equals(way)){
            link = "/modules/chat/chat";
        }else if ("2".equals(way)){
            link = "/modules/test/test";
        }else if ("3".equals(way)){
            link = "/modules/chat/chat2";
        }
        return link;
    }

}
