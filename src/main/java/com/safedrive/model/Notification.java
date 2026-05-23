package com.safedrive.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 300)
    private String message;

    @Column(nullable = false)
    private boolean read = false;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "accident_id")
    private Accident accident;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Notification() {}

    public Long getId()                        { return id; }

    public String getMessage()                 { return message; }
    public void setMessage(String v)           { this.message = v; }

    public boolean isRead()                    { return read; }
    public void setRead(boolean v)             { this.read = v; }

    public Accident getAccident()              { return accident; }
    public void setAccident(Accident v)        { this.accident = v; }

    public Long getAccidentId()                { return accident != null ? accident.getId() : null; }

    public LocalDateTime getCreatedAt()        { return createdAt; }
}
