package com.safedrive.servlet;

import com.safedrive.model.Accident;
import com.safedrive.model.AccidentSeverity;
import com.safedrive.model.AccidentStatus;
import com.safedrive.model.Role;
import com.safedrive.service.AccidentService;
import com.safedrive.service.AIResult;
import com.safedrive.service.AIService;
import com.safedrive.service.NotificationService;
import com.safedrive.service.UserService;
import com.safedrive.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/app/accidents")
@MultipartConfig(maxFileSize = 10_000_000, maxRequestSize = 15_000_000)
public class AccidentServlet extends HttpServlet {

    private final AccidentService     accidentService     = new AccidentService();
    private final UserService         userService         = new UserService();
    private final VehicleService      vehicleService      = new VehicleService();
    private final NotificationService notificationService = new NotificationService();
    private final AIService           aiService           = new AIService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role          = (String) req.getAttribute("currentRole");
        Long   currentUserId = (Long)   req.getAttribute("currentUserId");
        String action        = req.getParameter("action");

        if ("detail".equals(action)) {
            Long id = Long.parseLong(req.getParameter("id"));
            Accident detail = accidentService.findByIdWithDetails(id).orElse(null);
            if (detail == null) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
            if ("DRIVER".equals(role) && !detail.getDriver().getId().equals(currentUserId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
            }
            req.setAttribute("accident", detail);
            if (detail.getAiConfidence() != null) {
                req.setAttribute("aiConfPct", (int) Math.round(detail.getAiConfidence() * 100));
            }
            if ("true".equals(req.getParameter("newDeclaration"))) {
                req.setAttribute("newDeclaration", true);
            }
            req.getRequestDispatcher("/WEB-INF/views/accident-detail.jsp").forward(req, resp);
            return;
        }

        if ("updateStatus".equals(action) && !"DRIVER".equals(role)) {
            Long statusId = Long.parseLong(req.getParameter("id"));
            accidentService.updateStatus(statusId, AccidentStatus.valueOf(req.getParameter("status")));
            String returnTo = req.getParameter("returnTo");
            if ("detail".equals(returnTo)) {
                resp.sendRedirect(req.getContextPath() + "/app/accidents?action=detail&id=" + statusId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/app/accidents");
            }
            return;
        }

        if ("delete".equals(action) && "ADMIN".equals(role)) {
            accidentService.deleteAccident(Long.parseLong(req.getParameter("id")));
            resp.sendRedirect(req.getContextPath() + "/app/accidents");
            return;
        }

        if ("DRIVER".equals(role)) {
            req.setAttribute("accidents", accidentService.getAccidentsByDriver(currentUserId));
            req.setAttribute("chauffeurVehicle",
                    vehicleService.getVehicleByDriverId(currentUserId).orElse(null));
        } else {
            req.setAttribute("accidents", accidentService.getAllAccidents());
        }

        req.setAttribute("drivers",  userService.getUsersByRole(Role.DRIVER));
        req.setAttribute("vehicles", vehicleService.getAllVehicles());
        req.getRequestDispatcher("/WEB-INF/views/accidents.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println("=== doPost AccidentServlet appelé ===");
        System.out.println("=== Content-Type: " + req.getContentType() + " ===");

        String role          = (String) req.getAttribute("currentRole");
        Long   currentUserId = (Long)   req.getAttribute("currentUserId");

        // Pour multipart, getParameter() fonctionne normalement avec @MultipartConfig
        String action = req.getParameter("action");
        System.out.println("=== action param: " + action + " ===");

        if ("reclassify".equals(action) && !"DRIVER".equals(role)) {
            Long id = Long.parseLong(req.getParameter("id"));
            accidentService.updateSeverity(id, AccidentSeverity.valueOf(req.getParameter("severity")));
            resp.sendRedirect(req.getContextPath() + "/app/accidents?action=detail&id=" + id);
            return;
        }

        String driverIdParam = req.getParameter("driverId");
        Long driverId = "DRIVER".equals(role) ? currentUserId
                : (driverIdParam != null && !driverIdParam.isBlank()
                ? Long.parseLong(driverIdParam) : currentUserId);

        String latParam = req.getParameter("latitude");
        String lngParam = req.getParameter("longitude");
        Double latitude  = (latParam != null && !latParam.isBlank()) ? Double.parseDouble(latParam) : null;
        Double longitude = (lngParam != null && !lngParam.isBlank()) ? Double.parseDouble(lngParam) : null;

        Accident saved;
        try {
            saved = accidentService.declareAccident(
                    driverId,
                    Long.parseLong(req.getParameter("vehicleId")),
                    LocalDate.parse(req.getParameter("date")),
                    req.getParameter("location"),
                    req.getParameter("description"),
                    AccidentSeverity.valueOf(req.getParameter("severity")),
                    latitude,
                    longitude
            );
        } catch (Exception e) {
            System.out.println("=== ERREUR declareAccident: " + e.getClass().getSimpleName() + " - " + e.getMessage() + " ===");
            e.printStackTrace();
            throw new ServletException("Erreur lors de la déclaration de l'accident", e);
        }
        notificationService.createForAccident(saved);

        // Classification IA — image optionnelle
        try {
            Part imagePart = req.getPart("image");
            System.out.println("[DEBUG] imagePart = " + imagePart);
            System.out.println("[DEBUG] size = " + (imagePart != null ? imagePart.getSize() : "NULL"));

            if (imagePart != null && imagePart.getSize() > 0) {
                byte[] imageBytes = imagePart.getInputStream().readAllBytes();
                System.out.println("[DEBUG] imageBytes length = " + imageBytes.length);

                AIResult aiResult = aiService.classifyImage(imageBytes);
                System.out.println("[DEBUG] AI Result: severity=" + aiResult.getSeverity()
                        + " confidence=" + aiResult.getConfidence());

                accidentService.updateAIResult(
                        saved.getId(), aiResult.getSeverity(), aiResult.getConfidence());
                System.out.println("[DEBUG] AI result saved for accident #" + saved.getId());
            } else {
                System.out.println("[DEBUG] imagePart null ou vide — classification IA ignorée");
            }
        } catch (Exception e) {
            System.out.println("[DEBUG] EXCEPTION classification IA : "
                    + e.getClass().getSimpleName() + " - " + e.getMessage());
            e.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath()
                + "/app/accidents?action=detail&id=" + saved.getId() + "&newDeclaration=true");
    }
}
