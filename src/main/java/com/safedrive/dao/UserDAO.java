package com.safedrive.dao;

import com.safedrive.config.HibernateUtil;
import com.safedrive.model.Role;
import com.safedrive.model.User;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class UserDAO {

    public Optional<User> findById(Long id) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return Optional.ofNullable(em.find(User.class, id));
        } finally { em.close(); }
    }

    public Optional<User> findByUsername(String username) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT u FROM User u WHERE u.username = :u", User.class)
                    .setParameter("u", username)
                    .getResultStream().findFirst();
        } finally { em.close(); }
    }

    public List<User> findAll() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT u FROM User u ORDER BY u.lastName", User.class)
                    .getResultList();
        } finally { em.close(); }
    }

    public List<User> findByRole(Role role) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT u FROM User u WHERE u.role = :r ORDER BY u.lastName", User.class)
                    .setParameter("r", role)
                    .getResultList();
        } finally { em.close(); }
    }

    public User save(User user) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            em.getTransaction().begin();
            User merged = em.merge(user);
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
            User u = em.find(User.class, id);
            if (u != null) em.remove(u);
            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally { em.close(); }
    }

    public long count() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery("SELECT COUNT(u) FROM User u", Long.class).getSingleResult();
        } finally { em.close(); }
    }

    public long countByRole(Role role) {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT COUNT(u) FROM User u WHERE u.role = :r", Long.class)
                    .setParameter("r", role)
                    .getSingleResult();
        } finally { em.close(); }
    }

    /** Tous les chauffeurs avec leur véhicule chargé (évite la LazyInitializationException en JSP). */
    public List<User> findAllChauffeurs() {
        EntityManager em = HibernateUtil.getEMF().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT u FROM User u LEFT JOIN FETCH u.assignedVehicle " +
                    "WHERE u.role = :r ORDER BY u.lastName",
                    User.class)
                    .setParameter("r", Role.DRIVER)
                    .getResultList();
        } finally { em.close(); }
    }
}
