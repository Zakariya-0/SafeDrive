package com.safedrive.dao;

import com.safedrive.config.HibernateUtil;
import com.safedrive.model.DriverLocation;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class DriverLocationDAO {

    public Optional<DriverLocation> findByDriverId(Long driverId) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return Optional.ofNullable(em.find(DriverLocation.class, driverId));
        } finally { em.close(); }
    }

    public List<DriverLocation> findAll() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT dl FROM DriverLocation dl JOIN FETCH dl.driver ORDER BY dl.updatedAt DESC",
                    DriverLocation.class).getResultList();
        } finally { em.close(); }
    }

    public DriverLocation save(DriverLocation loc) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            DriverLocation merged = em.merge(loc);
            em.getTransaction().commit();
            return merged;
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }
}
