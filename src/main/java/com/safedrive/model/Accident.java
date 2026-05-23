package com.safedrive.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "accidents")
public class Accident {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false)
    private User driver;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @Column(nullable = false)
    private LocalDate date;

    @Column(length = 200)
    private String location;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AccidentSeverity severity = AccidentSeverity.MINOR;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AccidentStatus status = AccidentStatus.DECLARED;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "ai_severity", length = 20)
    private String aiSeverity = "EN_ATTENTE";

    @Column(name = "ai_confidence")
    private Double aiConfidence;

    @Column(name = "gravite_manuelle", columnDefinition = "boolean default false")
    private Boolean graviteManuelle = false;

    public Accident() {}

    // Getters & Setters

    public Long getId()                         { return id; }
    public void setId(Long id)                  { this.id = id; }

    public User getDriver()                     { return driver; }
    public void setDriver(User v)               { this.driver = v; }

    public Vehicle getVehicle()                 { return vehicle; }
    public void setVehicle(Vehicle v)           { this.vehicle = v; }

    public LocalDate getDate()                  { return date; }
    public void setDate(LocalDate v)            { this.date = v; }

    public String getLocation()                 { return location; }
    public void setLocation(String v)           { this.location = v; }

    public String getDescription()              { return description; }
    public void setDescription(String v)        { this.description = v; }

    public AccidentSeverity getSeverity()       { return severity; }
    public void setSeverity(AccidentSeverity v) { this.severity = v; }

    public AccidentStatus getStatus()           { return status; }
    public void setStatus(AccidentStatus v)     { this.status = v; }

    public Double getLatitude()                  { return latitude; }
    public void setLatitude(Double v)            { this.latitude = v; }

    public Double getLongitude()                 { return longitude; }
    public void setLongitude(Double v)           { this.longitude = v; }

    public LocalDateTime getCreatedAt()         { return createdAt; }

    public String getAiSeverity()               { return aiSeverity; }
    public void setAiSeverity(String v)         { this.aiSeverity = v; }

    public Double getAiConfidence()             { return aiConfidence; }
    public void setAiConfidence(Double v)       { this.aiConfidence = v; }

    public Boolean getGraviteManuelle()         { return graviteManuelle != null ? graviteManuelle : false; }
    public boolean isGraviteManuelle()          { return graviteManuelle != null && graviteManuelle; }
    public void setGraviteManuelle(Boolean v)   { this.graviteManuelle = v != null ? v : false; }
}
