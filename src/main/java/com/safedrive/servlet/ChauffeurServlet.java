package com.safedrive.servlet;

import com.safedrive.dao.AccidentDAO;
import com.safedrive.model.User;
import com.safedrive.model.Vehicle;
import com.safedrive.service.UserService;
import com.safedrive.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/app/chauffeurs")
public class ChauffeurServlet extends HttpServlet {

    private final VehicleService vehicleService = new VehicleService();
    private final UserService    userService    = new UserService();
    private final AccidentDAO    accidentDAO    = new AccidentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = (String) req.getAttribute("currentRole");
        if (!"ADMIN".equals(role) && !"MANAGER".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<User> chauffeurs = userService.getAllChauffeurs();

        Map<Long, Long> accidentCounts = new HashMap<>();
        for (User u : chauffeurs) {
            accidentCounts.put(u.getId(), accidentDAO.countByDriverId(u.getId()));
        }

        long assignedCount = chauffeurs.stream()
                .filter(u -> u.getAssignedVehicle() != null)
                .count();

        req.setAttribute("chauffeurs",     chauffeurs);
        req.setAttribute("accidentCounts", accidentCounts);
        req.setAttribute("vehiclesDispo",  vehicleService.getVehiclesWithoutChauffeur());
        req.setAttribute("assignedCount",  assignedCount);
        req.setAttribute("success",        req.getParameter("success"));
        req.getRequestDispatcher("/WEB-INF/views/chauffeurs.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = (String) req.getAttribute("currentRole");
        if (!"ADMIN".equals(role) && !"MANAGER".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        String successMsg = "";

        if ("assign".equals(action)) {
            Long vehicleId   = Long.parseLong(req.getParameter("vehicleId"));
            Long chauffeurId = Long.parseLong(req.getParameter("chauffeurId"));

            String reg  = vehicleService.findById(vehicleId)
                    .map(Vehicle::getRegistrationNumber).orElse("?");
            String nom  = userService.findById(chauffeurId)
                    .map(u -> u.getFullName().trim()).orElse("?");

            vehicleService.assignChauffeur(vehicleId, chauffeurId);
            successMsg = "Véhicule " + reg + " attribué à " + nom + " avec succès";

        } else if ("unassign".equals(action)) {
            Long vehicleId = Long.parseLong(req.getParameter("vehicleId"));
            vehicleService.unassignChauffeur(vehicleId);
            successMsg = "Chauffeur désassigné avec succès";
        }

        resp.sendRedirect(req.getContextPath() + "/app/chauffeurs?success="
                + URLEncoder.encode(successMsg, StandardCharsets.UTF_8));
    }
}
