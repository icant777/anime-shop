package com.anime.backend.common;

/** 业务异常：Service 层抛，全局异常处理器转成一个友好的 Result */
public class BizException extends RuntimeException {
    private final int code;

    public BizException(String msg) {
        this(400, msg);
    }

    public BizException(int code, String msg) {
        super(msg);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
