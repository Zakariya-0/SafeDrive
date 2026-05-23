<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SafeDrive — Suivi en direct</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <style>
        #map { height: calc(100vh - 130px); border-radius: 12px; }
        #status-bar { font-size: .82rem; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <div class="topbar">
        <h5 class="mb-0 fw-bold">Suivi en Direct</h5>
        <div class="d-flex align-items-center gap-3">
            <span id="status-bar" class="text-muted">
                <span id="driver-count" class="fw-bold text-dark">—</span> chauffeur(s) actif(s)
                &nbsp;·&nbsp; Actualisation dans <span id="countdown" class="fw-bold text-danger">10</span>s
            </span>
            <span class="badge bg-danger px-3 py-2">${currentRole}</span>
            <span class="fw-semibold">${currentUser}</span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-secondary">
                Déconnexion
            </a>
        </div>
    </div>

    <div id="map"></div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const CTX  = '${pageContext.request.contextPath}';
    const ROLE = '${currentRole}';

    const map = L.map('map').setView([36.7372, 3.0926], 6);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
        maxZoom: 18
    }).addTo(map);

    const markers = {};

    function fetchLocations() {
        fetch(CTX + '/app/api/locations/all')
            .then(r => r.json())
            .then(locations => {
                document.getElementById('driver-count').textContent = locations.length;
                locations.forEach(loc => {
                    const latlng   = [loc.lat, loc.lng];
                    const popupHtml =
                        '<strong>' + loc.name + '</strong><br>' +
                        '<small>Mis à jour : ' + formatDate(loc.updatedAt) + '</small>';
                    if (markers[loc.driverId]) {
                        markers[loc.driverId].setLatLng(latlng);
                        markers[loc.driverId].setPopupContent(popupHtml);
                    } else {
                        markers[loc.driverId] = L.marker(latlng)
                            .bindPopup(popupHtml)
                            .addTo(map);
                    }
                });
            })
            .catch(() => console.warn('Échec de la récupération des positions'));
    }

    let seconds = 10;
    function tick() {
        seconds--;
        document.getElementById('countdown').textContent = seconds;
        if (seconds <= 0) { seconds = 10; fetchLocations(); }
    }

    fetchLocations();
    setInterval(tick, 1000);

    if (ROLE === 'DRIVER' && navigator.geolocation) {
        navigator.geolocation.watchPosition(
            pos => fetch(CTX + '/app/api/locations/update', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ lat: pos.coords.latitude, lng: pos.coords.longitude })
            }),
            err => console.warn('Géolocalisation refusée', err),
            { enableHighAccuracy: true, timeout: 10000 }
        );
    }

    function formatDate(iso) {
        try { return new Date(iso).toLocaleString('fr-FR'); } catch(e) { return iso; }
    }
</script>
</body>
</html>
