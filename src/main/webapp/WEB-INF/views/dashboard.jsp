<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SafeDrive — Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <style>#accident-map { height: 420px; border-radius: 10px; }</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <div class="topbar">
        <h5 class="mb-0 fw-bold">Tableau de bord</h5>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-danger px-3 py-2">${currentRole}</span>
            <span class="fw-semibold">${currentUser}</span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-secondary ms-2">
                Déconnexion
            </a>
        </div>
    </div>

    <!-- Stats cards -->
    <div class="row g-4 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card p-3">
                <div class="text-muted small">Total Véhicules</div>
                <div class="fw-bold fs-3">${totalVehicles}</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card p-3">
                <div class="text-muted small">Véhicules Disponibles</div>
                <div class="fw-bold fs-3">${availableVehicles}</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card p-3">
                <div class="text-muted small">Total Accidents</div>
                <div class="fw-bold fs-3">${totalAccidents}</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card p-3">
                <div class="text-muted small">Accidents en attente</div>
                <div class="fw-bold fs-3">${pendingAccidents}</div>
            </div>
        </div>
        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card p-3">
                <div class="text-muted small">Utilisateurs</div>
                <div class="fw-bold fs-3">${totalUsers}</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card p-3">
                <div class="text-muted small">Chauffeurs</div>
                <div class="fw-bold fs-3">${totalDrivers}</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card p-3">
                <div class="text-muted small">En maintenance</div>
                <div class="fw-bold fs-3">${maintenanceVehicles}</div>
            </div>
        </div>
        </c:if>
    </div>

    <!-- Accident map (ADMIN / MANAGER only) -->
    <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-white fw-semibold py-3">
            Carte des Accidents
        </div>
        <div class="card-body p-2">
            <div id="accident-map"></div>
        </div>
    </div>
    </c:if>

    <!-- Recent accidents table -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white fw-semibold py-3">
            Accidents Récents
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Chauffeur</th><th>Véhicule</th><th>Date</th>
                            <th>Lieu</th><th>Sévérité</th><th>Statut</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${recentAccidents}">
                        <tr>
                            <td>${a.driver.firstName} ${a.driver.lastName}</td>
                            <td>${a.vehicle.brand} ${a.vehicle.model}</td>
                            <td>${a.date}</td>
                            <td>${a.location}</td>
                            <td>
                                <span class="badge
                                    ${a.severity == 'SEVERE'   ? 'bg-danger' :
                                      a.severity == 'MODERATE' ? 'bg-warning text-dark' : 'bg-success'}">
                                    ${a.severity}
                                </span>
                            </td>
                            <td>
                                <span class="badge
                                    ${a.status == 'DECLARED'     ? 'bg-secondary' :
                                      a.status == 'UNDER_REVIEW' ? 'bg-info text-dark' : 'bg-success'}">
                                    ${a.status}
                                </span>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty recentAccidents}">
                        <tr><td colspan="6" class="text-center text-muted py-4">Aucun accident enregistré</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
<script>
(function() {
    var map = L.map('accident-map').setView([36.7372, 3.0926], 6);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
        maxZoom: 18
    }).addTo(map);

    var severityColor = { 'SEVERE': '#dc3545', 'MODERATE': '#ffc107', 'MINOR': '#198754' };

    var accidents = [
        <c:forEach var="a" items="${mapAccidents}" varStatus="loop">
        <c:if test="${a.latitude != null && a.longitude != null}">
        {
            lat:      ${a.latitude},
            lng:      ${a.longitude},
            date:     '<c:out value="${a.date}"/>',
            driver:   '<c:out value="${a.driver.firstName} ${a.driver.lastName}"/>',
            vehicle:  '<c:out value="${a.vehicle.brand} ${a.vehicle.model}"/>',
            severity: '<c:out value="${a.severity}"/>',
            location: '<c:out value="${a.location}"/>'
        }<c:if test="${!loop.last}">,</c:if>
        </c:if>
        </c:forEach>
    ].filter(function(a){ return a && a.lat !== undefined; });

    if (accidents.length === 0) {
        document.getElementById('accident-map').innerHTML =
            '<div class="d-flex align-items-center justify-content-center h-100 text-muted">Aucun accident géolocalisé</div>';
        return;
    }

    var bounds = [];
    accidents.forEach(function(a) {
        var color = severityColor[a.severity] || '#6c757d';
        var icon = L.divIcon({
            className: '',
            html: '<div style="width:14px;height:14px;border-radius:50%;background:' + color + ';border:2px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.4)"></div>',
            iconSize: [14, 14],
            iconAnchor: [7, 7]
        });
        var popup =
            '<strong>' + a.driver + '</strong><br>' +
            '<span class="text-muted">' + a.vehicle + '</span><br>' +
            'Date : ' + a.date + '<br>' +
            'Lieu : ' + a.location + '<br>' +
            'Sévérité : <strong style="color:' + color + '">' + a.severity + '</strong>';
        L.marker([a.lat, a.lng], { icon: icon }).bindPopup(popup).addTo(map);
        bounds.push([a.lat, a.lng]);
    });

    if (bounds.length > 0) map.fitBounds(bounds, { padding: [30, 30] });
})();
</script>
</c:if>
</body>
</html>
