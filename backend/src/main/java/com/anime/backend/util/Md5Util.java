package com.anime.backend.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/** 密码散列：MD5（教学项目够用；生产应换 BCrypt） */
public final class Md5Util {
    private Md5Util() {}

    public static String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
