package com.invoicing.common;

import lombok.Getter;

@Getter
public class ServiceException extends RuntimeException {
    private final Integer code;

    public ServiceException(Integer code, String message) {
        super(message);
        this.code = code;
    }

    public ServiceException(String message) {
        super(message);
        this.code = 500;
    }

    public static ServiceException badRequest(String message) {
        return new ServiceException(400, message);
    }

    public static ServiceException unauthorized(String message) {
        return new ServiceException(401, message);
    }

    public static ServiceException forbidden(String message) {
        return new ServiceException(403, message);
    }
}
