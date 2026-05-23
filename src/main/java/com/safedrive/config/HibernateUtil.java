package com.safedrive.config;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class HibernateUtil {

    private static final EntityManagerFactory EMF =
            Persistence.createEntityManagerFactory("safedrivepu");

    public static EntityManagerFactory getEMF() {
        return EMF;
    }

    public static void shutdown() {
        if (EMF != null && EMF.isOpen()) EMF.close();
    }
}
