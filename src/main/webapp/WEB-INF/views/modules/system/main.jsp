<%--
  Created by IntelliJ IDEA.
  User: WANGQINGPING
  Date: 2018-01-31
  Time: 9:55
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<html>
<head>
    <title>首页</title>
</head>
<body>
    <button onclick="jump(1);">进入聊天页面</button><br>
    <button onclick="jump(2);">进入测试页面</button><br>
    <button onclick="jump(3);">进入聊天页面2</button><br>

<script>
    function jump(flag) {
        if(flag == 1){
            document.location.href = '${ctx}/system/jump?way=1';
        }
        if(flag == 2){
            document.location.href = '${ctx}/system/jump?way=2';
        }
        if(flag == 3){
            document.location.href = '${ctx}/system/jump?way=3';
        }
    }

</script>
</body>
</html>
