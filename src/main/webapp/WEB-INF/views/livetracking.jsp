<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Suivi en Direct</title>
  <%-- Tabler CSS first, then Leaflet CSS (order matters for z-index) --%>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/css/tabler.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <%-- Leaflet CSS must be in <head> before the map div renders --%>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
  <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
  <style>
    /* Explicit height so Leaflet can compute its canvas — never rely on calc() alone */
    #tracking-map-container { height: 600px; }
    #map { height: 100%; width: 100%; }
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50%       { opacity: 0.3; }
    }
  </style>
</head>
<body class="antialiased">
<div class="wrapper">

  <%@ include file="sidebar.jsp" %>

  <div class="page-wrapper">

    <!-- Page header -->
    <div class="page-header d-print-none">
      <div class="container-xl">
        <div class="row g-2 align-items-center">
          <div class="col">
            <ol class="breadcrumb breadcrumb-arrows" aria-label="breadcrumbs">
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/app/dashboard">Tableau de bord</a></li>
              <li class="breadcrumb-item active">Suivi en Direct</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-location-dot me-2 text-danger"></i>Suivi en Direct
            </h2>
          </div>
          <div class="col-auto ms-auto">
            <div class="d-flex align-items-center gap-3 flex-wrap">
              <span class="badge bg-success d-flex align-items-center gap-1">
                <span class="rounded-circle"
                      style="width:6px;height:6px;background:#fff;display:inline-block;animation:pulse 1.5s infinite"></span>
                LIVE
              </span>
              <span class="text-muted">
                <i class="fa-solid fa-users me-1"></i>
                <span id="driver-count" class="fw-bold text-dark">—</span> chauffeur(s) actif(s)
              </span>
              <span class="badge bg-danger-lt text-danger">
                <i class="fa-solid fa-rotate me-1"></i>
                Actualisation dans <span id="countdown" class="fw-bold">10</span>s
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="page-body">
      <div class="container-xl">

        <div class="card">
          <div class="card-body p-2">
            <%-- Fixed-height wrapper — Leaflet REQUIRES a non-zero height at init time --%>
            <div id="tracking-map-container">
              <div id="map"></div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div><!-- /page-wrapper -->
</div><!-- /wrapper -->

<%-- Load Leaflet JS BEFORE Tabler so L is defined before any layout changes --%>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
<script>
(function() {
    const CTX  = '${pageContext.request.contextPath}';
    const ROLE = '${currentRole}';

    var map = null;
    var markers = {};

    function initMap() {
        map = L.map('map', { zoomControl: true }).setView([36.7372, 3.0926], 6);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
            maxZoom: 18
        }).addTo(map);

        // Tabler's flex layout shifts containers after DOMContentLoaded —
        // call invalidateSize multiple times to catch each reflow.
        setTimeout(function() { map.invalidateSize(); }, 100);
        setTimeout(function() { map.invalidateSize(); }, 500);
        setTimeout(function() { map.invalidateSize(); }, 1200);

        window.addEventListener('resize', function() { map.invalidateSize(); });

        fetchLocations();
        startCountdown();
    }

    function makeDriverIcon(name) {
        var initials = '?';
        if (name) {
            var parts = name.trim().split(/\s+/);
            initials = parts.map(function(p) { return p[0] || ''; }).slice(0, 2).join('').toUpperCase();
        }
        return L.divIcon({
            className: '',
            html: '<div style="width:38px;height:38px;border-radius:50%;background:#e94560;color:#fff;' +
                  'display:flex;align-items:center;justify-content:center;font-weight:700;font-size:.73rem;' +
                  'border:3px solid #fff;box-shadow:0 2px 10px rgba(0,0,0,.4)">' + initials + '</div>',
            iconSize:    [38, 38],
            iconAnchor:  [19, 19],
            popupAnchor: [0, -22]
        });
    }

    function fetchLocations() {
        fetch(CTX + '/app/api/locations/all')
            .then(function(r) { return r.json(); })
            .then(function(locations) {
                var count = document.getElementById('driver-count');
                if (count) count.textContent = locations.length;

                locations.forEach(function(loc) {
                    var latlng = [loc.lat, loc.lng];
                    var popup  =
                        '<div class="fw-bold mb-1"><i class="fa-solid fa-user me-1"></i>' + escHtml(loc.name) + '</div>' +
                        '<small class="text-muted"><i class="fa-solid fa-clock me-1"></i>' + formatDate(loc.updatedAt) + '</small>';

                    if (markers[loc.driverId]) {
                        markers[loc.driverId].setLatLng(latlng).setPopupContent(popup);
                    } else {
                        markers[loc.driverId] = L.marker(latlng, { icon: makeDriverIcon(loc.name) })
                            .bindPopup(popup)
                            .addTo(map);
                    }
                });
            })
            .catch(function() { console.warn('[SafeDrive] Échec récupération positions'); });
    }

    var seconds = 10;
    function startCountdown() {
        setInterval(function() {
            seconds--;
            var el = document.getElementById('countdown');
            if (el) el.textContent = seconds;
            if (seconds <= 0) {
                seconds = 10;
                fetchLocations();
            }
        }, 1000);
    }

    // GPS upload for drivers
    if (ROLE === 'DRIVER' && navigator.geolocation) {
        navigator.geolocation.watchPosition(
            function(pos) {
                fetch(CTX + '/app/api/locations/update', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ lat: pos.coords.latitude, lng: pos.coords.longitude })
                });
            },
            function(err) { console.warn('[SafeDrive] Géolocalisation refusée', err); },
            { enableHighAccuracy: true, timeout: 10000 }
        );
    }

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    function formatDate(iso) {
        try { return new Date(iso).toLocaleString('fr-FR'); } catch(e) { return iso || ''; }
    }

    // Wait for DOM ready so the #map div has been painted by the browser
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initMap);
    } else {
        initMap();
    }
})();
</script>
</body>
</html>
