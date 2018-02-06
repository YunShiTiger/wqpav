package com.wqp.av.common.utils;

public class EmptyUtil {
    /**
     * 判断是否为空
     * @param t 待判断数据
     * @param <T> String ,object
     * @return true表示为空,否则为false
     */
    public static <T> boolean  isEmpty(T t){
        boolean flag = true;
        if(t instanceof String){
            if(t != null && !"".equals(t) && ((String)t).length() > 0) flag = false;
        }else if(t instanceof Object){
            if(t != null) flag = false;
        }else if(t != null){
            flag = false;
        }
        return flag;
    }
}
