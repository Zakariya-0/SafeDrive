<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>SafeDrive — Rapports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main-content">
    <div class="topbar">
        <h5 class="mb-0 fw-bold">Génération de Rapports PDF</h5>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-danger px-3 py-2">${currentRole}</span>
            <span class="fw-semibold">${currentUser}</span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-secondary ms-2">
                Déconnexion
            </a>
        </div>
    </div>

    <div class="row g-4">

        <!-- Accidents : visible à tous les rôles -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100 p-4 d-flex flex-column">
                <c:choose>
                    <c:when test="${currentRole == 'DRIVER'}">
                        <h5 class="fw-bold">Mes Accidents</h5>
                        <p class="text-muted">Exporter la liste de vos propres accidents avec leur statut et détails en PDF.</p>
                    </c:when>
                    <c:otherwise>
                        <h5 class="fw-bold">Rapport des Accidents</h5>
                        <p class="text-muted">Exporter la liste complète des accidents de tous les chauffeurs en PDF.</p>
                    </c:otherwise>
                </c:choose>
                <a href="${pageContext.request.contextPath}/app/reports?type=accidents"
                   class="btn btn-danger mt-auto">
                    Télécharger PDF
                </a>
            </div>
        </div>

        <!-- Véhicules : ADMIN et MANAGER uniquement -->
        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100 p-4 d-flex flex-column">
                <h5 class="fw-bold">Rapport des Véhicules</h5>
                <p class="text-muted">Exporter l'inventaire complet des véhicules avec leur état et kilométrage en PDF.</p>
                <a href="${pageContext.request.contextPath}/app/reports?type=vehicles"
                   class="btn btn-primary mt-auto">
                    Télécharger PDF
                </a>
            </div>
        </div>
        </c:if>

    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
