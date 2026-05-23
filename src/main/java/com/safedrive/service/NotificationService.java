package com.safedrive.service;

import com.safedrive.dao.NotificationDAO;
import com.safedrive.model.Accident;
import com.safedrive.model.Notification;

import java.util.List;
import java.util.Optional;

public class NotificationService {

    private final NotificationDAO dao = new NotificationDAO();

    public void createForAccident(Accident a) {
        Notification n = new Notification();
        n.setMessage("Accident déclaré par " +
                a.getDriver().getFirstName() + " " + a.getDriver().getLastName() +
                " — " + a.getVehicle().getBrand() + " " + a.getVehicle().getModel() +
                " le " + a.getDate());
        n.setAccident(a);
        dao.save(n);
    }

    public long getUnreadCount()                   { return dao.countUnread(); }
    public List<Notification> getRecent(int limit) { return dao.findRecent(limit); }
    public void markAllAsRead()                    { dao.markAllAsRead(); }
    public void markAsRead(Long id)                { dao.markAsRead(id); }
    public Optional<Notification> findById(Long id){ return dao.findById(id); }
}
