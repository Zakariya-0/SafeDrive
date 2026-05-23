<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>SafeDrive — Accident #${accident.id}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <style>
        #detail-map { height: 300px; border-radius: 8px; border: 1px solid #dee2e6; }
        .info-label { font-size: .75rem; color: #6c757d; text-transform: uppercase; letter-spacing: .05em; }
        .info-value { font-size: 1rem; font-weight: 500; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main-content">

    <%-- Alerte affichée uniquement juste après une nouvelle déclaration --%>
    <c:if test="${newDeclaration}">
    <div class="alert alert-success alert-dismissible fade show mb-3" role="alert">
        <strong><i class="bi bi-check-circle-fill me-1"></i> Accident déclaré avec succès !</strong>
        <c:choose>
            <c:when test="${accident.aiSeverity == 'EN_ATTENTE' || empty accident.aiSeverity}">
                Aucune image fournie — analyse IA non disponible.
            </c:when>
            <c:otherwise>
                Résultat de l'analyse IA :
                <span class="badge ms-1 ${accident.aiSeverity == 'GRAVE' ? 'bg-danger' : 'bg-success'}">
                    ${accident.aiSeverity == 'GRAVE' ? '🔴 GRAVE' : '🟢 LÉGER'}
                </span>
                <c:if test="${aiConfPct != null}">
                     — Confiance : <strong>${aiConfPct}%</strong>
                </c:if>
                 — <em>Gravité détectée automatiquement par l'IA</em>
            </c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    </c:if>

    <div class="topbar d-flex align-items-center gap-3">
        <a href="${pageContext.request.contextPath}/app/accidents" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left"></i> Retour
        </a>
        <h5 class="mb-0 fw-bold">Accident #${accident.id}</h5>

        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <div class="ms-auto d-flex gap-2">
            <c:if test="${accident.status != 'RESOLVED'}">
            <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=RESOLVED&returnTo=detail"
               class="btn btn-success btn-sm"
               onclick="return confirm('Marquer cet accident comme résolu ?')">
                <i class="bi bi-check-circle"></i> Marquer comme traité
            </a>
            </c:if>
            <a href="${pageContext.request.contextPath}/app/reports?type=accident-single&id=${accident.id}"
               class="btn btn-outline-dark btn-sm">
                <i class="bi bi-file-earmark-pdf"></i> Télécharger PDF
            </a>
        </div>
        </c:if>
    </div>

    <div class="row g-4">
        <!-- Informations principales -->
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white border-bottom fw-semibold">
                    Informations de l'accident
                </div>
                <div class="card-body">
                    <div class="row g-4">
                        <c:if test="${currentRole != 'DRIVER'}">
                        <div class="col-sm-6">
                            <div class="info-label">Chauffeur</div>
                            <div class="info-value">
                                <i class="bi bi-person me-1 text-secondary"></i>
                                ${accident.driver.firstName} ${accident.driver.lastName}
                            </div>
                        </div>
                        </c:if>
                        <div class="col-sm-6">
                            <div class="info-label">Véhicule</div>
                            <div class="info-value">
                                <i class="bi bi-truck me-1 text-secondary"></i>
                                ${accident.vehicle.brand} ${accident.vehicle.model}
                                <small class="text-muted">(${accident.vehicle.registrationNumber})</small>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="info-label">Date</div>
                            <div class="info-value">
                                <i class="bi bi-calendar3 me-1 text-secondary"></i>
                                ${accident.date}
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="info-label">Lieu</div>
                            <div class="info-value">
                                <i class="bi bi-geo-alt me-1 text-secondary"></i>
                                <c:choose>
                                    <c:when test="${not empty accident.location}">${accident.location}</c:when>
                                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="info-label">Gravité</div>
                            <div class="info-value">
                                <span class="badge fs-6
                                    ${accident.severity == 'SEVERE'   ? 'bg-danger' :
                                      accident.severity == 'MODERATE' ? 'bg-warning text-dark' : 'bg-success'}">
                                    <c:choose>
                                        <c:when test="${accident.severity == 'SEVERE'}">Grave</c:when>
                                        <c:when test="${accident.severity == 'MODERATE'}">Modéré</c:when>
                                        <c:otherwise>Mineur</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="info-label">Statut</div>
                            <div class="info-value">
                                <span class="badge fs-6
                                    ${accident.status == 'DECLARED'     ? 'bg-secondary' :
                                      accident.status == 'UNDER_REVIEW' ? 'bg-info text-dark' : 'bg-success'}">
                                    <c:choose>
                                        <c:when test="${accident.status == 'DECLARED'}">Déclaré</c:when>
                                        <c:when test="${accident.status == 'UNDER_REVIEW'}">En révision</c:when>
                                        <c:otherwise>Résolu</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="info-label">Description</div>
                            <div class="info-value mt-1">
                                <c:choose>
                                    <c:when test="${not empty accident.description}">${accident.description}</c:when>
                                    <c:otherwise><span class="text-muted">Aucune description</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <%-- ── Résultat de l'analyse IA ─────────────────────── --%>
                        <div class="col-12">
                            <div class="info-label">Analyse IA</div>
                            <div class="d-flex flex-wrap align-items-center gap-3 mt-1">
                                <c:choose>
                                    <c:when test="${accident.aiSeverity == 'GRAVE'}">
                                        <span class="badge bg-danger fs-6">🔴 GRAVE</span>
                                    </c:when>
                                    <c:when test="${accident.aiSeverity == 'LEGER'}">
                                        <span class="badge bg-success fs-6">🟢 LÉGER</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary fs-6">⏳ EN ATTENTE</span>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${aiConfPct != null}">
                                <span class="text-muted small">
                                    Confiance IA : <strong>${aiConfPct}%</strong>
                                </span>
                                </c:if>
                                <span class="text-muted small fst-italic">
                                    Gravité détectée automatiquement par l'IA
                                </span>
                            </div>
                            <c:if test="${accident.graviteManuelle == true}">
                            <div class="mt-2 small text-warning fw-semibold">
                                <i class="bi bi-exclamation-triangle-fill me-1"></i>
                                Gravité modifiée manuellement par
                                ${currentRole == 'ADMIN' ? "l'Admin" : 'le Manager'}
                            </div>
                            </c:if>
                        </div>
                        <%-- ──────────────────────────────────────────────────── --%>

                        <c:if test="${accident.latitude != null && accident.longitude != null}">
                        <div class="col-12">
                            <div class="info-label mb-2">Localisation GPS</div>
                            <div id="detail-map"></div>
                            <small class="text-muted">
                                ${accident.latitude}, ${accident.longitude}
                            </small>
                        </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <!-- Actions -->
        <div class="col-lg-4">
            <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-white border-bottom fw-semibold">
                    Reclassifier la gravité
                </div>
                <div class="card-body">
                    <form method="post" action="${pageContext.request.contextPath}/app/accidents">
                        <input type="hidden" name="action" value="reclassify">
                        <input type="hidden" name="id"     value="${accident.id}">
                        <div class="mb-3">
                            <label class="form-label">Nouvelle gravité</label>
                            <select name="severity" class="form-select">
                                <option value="MINOR"
                                    ${accident.severity == 'MINOR' ? 'selected' : ''}>
                                    Mineur
                                </option>
                                <option value="MODERATE"
                                    ${accident.severity == 'MODERATE' ? 'selected' : ''}>
                                    Modéré
                                </option>
                                <option value="SEVERE"
                                    ${accident.severity == 'SEVERE' ? 'selected' : ''}>
                                    Grave
                                </option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-warning w-100">
                            <i class="bi bi-pencil-square me-1"></i> Appliquer
                        </button>
                    </form>
                </div>
            </div>

            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-white border-bottom fw-semibold">
                    Changer le statut
                </div>
                <div class="card-body d-grid gap-2">
                    <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=DECLARED&returnTo=detail"
                       class="btn btn-outline-secondary btn-sm ${accident.status == 'DECLARED' ? 'active' : ''}">
                        Déclaré
                    </a>
                    <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=UNDER_REVIEW&returnTo=detail"
                       class="btn btn-outline-info btn-sm ${accident.status == 'UNDER_REVIEW' ? 'active' : ''}">
                        En révision
                    </a>
                    <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=RESOLVED&returnTo=detail"
                       class="btn btn-outline-success btn-sm ${accident.status == 'RESOLVED' ? 'active' : ''}">
                        Résolu
                    </a>
                </div>
            </div>
            </c:if>

            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white border-bottom fw-semibold">
                    Métadonnées
                </div>
                <div class="card-body">
                    <div class="info-label">Enregistré le</div>
                    <div class="info-value mb-0">${accident.createdAt}</div>
                </div>
            </div>
        </div>
    </div>
</div>

<c:if test="${accident.latitude != null && accident.longitude != null}">
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(function() {
    var lat = ${accident.latitude};
    var lng = ${accident.longitude};
    var map = L.map('detail-map').setView([lat, lng], 14);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
        maxZoom: 18
    }).addTo(map);
    L.marker([lat, lng]).addTo(map);
})();
</script>
</c:if>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
