package com.safedrive.servlet;

import com.safedrive.model.Role;
import com.safedrive.model.VehicleStatus;
import com.safedrive.service.UserService;
import com.safedrive.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/vehicles")
public class VehicleServlet extends HttpServlet {

    private final VehicleService vehicleService = new VehicleService();
    private final UserService    userService    = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role   = (String) req.getAttribute("currentRole");
        String action = req.getParameter("action");

        if ("delete".equals(action) && "ADMIN".equals(role)) {
            vehicleService.deleteVehicle(Long.parseLong(req.getParameter("id")));
            resp.sendRedirect(req.getContextPath() + "/app/vehicles");
            return;
        }

        if ("edit".equals(action)) {
            Long id = Long.parseLong(req.getParameter("id"));
            vehicleService.findById(id).ifPresent(v -> req.setAttribute("editVehicle", v));
        }

        req.setAttribute("vehicles", vehicleService.getAllVehicles());
        req.setAttribute("drivers",  userService.getUsersByRole(Role.DRIVER));
        req.getRequestDispatcher("/WEB-INF/views/vehicles.jsp").forward(req, resp);
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

        if ("create".equals(action)) {
            String mi = req.getParameter("mileage");
            vehicleService.createVehicle(
                    req.getParameter("registrationNumber"),
                    req.getParameter("brand"),
                    req.getParameter("model"),
                    Integer.parseInt(req.getParameter("year")),
                    (mi != null && !mi.isBlank()) ? Integer.parseInt(mi) : 0
            );

        } else if ("update".equals(action)) {
            Long id = Long.parseLong(req.getParameter("id"));
            vehicleService.findById(id).ifPresent(v -> {
                v.setBrand(req.getParameter("brand"));
                v.setModel(req.getParameter("model"));
                v.setYear(Integer.parseInt(req.getParameter("year")));
                String mi = req.getParameter("mileage");
                if (mi != null && !mi.isBlank()) v.setMileage(Integer.parseInt(mi));
                v.setStatus(VehicleStatus.valueOf(req.getParameter("status")));
                String dId = req.getParameter("assignedDriverId");
                if (dId != null && !dId.isBlank())
                    userService.findById(Long.parseLong(dId)).ifPresent(v::setAssignedDriver);
                else
                    v.setAssignedDriver(null);
                vehicleService.updateVehicle(v);
            });
        }

        resp.sendRedirect(req.getContextPath() + "/app/vehicles");
    }
}
