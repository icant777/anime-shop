package com.anime.backend.common;

import lombok.Data;

import java.io.Serializable;

/**
 * 统一返回结果：所有接口都返回这个结构
 * { "code": 200, "msg": "ok", "data": ... }
 * code=200 成功；400 参数/业务错误；401 未登录；500 系统错误
 */
@Data
public class Result<T> implements Serializable {

    private int code;
    private String msg;
    private T data;

    public Result() {}

    public Result(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    public static <T> Result<T> ok(T data) {
        return new Result<>(200, "ok", data);
    }

    public static <T> Result<T> ok() {
        return new Result<>(200, "ok", null);
    }

    public static <T> Result<T> fail(int code, String msg) {
        return new Result<>(code, msg, null);
    }

    public static <T> Result<T> fail(String msg) {
        return new Result<>(400, msg, null);
    }

    /** 未登录 */
    public static <T> Result<T> unauthorized() {
        return new Result<>(401, "未登录或登录已过期", null);
    }
}
