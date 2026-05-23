package com.safedrive.dao;

import com.safedrive.config.HibernateUtil;
import com.safedrive.model.Vehicle;
import com.safedrive.model.VehicleStatus;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class VehicleDAO {

    public Optional<Vehicle> findById(Long id) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return Optional.ofNullable(em.find(Vehicle.class, id));
        } finally { em.close(); }
    }

    public List<Vehicle> findAll() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT v FROM Vehicle v LEFT JOIN FETCH v.assignedDriver ORDER BY v.brand",
                    Vehicle.class).getResultList();
        } finally { em.close(); }
    }

    public List<Vehicle> findByStatus(VehicleStatus status) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT v FROM Vehicle v WHERE v.status = :s ORDER BY v.brand",
                    Vehicle.class)
                    .setParameter("s", status)
                    .getResultList();
        } finally { em.close(); }
    }

    public Vehicle save(Vehicle vehicle) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            Vehicle merged = em.merge(vehicle);
            em.getTransaction().commit();
            return merged;
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }

    public void delete(Long id) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            Vehicle v = em.find(Vehicle.class, id);
            if (v != null) em.remove(v);
            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }

    public long count() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery("SELECT COUNT(v) FROM Vehicle v", Long.class).getSingleResult();
        } finally { em.close(); }
    }

    public long countByStatus(VehicleStatus status) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT COUNT(v) FROM Vehicle v WHERE v.status = :s", Long.class)
                    .setParameter("s", status)
                    .getSingleResult();
        } finally { em.close(); }
    }

    /** Véhicule assigné à un chauffeur donné. */
    public Optional<Vehicle> findByDriverId(Long driverId) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            List<Vehicle> result = em.createQuery(
                    "SELECT v FROM Vehicle v WHERE v.assignedDriver.id = :driverId",
                    Vehicle.class)
                    .setParameter("driverId", driverId)
                    .getResultList();
            return result.isEmpty() ? Optional.empty() : Optional.of(result.get(0));
        } finally { em.close(); }
    }

    /** Véhicules sans chauffeur assigné (pour la modal d'attribution). */
    public List<Vehicle> findAvailable() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT v FROM Vehicle v WHERE v.assignedDriver IS NULL ORDER BY v.brand",
                    Vehicle.class).getResultList();
        } finally { em.close(); }
    }

    /**
     * Attribue un chauffeur à un véhicule dans une seule transaction.
     * Désassigne automatiquement :
     *  - l'ancien véhicule du chauffeur (s'il en avait un)
     *  - l'ancien chauffeur du véhicule cible (s'il en avait un)
     */
    public void assignChauffeur(Long vehicleId, Long chauffeurId) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();

            Vehicle targetVehicle = em.find(Vehicle.class, vehicleId);
            com.safedrive.model.User chauffeur = em.find(com.safedrive.model.User.class, chauffeurId);
            if (targetVehicle == null || chauffeur == null) {
                em.getTransaction().rollback();
                return;
            }

            // Libérer ce chauffeur de tout autre véhicule qu'il occupait
            em.createQuery(
                    "SELECT v FROM Vehicle v WHERE v.assignedDriver.id = :cid AND v.id <> :vid",
                    Vehicle.class)
                    .setParameter("cid", chauffeurId)
                    .setParameter("vid", vehicleId)
                    .getResultList()
                    .forEach(v -> v.setAssignedDriver(null));

            em.flush(); // vider les NULL avant de poser la nouvelle clé unique

            targetVehicle.setAssignedDriver(chauffeur);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }

    /** Retire le chauffeur d'un véhicule. */
    public void unassignChauffeur(Long vehicleId) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            Vehicle v = em.find(Vehicle.class, vehicleId);
            if (v != null) v.setAssignedDriver(null);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }
}
