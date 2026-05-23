package com.safedrive.servlet;

import com.safedrive.model.Notification;
import com.safedrive.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/app/api/notifications/*")
public class NotificationApiServlet extends HttpServlet {

    private final NotificationService notifService = new NotificationService();
    private static final DateTimeFormatter FMT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /** GET /app/api/notifications  →  { "count": N, "items": [...] } */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if ("DRIVER".equals(req.getAttribute("currentRole"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<Notification> items = notifService.getRecent(20);
        long unread = notifService.getUnreadCount();

        StringBuilder sb = new StringBuilder();
        sb.append("{\"count\":").append(unread).append(",\"items\":[");
        for (int i = 0; i < items.size(); i++) {
            Notification n = items.get(i);
            if (i > 0) sb.append(',');
            sb.append("{\"id\":").append(n.getId())
              .append(",\"message\":\"").append(escJson(n.getMessage())).append("\"")
              .append(",\"read\":").append(n.isRead())
              .append(",\"createdAt\":\"").append(n.getCreatedAt().format(FMT)).append("\"");
            if (n.getAccidentId() != null)
                sb.append(",\"accidentId\":").append(n.getAccidentId());
            sb.append('}');
        }
        sb.append("]}");

        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(sb.toString());
    }

    /**
     * POST /app/api/notifications/read       → mark all as read
     * POST /app/api/notifications/read/{id}  → mark single notification as read
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if ("DRIVER".equals(req.getAttribute("currentRole"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = req.getPathInfo();
        if ("/read".equals(path)) {
            notifService.markAllAsRead();
            resp.setStatus(HttpServletResponse.SC_OK);
        } else if (path != null && path.startsWith("/read/")) {
            try {
                Long id = Long.parseLong(path.substring("/read/".length()));
                notifService.markAsRead(id);
                Long accidentId = notifService.findById(id)
                        .map(Notification::getAccidentId).orElse(null);
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder("{\"success\":true");
                if (accidentId != null) json.append(",\"accidentId\":").append(accidentId);
                json.append("}");
                resp.getWriter().write(json.toString());
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private static String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
