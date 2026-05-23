package com.safedrive.service;

import com.safedrive.dao.UserDAO;
import com.safedrive.model.Role;
import com.safedrive.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.util.List;
import java.util.Optional;

public class UserService {

    private final UserDAO dao = new UserDAO();

    public Optional<User> authenticate(String username, String password) {
        return dao.findByUsername(username)
                .filter(User::isActive)
                .filter(u -> BCrypt.checkpw(password, u.getPassword()));
    }

    public User createUser(String username, String email, String password,
                           String firstName, String lastName, Role role, String phone) {
        User u = new User();
        u.setUsername(username);
        u.setEmail(email);
        u.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
        u.setFirstName(firstName);
        u.setLastName(lastName);
        u.setRole(role);
        u.setPhone(phone);
        u.setActive(true);
        return dao.save(u);
    }

    public User updateUser(User user) {
        return dao.save(user);
    }

    public void changePassword(Long userId, String newPassword) {
        dao.findById(userId).ifPresent(u -> {
            u.setPassword(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
            dao.save(u);
        });
    }

    public void toggleActive(Long userId) {
        dao.findById(userId).ifPresent(u -> {
            u.setActive(!u.isActive());
            dao.save(u);
        });
    }

    public void deleteUser(Long id)                  { dao.delete(id); }
    public Optional<User> findById(Long id)          { return dao.findById(id); }
    public List<User> getAllUsers()                   { return dao.findAll(); }
    public List<User> getUsersByRole(Role role)       { return dao.findByRole(role); }
    public List<User> getAllChauffeurs()              { return dao.findAllChauffeurs(); }
    public long countTotal()                          { return dao.count(); }
    public long countByRole(Role role)                { return dao.countByRole(role); }
}
