package com.safedrive.servlet;

import com.safedrive.model.Notification;
import com.safedrive.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * POST /app/notifications/read?notificationId={id}
 * Marque une notification comme lue et renvoie JSON :
 *   { "success": true, "accidentId": 7 }
 */
@WebServlet("/app/notifications/read")
public class NotificationServlet extends HttpServlet {

    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = (String) req.getAttribute("currentRole");
        if ("DRIVER".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String idParam = req.getParameter("notificationId");
        if (idParam == null || idParam.isBlank()) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"error\":\"notificationId manquant\"}");
            return;
        }

        try {
            Long notifId = Long.parseLong(idParam);
            notifService.markAsRead(notifId);

            Long accidentId = notifService.findById(notifId)
                    .map(Notification::getAccidentId).orElse(null);

            resp.setContentType("application/json;charset=UTF-8");
            StringBuilder json = new StringBuilder("{\"success\":true");
            if (accidentId != null) json.append(",\"accidentId\":").append(accidentId);
            json.append("}");
            resp.getWriter().write(json.toString());

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
