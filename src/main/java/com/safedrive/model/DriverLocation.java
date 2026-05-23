package com.safedrive.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "driver_locations")
public class DriverLocation {

    @Id
    @Column(name = "driver_id")
    private Long driverId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "driver_id")
    private User driver;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

    public DriverLocation() {}

    // Getters & Setters

    public Long getDriverId()                   { return driverId; }

    public User getDriver()                     { return driver; }
    public void setDriver(User v)               { this.driver = v; }

    public Double getLatitude()                 { return latitude; }
    public void setLatitude(Double v)           { this.latitude = v; }

    public Double getLongitude()                { return longitude; }
    public void setLongitude(Double v)          { this.longitude = v; }

    public LocalDateTime getUpdatedAt()         { return updatedAt; }
    public void setUpdatedAt(LocalDateTime v)   { this.updatedAt = v; }
}
