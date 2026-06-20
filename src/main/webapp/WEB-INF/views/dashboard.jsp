<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Tableau de bord</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/css/tabler.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <%-- Leaflet CSS must be in <head> --%>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
  <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
  <style>
    /* Explicit pixel height — never rely on calc() inside a Tabler flex container */
    #accident-map { height: 450px; width: 100%; }
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
              <li class="breadcrumb-item"><a href="#">SafeDrive</a></li>
              <li class="breadcrumb-item active">Tableau de bord</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-gauge-high me-2 text-danger"></i>Tableau de bord
            </h2>
          </div>
        </div>
      </div>
    </div>

    <div class="page-body">
      <div class="container-xl">

        <!-- ── Stat cards ── -->
        <div class="row row-deck row-cards mb-4">

          <div class="col-sm-6 col-xl-3">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Total Véhicules</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${totalVehicles}</div>
                  </div>
                  <span class="avatar bg-blue text-white rounded ms-3">
                    <i class="fa-solid fa-car"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div class="col-sm-6 col-xl-3">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Véhicules Disponibles</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${availableVehicles}</div>
                  </div>
                  <span class="avatar bg-green text-white rounded ms-3">
                    <i class="fa-solid fa-circle-check"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div class="col-sm-6 col-xl-3">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Total Accidents</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${totalAccidents}</div>
                  </div>
                  <span class="avatar bg-red text-white rounded ms-3">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div class="col-sm-6 col-xl-3">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Accidents en Attente</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${pendingAccidents}</div>
                  </div>
                  <span class="avatar bg-yellow text-white rounded ms-3">
                    <i class="fa-solid fa-clock"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
          <div class="col-sm-6 col-xl-3">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Utilisateurs</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${totalUsers}</div>
                  </div>
                  <span class="avatar bg-purple text-white rounded ms-3">
                    <i class="fa-solid fa-users"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div class="col-sm-6 col-xl-3">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Chauffeurs actifs</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${totalDrivers}</div>
                  </div>
                  <span class="avatar bg-azure text-white rounded ms-3">
                    <i class="fa-solid fa-id-badge"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div class="col-sm-6 col-xl-3">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">En Maintenance</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${maintenanceVehicles}</div>
                  </div>
                  <span class="avatar bg-orange text-white rounded ms-3">
                    <i class="fa-solid fa-wrench"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>
          </c:if>

        </div><!-- /row stat cards -->

        <!-- ── Accident map (ADMIN / MANAGER) ── -->
        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <div class="card mb-4">
          <div class="card-header">
            <h3 class="card-title">
              <i class="fa-solid fa-map-location-dot me-2 text-danger"></i>Carte des Accidents
            </h3>
            <div class="card-options ms-auto">
              <span class="badge bg-red-lt text-red me-1">
                <span style="width:8px;height:8px;border-radius:50%;background:#d63939;display:inline-block;margin-right:4px"></span>Grave
              </span>
              <span class="badge bg-yellow-lt text-yellow me-1">
                <span style="width:8px;height:8px;border-radius:50%;background:#f59f00;display:inline-block;margin-right:4px"></span>Modéré
              </span>
              <span class="badge bg-green-lt text-green">
                <span style="width:8px;height:8px;border-radius:50%;background:#2fb344;display:inline-block;margin-right:4px"></span>Mineur
              </span>
            </div>
          </div>
          <%-- p-0 so the map fills the card edge-to-edge; height set by inline style + CSS rule --%>
          <div class="card-body p-0" style="overflow:hidden; border-radius:0 0 .5rem .5rem;">
            <div id="accident-map"></div>
          </div>
        </div>
        </c:if>

        <!-- ── Recent accidents table ── -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <i class="fa-solid fa-clock-rotate-left me-2 text-muted"></i>Accidents Récents
            </h3>
          </div>
          <div class="table-responsive">
            <table class="table table-vcenter card-table table-hover">
              <thead>
                <tr>
                  <th>Chauffeur</th>
                  <th>Véhicule</th>
                  <th>Date</th>
                  <th>Lieu</th>
                  <th>Sévérité</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="a" items="${recentAccidents}">
                <tr>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <span class="avatar avatar-xs bg-red-lt text-red rounded-circle">
                        <i class="fa-solid fa-user fa-xs"></i>
                      </span>
                      ${a.driver.firstName} ${a.driver.lastName}
                    </div>
                  </td>
                  <td class="text-muted">${a.vehicle.brand} ${a.vehicle.model}</td>
                  <td>${a.date}</td>
                  <td>${a.location}</td>
                  <td>
                    <span class="badge text-white ${a.severity == 'SEVERE' ? 'bg-red' : a.severity == 'MODERATE' ? 'bg-yellow' : 'bg-green'}">
                      <c:choose>
                        <c:when test="${a.severity == 'SEVERE'}"><i class="fa-solid fa-circle-exclamation me-1"></i>Grave</c:when>
                        <c:when test="${a.severity == 'MODERATE'}"><i class="fa-solid fa-circle-minus me-1"></i>Modéré</c:when>
                        <c:otherwise><i class="fa-solid fa-circle-check me-1"></i>Mineur</c:otherwise>
                      </c:choose>
                    </span>
                  </td>
                  <td>
                    <span class="badge text-white ${a.status == 'DECLARED' ? 'bg-secondary' : a.status == 'UNDER_REVIEW' ? 'bg-azure' : 'bg-green'}">
                      <c:choose>
                        <c:when test="${a.status == 'DECLARED'}">Déclaré</c:when>
                        <c:when test="${a.status == 'UNDER_REVIEW'}">En révision</c:when>
                        <c:otherwise>Résolu</c:otherwise>
                      </c:choose>
                    </span>
                  </td>
                </tr>
                </c:forEach>
                <c:if test="${empty recentAccidents}">
                <tr>
                  <td colspan="6" class="text-center text-muted py-5">
                    <i class="fa-solid fa-inbox fa-2x mb-2 d-block"></i>Aucun accident enregistré
                  </td>
                </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>

      </div><!-- /container-xl -->
    </div><!-- /page-body -->
  </div><!-- /page-wrapper -->
