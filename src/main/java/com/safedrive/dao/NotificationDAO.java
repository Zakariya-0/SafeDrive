package com.safedrive.dao;

import com.safedrive.config.HibernateUtil;
import com.safedrive.model.Notification;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class NotificationDAO {

    public Optional<Notification> findById(Long id) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return Optional.ofNullable(em.find(Notification.class, id));
        } finally { em.close(); }
    }

    public void markAsRead(Long notificationId) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery(
                "UPDATE Notification n SET n.read = true WHERE n.id = :id AND n.read = false")
              .setParameter("id", notificationId)
              .executeUpdate();
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }

    public Notification save(Notification n) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            Notification merged = em.merge(n);
            em.getTransaction().commit();
            return merged;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public long countUnread() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT COUNT(n) FROM Notification n WHERE n.read = false", Long.class)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }

    public List<Notification> findRecent(int limit) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT n FROM Notification n ORDER BY n.createdAt DESC", Notification.class)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public void markAllAsRead() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("UPDATE Notification n SET n.read = true WHERE n.read = false")
              .executeUpdate();
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
