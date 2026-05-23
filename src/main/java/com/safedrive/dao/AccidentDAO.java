package com.safedrive.dao;

import com.safedrive.config.HibernateUtil;
import com.safedrive.model.Accident;
import com.safedrive.model.AccidentStatus;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class AccidentDAO {

    public Optional<Accident> findById(Long id) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return Optional.ofNullable(em.find(Accident.class, id));
        } finally { em.close(); }
    }

    public Optional<Accident> findByIdWithDetails(Long id) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            List<Accident> list = em.createQuery(
                    "SELECT a FROM Accident a JOIN FETCH a.driver JOIN FETCH a.vehicle WHERE a.id = :id",
                    Accident.class)
                    .setParameter("id", id)
                    .getResultList();
            return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
        } finally { em.close(); }
    }

    public List<Accident> findAll() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM Accident a JOIN FETCH a.driver JOIN FETCH a.vehicle ORDER BY a.date DESC",
                    Accident.class).getResultList();
        } finally { em.close(); }
    }

    public List<Accident> findByDriverId(Long driverId) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM Accident a JOIN FETCH a.vehicle WHERE a.driver.id = :d ORDER BY a.date DESC",
                    Accident.class)
                    .setParameter("d", driverId)
                    .getResultList();
        } finally { em.close(); }
    }

    public List<Accident> findRecent(int limit) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM Accident a JOIN FETCH a.driver JOIN FETCH a.vehicle ORDER BY a.createdAt DESC",
                    Accident.class)
                    .setMaxResults(limit)
                    .getResultList();
        } finally { em.close(); }
    }

    public Accident save(Accident accident) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            Accident merged = em.merge(accident);
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
            // Supprimer d'abord les notifications qui référencent cet accident
            em.createQuery("DELETE FROM Notification n WHERE n.accident.id = :id")
              .setParameter("id", id)
              .executeUpdate();
            Accident a = em.find(Accident.class, id);
            if (a != null) em.remove(a);
            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }

    public long count() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery("SELECT COUNT(a) FROM Accident a", Long.class).getSingleResult();
        } finally { em.close(); }
    }

    public long countByStatus(AccidentStatus status) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT COUNT(a) FROM Accident a WHERE a.status = :s", Long.class)
                    .setParameter("s", status)
                    .getSingleResult();
        } finally { em.close(); }
    }

    public long countByDriverId(Long driverId) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT COUNT(a) FROM Accident a WHERE a.driver.id = :d", Long.class)
                    .setParameter("d", driverId)
                    .getSingleResult();
        } finally { em.close(); }
    }
}
