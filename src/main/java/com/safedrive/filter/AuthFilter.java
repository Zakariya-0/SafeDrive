package com.safedrive.filter;

import com.safedrive.config.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebFilter("/app/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String token = extractJwt(req);
        if (token == null || !JwtUtil.isTokenValid(token)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Claims claims = JwtUtil.validateToken(token);
        req.setAttribute("currentUser",   claims.getSubject());
        req.setAttribute("currentRole",   claims.get("role",   String.class));
        req.setAttribute("currentUserId", claims.get("userId", Long.class));

        chain.doFilter(request, response);
    }

    private String extractJwt(HttpServletRequest req) {
        if (req.getCookies() == null) return null;
        for (Cookie c : req.getCookies()) {
            if ("jwt".equals(c.getName())) return c.getValue();
        }
        return null;
    }
}
