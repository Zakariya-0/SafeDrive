package com.safedrive.service;

import com.safedrive.config.HibernateUtil;
import com.safedrive.dao.DriverLocationDAO;
import com.safedrive.model.DriverLocation;
import com.safedrive.model.User;
import jakarta.persistence.EntityManager;

import java.time.LocalDateTime;
import java.util.List;

public class DriverLocationService {

    private final DriverLocationDAO dao = new DriverLocationDAO();

    public void updateLocation(Long driverId, double lat, double lng) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            DriverLocation loc = em.find(DriverLocation.class, driverId);
            if (loc == null) {
                User driver = em.find(User.class, driverId);
                if (driver == null) throw new IllegalArgumentException("Driver not found: " + driverId);
                loc = new DriverLocation();
                loc.setDriver(driver);
                loc.setLatitude(lat);
                loc.setLongitude(lng);
                loc.setUpdatedAt(LocalDateTime.now());
                em.persist(loc);   // new entity — persist, not merge
            } else {
                loc.setLatitude(lat);
                loc.setLongitude(lng);
                loc.setUpdatedAt(LocalDateTime.now());
                // already managed — no merge needed, changes are tracked automatically
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }

    public List<DriverLocation> getAllLocations() {
        return dao.findAll();
    }
}