</div><!-- /wrapper -->

<%-- Leaflet JS BEFORE Tabler JS — L must be defined before Tabler's layout events fire --%>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>

<c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
<script>
(function () {
    'use strict';

    // ── Build accident data with push() — avoids JSTL comma-in-array bugs ──
    var accidents = [];
    <c:forEach var="a" items="${mapAccidents}">
    <c:if test="${a.latitude != null && a.longitude != null}">
    accidents.push({
        lat:      ${a.latitude},
        lng:      ${a.longitude},
        severity: '<c:out value="${a.severity}"/>',
        date:     '<c:out value="${a.date}"/>',
        driver:   '<c:out value="${a.driver.firstName} ${a.driver.lastName}"/>',
        vehicle:  '<c:out value="${a.vehicle.brand} ${a.vehicle.model}"/>',
        location: '<c:out value="${a.location}"/>',
        id:       ${a.id}
    });
    </c:if>
    </c:forEach>

    var severityColor = {
        'SEVERE':   '#d63939',
        'MODERATE': '#f59f00',
        'MINOR':    '#2fb344'
    };
    var severityLabel = {
        'SEVERE':   'Grave',
        'MODERATE': 'Modéré',
        'MINOR':    'Mineur'
    };

    function initMap() {
        var mapEl = document.getElementById('accident-map');
        if (!mapEl) return;

        // Show empty state inline if no GPS data at all
        if (accidents.length === 0) {
            mapEl.innerHTML =
                '<div style="height:100%;display:flex;align-items:center;justify-content:center;' +
                'color:#6c757d;flex-direction:column;gap:.5rem;">' +
                '<i class="fa-solid fa-map-pin fa-2x"></i>' +
                '<span>Aucun accident géolocalisé</span>' +
                '<small>Déclarez des accidents avec une localisation sur la carte</small></div>';
            return;
        }

        var map = L.map('accident-map', { zoomControl: true }).setView([36.7372, 3.0926], 6);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
            maxZoom: 19
        }).addTo(map);

        // Tabler's flex layout reflows after DOMContentLoaded — call invalidateSize
        // multiple times to catch each stage of the sidebar/wrapper animation.
        setTimeout(function () { map.invalidateSize(); }, 150);
        setTimeout(function () { map.invalidateSize(); }, 500);
        setTimeout(function () { map.invalidateSize(); }, 1200);
        window.addEventListener('resize', function () { map.invalidateSize(); });

        var bounds = [];
        accidents.forEach(function (a) {
            var color = severityColor[a.severity] || '#6c757d';
            var label = severityLabel[a.severity] || a.severity;

            // Larger circle marker — more visible than the 14px dots
            var icon = L.divIcon({
                className: '',
                html: '<div style="' +
                      'width:18px;height:18px;border-radius:50%;' +
                      'background:' + color + ';' +
                      'border:3px solid #fff;' +
                      'box-shadow:0 2px 8px rgba(0,0,0,.45);' +
                      'cursor:pointer"></div>',
                iconSize:   [18, 18],
                iconAnchor: [9, 9]
            });

            var ctx = '${pageContext.request.contextPath}';
            var popup =
                '<div style="min-width:200px;font-family:inherit">' +
                '<div style="font-weight:600;margin-bottom:4px">' +
                '<i class="fa-solid fa-user me-1" style="color:#6c757d"></i>' + escHtml(a.driver) +
                '</div>' +
                '<div style="color:#6c757d;font-size:.85rem;margin-bottom:6px">' +
                '<i class="fa-solid fa-car me-1"></i>' + escHtml(a.vehicle) +
                '</div>' +
                '<div style="margin-bottom:4px;font-size:.85rem">' +
                '<i class="fa-solid fa-calendar me-1" style="color:#6c757d"></i>' + escHtml(a.date) +
                '</div>' +
                (a.location ? '<div style="margin-bottom:6px;font-size:.85rem">' +
                '<i class="fa-solid fa-location-dot me-1" style="color:#6c757d"></i>' + escHtml(a.location) +
                '</div>' : '') +
                '<span style="display:inline-block;padding:2px 8px;border-radius:4px;color:#fff;' +
                'background:' + color + ';font-size:.78rem;font-weight:600">' + label + '</span>' +
                '&nbsp;&nbsp;<a href="' + ctx + '/app/accidents?action=detail&id=' + a.id +
                '" style="font-size:.8rem">Voir détail →</a>' +
                '</div>';

            L.marker([a.lat, a.lng], { icon: icon })
             .bindPopup(popup, { maxWidth: 260 })
             .addTo(map);
            bounds.push([a.lat, a.lng]);
        });

        if (bounds.length > 0) {
            map.fitBounds(bounds, { padding: [40, 40], maxZoom: 13 });
        }
    }

    function escHtml(s) {
        return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }

    // Wait for full DOM — sidebar JS fires after DOMContentLoaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initMap);
    } else {
        initMap();
    }
})();
</script>
</c:if>
</body>
</html>
