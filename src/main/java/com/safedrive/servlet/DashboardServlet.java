package com.safedrive.servlet;

import com.safedrive.model.AccidentStatus;
import com.safedrive.model.Role;
import com.safedrive.model.VehicleStatus;
import com.safedrive.service.AccidentService;
import com.safedrive.service.UserService;
import com.safedrive.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/dashboard")
public class DashboardServlet extends HttpServlet {

    private final UserService     userService     = new UserService();
    private final VehicleService  vehicleService  = new VehicleService();
    private final AccidentService accidentService = new AccidentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = (String) req.getAttribute("currentRole");

        req.setAttribute("totalVehicles",    vehicleService.countTotal());
        req.setAttribute("availableVehicles", vehicleService.countByStatus(VehicleStatus.AVAILABLE));
        req.setAttribute("totalAccidents",   accidentService.countTotal());
        req.setAttribute("pendingAccidents", accidentService.countByStatus(AccidentStatus.DECLARED));
        req.setAttribute("recentAccidents",  accidentService.getRecentAccidents(5));

        if ("ADMIN".equals(role) || "MANAGER".equals(role)) {
            req.setAttribute("totalUsers",         userService.countTotal());
            req.setAttribute("totalDrivers",       userService.countByRole(Role.DRIVER));
            req.setAttribute("maintenanceVehicles", vehicleService.countByStatus(VehicleStatus.MAINTENANCE));
            req.setAttribute("mapAccidents",       accidentService.getAllAccidents());
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
