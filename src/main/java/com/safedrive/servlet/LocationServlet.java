package com.safedrive.servlet;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.safedrive.model.DriverLocation;
import com.safedrive.service.DriverLocationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/app/api/locations/*")
public class LocationServlet extends HttpServlet {

    private final DriverLocationService service = new DriverLocationService();
    private final ObjectMapper mapper = new ObjectMapper();

    /**
     * GET /app/api/locations/all
     * Returns JSON array of all driver positions.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!"/all".equals(req.getPathInfo())) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (DriverLocation loc : service.getAllLocations()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("driverId",  loc.getDriver().getId());
            m.put("name",      loc.getDriver().getFirstName() + " " + loc.getDriver().getLastName());
            m.put("lat",       loc.getLatitude());
            m.put("lng",       loc.getLongitude());
            m.put("updatedAt", loc.getUpdatedAt().toString());
            result.add(m);
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        mapper.writeValue(resp.getWriter(), result);
    }

    /**
     * POST /app/api/locations/update
     * Body: { "lat": 36.7372, "lng": 3.0926 }
     * Called by the DRIVER's browser via Geolocation API.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!"/update".equals(req.getPathInfo())) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Long driverId = (Long) req.getAttribute("currentUserId");
        String body = req.getReader().lines().collect(Collectors.joining());

        @SuppressWarnings("unchecked")
        Map<String, Object> data = mapper.readValue(body, Map.class);
        double lat = ((Number) data.get("lat")).doubleValue();
        double lng = ((Number) data.get("lng")).doubleValue();

        service.updateLocation(driverId, lat, lng);

        resp.setContentType("application/json");
        resp.getWriter().write("{\"status\":\"ok\"}");
    }
}
