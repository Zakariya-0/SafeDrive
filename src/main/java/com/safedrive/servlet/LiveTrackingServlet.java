package com.safedrive.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/livetracking")
public class LiveTrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = (String) req.getAttribute("currentRole");
        if (!"ADMIN".equals(role) && !"MANAGER".equals(role) && !"DRIVER".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/livetracking.jsp").forward(req, resp);
    }
}
