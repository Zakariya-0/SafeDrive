package com.safedrive.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

public class AIService {

    private static final String   AI_URL  = "http://127.0.0.1:8001/classify";
    private static final Duration TIMEOUT = Duration.ofSeconds(30);

    // Force HTTP/1.1 — uvicorn/FastAPI en local ne supporte pas HTTP/2
    private final HttpClient http = HttpClient.newBuilder()
            .version(HttpClient.Version.HTTP_1_1)
            .connectTimeout(TIMEOUT)
            .build();

    public AIResult classifyImage(byte[] imageData) {
        System.out.println("[AIService] Calling AI service with image size: " + imageData.length + " bytes");

        String boundary = "----SafeDriveBoundary" + System.currentTimeMillis();

        byte[] body;
        try {
            body = buildMultipartBody(imageData, boundary, "accident.jpg");
        } catch (IOException e) {
            System.out.println("[AIService] Erreur construction multipart : " + e.getMessage());
            return new AIResult("EN_ATTENTE", 0.0);
        }

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(AI_URL))
                .timeout(TIMEOUT)
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .POST(HttpRequest.BodyPublishers.ofByteArray(body))
                .build();

        try {
            HttpResponse<String> resp = http.send(request, HttpResponse.BodyHandlers.ofString());
            System.out.println("[AIService] AI Response status: " + resp.statusCode());
            System.out.println("[AIService] AI Response body: " + resp.body());

            if (resp.statusCode() == 200) {
                AIResult result = parseResponse(resp.body());
                System.out.println("[AIService] Parsed: severity=" + result.getSeverity()
                        + " confidence=" + result.getConfidence());
                return result;
            }
            System.out.println("[AIService] ERROR - HTTP " + resp.statusCode() + " : " + resp.body());

        } catch (IOException ex) {
            System.out.println("[AIService] IOException - service indisponible : " + ex.getMessage());
            ex.printStackTrace();
        } catch (InterruptedException ex) {
            System.out.println("[AIService] InterruptedException : " + ex.getMessage());
            Thread.currentThread().interrupt();
        }

        System.out.println("[AIService] Returning EN_ATTENTE (fallback)");
        return new AIResult("EN_ATTENTE", 0.0);
    }

    private static byte[] buildMultipartBody(byte[] imageBytes, String boundary, String fileName)
            throws IOException {
        String CRLF = "\r\n";
        ByteArrayOutputStream out = new ByteArrayOutputStream();

        // Part header
        out.write(("--" + boundary + CRLF).getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"" + CRLF)
                .getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Type: image/jpeg" + CRLF).getBytes(StandardCharsets.UTF_8));
        out.write(CRLF.getBytes(StandardCharsets.UTF_8));  // blank line — séparateur headers/body

        // Contenu binaire
        out.write(imageBytes);
        out.write(CRLF.getBytes(StandardCharsets.UTF_8));

        // Closing boundary
        out.write(("--" + boundary + "--" + CRLF).getBytes(StandardCharsets.UTF_8));

        return out.toByteArray();
    }

    // ── Parsing JSON minimal { "severity": "...", "confidence": 0.XX } ──

    private static AIResult parseResponse(String json) {
        String severity   = extractString(json, "severity");
        double confidence = extractDouble(json, "confidence");
        return new AIResult(severity, confidence);
    }

    private static String extractString(String json, String key) {
        int idx = json.indexOf("\"" + key + "\"");
        if (idx < 0) return "EN_ATTENTE";
        int colon = json.indexOf(':', idx);
        int q1    = json.indexOf('"', colon);
        int q2    = json.indexOf('"', q1 + 1);
        return (q1 >= 0 && q2 > q1) ? json.substring(q1 + 1, q2) : "EN_ATTENTE";
    }

    private static double extractDouble(String json, String key) {
        int idx = json.indexOf("\"" + key + "\"");
        if (idx < 0) return 0.0;
        int colon = json.indexOf(':', idx);
        int start = colon + 1;
        while (start < json.length()
                && (json.charAt(start) == ' ' || json.charAt(start) == '\t')) start++;
        int end = start;
        while (end < json.length()
                && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '.')) end++;
        try {
            return Double.parseDouble(json.substring(start, end));
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
}
