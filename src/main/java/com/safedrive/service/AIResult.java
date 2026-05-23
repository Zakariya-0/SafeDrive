package com.safedrive.service;

/** DTO renvoyé par le microservice IA (LEGER / GRAVE / EN_ATTENTE). */
public class AIResult {

    private final String severity;
    private final double confidence;

    public AIResult(String severity, double confidence) {
        this.severity   = severity;
        this.confidence = confidence;
    }

    public String getSeverity()   { return severity; }
    public double getConfidence() { return confidence; }
}
