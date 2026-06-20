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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.time.LocalDate;

@WebServlet("/app/accidents")
@MultipartConfig(maxFileSize = 10_000_000, maxRequestSize = 15_000_000)
public class AccidentServlet extends HttpServlet {

    private final AccidentService     accidentService     = new AccidentService();
    private final UserService         userService         = new UserService();
    private final VehicleService      vehicleService      = new VehicleService();
    private final NotificationService notificationService = new NotificationService();
    private final AIService           aiService           = new AIService();

    /** Directory where accident photos are stored on the server file system. */
    private static final String UPLOAD_DIR;
    static {
        String base = System.getProperty("catalina.home");
        if (base == null || base.isBlank()) base = System.getProperty("java.io.tmpdir");
        UPLOAD_DIR = base + File.separator + "safedrive-uploads" + File.separator + "accidents";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role          = (String) req.getAttribute("currentRole");
        Long   currentUserId = (Long)   req.getAttribute("currentUserId");
        String action        = req.getParameter("action");

        // ── Serve accident photo (ADMIN / MANAGER only) ──────────────────────
        if ("photo".equals(action)) {
            if ("DRIVER".equals(role)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            Long id = Long.parseLong(req.getParameter("id"));
            Accident acc = accidentService.findById(id).orElse(null);
            if (acc == null || acc.getPhotoPath() == null || acc.getPhotoPath().isBlank()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            File photoFile;
            try {
                // Validate path is inside expected upload directory (prevent path traversal)
                photoFile = new File(acc.getPhotoPath()).getCanonicalFile();
                File uploadBase = new File(UPLOAD_DIR).getCanonicalFile();
                if (!photoFile.getPath().startsWith(uploadBase.getPath())) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
            } catch (IOException e) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                return;
            }
            if (!photoFile.exists() || !photoFile.isFile()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            String contentType = getServletContext().getMimeType(photoFile.getName());
            if (contentType == null) contentType = "image/jpeg";
            resp.setContentType(contentType);
            resp.setContentLengthLong(photoFile.length());
            resp.setHeader("Cache-Control", "private, max-age=86400");
            try (InputStream in  = new FileInputStream(photoFile);
                 OutputStream out = resp.getOutputStream()) {
                byte[] buf = new byte[8192];
                int n;
                while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
            }
            return;
        }

        // ── Accident detail ───────────────────────────────────────────────────
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

        // ── Update status ─────────────────────────────────────────────────────
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

        // ── Delete ────────────────────────────────────────────────────────────
        if ("delete".equals(action) && "ADMIN".equals(role)) {
            // Also delete the photo file if it exists
            Accident toDelete = accidentService.findById(Long.parseLong(req.getParameter("id"))).orElse(null);
            if (toDelete != null && toDelete.getPhotoPath() != null) {
                new File(toDelete.getPhotoPath()).delete();
            }
            accidentService.deleteAccident(Long.parseLong(req.getParameter("id")));
            resp.sendRedirect(req.getContextPath() + "/app/accidents");
            return;
        }

        // ── Accident list ─────────────────────────────────────────────────────
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

        String role          = (String) req.getAttribute("currentRole");
        Long   currentUserId = (Long)   req.getAttribute("currentUserId");
        String action        = req.getParameter("action");

        // ── Reclassify severity ───────────────────────────────────────────────
        if ("reclassify".equals(action) && !"DRIVER".equals(role)) {
            Long id = Long.parseLong(req.getParameter("id"));
            accidentService.updateSeverity(id, AccidentSeverity.valueOf(req.getParameter("severity")));
            resp.sendRedirect(req.getContextPath() + "/app/accidents?action=detail&id=" + id);
            return;
        }

        // ── Declare accident ──────────────────────────────────────────────────
        String driverIdParam = req.getParameter("driverId");
        Long driverId = "DRIVER".equals(role) ? currentUserId
                : (driverIdParam != null && !driverIdParam.isBlank()
                        ? Long.parseLong(driverIdParam) : currentUserId);

        String latParam  = req.getParameter("latitude");
        String lngParam  = req.getParameter("longitude");
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
            e.printStackTrace();
            throw new ServletException("Erreur lors de la déclaration de l'accident", e);
        }
        notificationService.createForAccident(saved);

        // ── Handle uploaded photo + AI classification ─────────────────────────
        try {
            Part imagePart = req.getPart("image");
            if (imagePart != null && imagePart.getSize() > 0) {
                byte[] imageBytes = imagePart.getInputStream().readAllBytes();

                // 1. Save photo to disk
                try {
                    File dir = new File(UPLOAD_DIR);
                    if (!dir.exists()) dir.mkdirs();
                    String ext      = getExtension(imagePart.getSubmittedFileName());
                    String fileName = "accident_" + saved.getId() + "_" + System.currentTimeMillis() + ext;
                    File   dest     = new File(dir, fileName);
                    try (FileOutputStream fos = new FileOutputStream(dest)) {
                        fos.write(imageBytes);
                    }
                    accidentService.updatePhotoPath(saved.getId(), dest.getAbsolutePath());
                    System.out.println("[SafeDrive] Photo saved: " + dest.getAbsolutePath());
                } catch (Exception e) {
                    System.err.println("[SafeDrive] Could not save photo: " + e.getMessage());
                }

                // 2. AI classification
                try {
                    AIResult aiResult = aiService.classifyImage(imageBytes);
                    accidentService.updateAIResult(
                            saved.getId(), aiResult.getSeverity(), aiResult.getConfidence());
                } catch (Exception e) {
                    System.err.println("[SafeDrive] AI classification failed: " + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.err.println("[SafeDrive] Error processing image part: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath()
                + "/app/accidents?action=detail&id=" + saved.getId() + "&newDeclaration=true");
    }

    private static String getExtension(String filename) {
        if (filename == null) return ".jpg";
        int dot = filename.lastIndexOf('.');
        return (dot >= 0 && dot < filename.length() - 1) ? filename.substring(dot).toLowerCase() : ".jpg";
    }
}
