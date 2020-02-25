package com.example.gengmei_app_face.bean;

/**
 * @author lsy
 * @date 2020-02-21
 */
public class WXBean {
    int errorCode;
    String code;
    String state;

    public WXBean(int errorCode, String code, String state) {
        this.errorCode = errorCode;
        this.code = code;
        this.state = state;
    }

    public int getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(int errorCode) {
        this.errorCode = errorCode;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }
}
