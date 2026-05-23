package com.safedrive.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 50)
    private String username;

    @Column(unique = true, nullable = false, length = 100)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "first_name", length = 50)
    private String firstName;

    @Column(name = "last_name", length = 50)
    private String lastName;

    @Column(length = 20)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToOne(mappedBy = "assignedDriver", fetch = FetchType.LAZY)
    private Vehicle assignedVehicle;

    public User() {}

    // Getters & Setters

    public Long getId()                     { return id; }
    public void setId(Long id)              { this.id = id; }

    public String getUsername()             { return username; }
    public void setUsername(String v)       { this.username = v; }

    public String getEmail()                { return email; }
    public void setEmail(String v)          { this.email = v; }

    public String getPassword()             { return password; }
    public void setPassword(String v)       { this.password = v; }

    public String getFirstName()            { return firstName; }
    public void setFirstName(String v)      { this.firstName = v; }

    public String getLastName()             { return lastName; }
    public void setLastName(String v)       { this.lastName = v; }

    public String getPhone()                { return phone; }
    public void setPhone(String v)          { this.phone = v; }

    public Role getRole()                   { return role; }
    public void setRole(Role v)             { this.role = v; }

    public boolean isActive()               { return active; }
    public void setActive(boolean v)        { this.active = v; }

    public LocalDateTime getCreatedAt()     { return createdAt; }

    public Vehicle getAssignedVehicle()          { return assignedVehicle; }
    public void setAssignedVehicle(Vehicle v)    { this.assignedVehicle = v; }

    public String getFullName() {
        return (firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "");
    }
}
