package com.safedrive.servlet;

import com.safedrive.model.Role;
import com.safedrive.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/users")
public class UserServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!"ADMIN".equals(req.getAttribute("currentRole"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");

        if ("edit".equals(action)) {
            Long id = Long.parseLong(req.getParameter("id"));
            userService.findById(id).ifPresent(u -> req.setAttribute("editUser", u));

        } else if ("delete".equals(action)) {
            userService.deleteUser(Long.parseLong(req.getParameter("id")));
            resp.sendRedirect(req.getContextPath() + "/app/users");
            return;

        } else if ("toggle".equals(action)) {
            userService.toggleActive(Long.parseLong(req.getParameter("id")));
            resp.sendRedirect(req.getContextPath() + "/app/users");
            return;
        }

        req.setAttribute("users", userService.getAllUsers());
        req.getRequestDispatcher("/WEB-INF/views/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!"ADMIN".equals(req.getAttribute("currentRole"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");

        if ("create".equals(action)) {
            userService.createUser(
                    req.getParameter("username"),
                    req.getParameter("email"),
                    req.getParameter("password"),
                    req.getParameter("firstName"),
                    req.getParameter("lastName"),
                    Role.valueOf(req.getParameter("role")),
                    req.getParameter("phone")
            );

        } else if ("update".equals(action)) {
            Long id = Long.parseLong(req.getParameter("id"));
            userService.findById(id).ifPresent(u -> {
                u.setFirstName(req.getParameter("firstName"));
                u.setLastName(req.getParameter("lastName"));
                u.setEmail(req.getParameter("email"));
                u.setPhone(req.getParameter("phone"));
                u.setRole(Role.valueOf(req.getParameter("role")));
                userService.updateUser(u);
            });
        }

        resp.sendRedirect(req.getContextPath() + "/app/users");
    }
}
