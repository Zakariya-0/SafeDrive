package com.safedrive.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "vehicles")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "registration_number", unique = true, nullable = false, length = 20)
    private String registrationNumber;

    @Column(length = 50)
    private String brand;

    @Column(length = 50)
    private String model;

    @Column
    private Integer year;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VehicleStatus status = VehicleStatus.AVAILABLE;

    @Column
    private Integer mileage = 0;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chauffeur_id", unique = true)
    private User assignedDriver;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Vehicle() {}

    // Getters & Setters

    public Long getId()                         { return id; }
    public void setId(Long id)                  { this.id = id; }

    public String getRegistrationNumber()        { return registrationNumber; }
    public void setRegistrationNumber(String v)  { this.registrationNumber = v; }

    public String getBrand()                     { return brand; }
    public void setBrand(String v)               { this.brand = v; }

    public String getModel()                     { return model; }
    public void setModel(String v)               { this.model = v; }

    public Integer getYear()                     { return year; }
    public void setYear(Integer v)               { this.year = v; }

    public VehicleStatus getStatus()             { return status; }
    public void setStatus(VehicleStatus v)       { this.status = v; }

    public Integer getMileage()                  { return mileage; }
    public void setMileage(Integer v)            { this.mileage = v; }

    public User getAssignedDriver()              { return assignedDriver; }
    public void setAssignedDriver(User v)        { this.assignedDriver = v; }

    public LocalDateTime getCreatedAt()          { return createdAt; }
}
