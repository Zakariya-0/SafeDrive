<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Accidents</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/css/tabler.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
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
              <li class="breadcrumb-item active">Accidents</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-triangle-exclamation me-2 text-danger"></i>Déclaration d'Accidents
            </h2>
          </div>
          <div class="col-auto ms-auto">
            <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#modalAccident">
              <i class="fa-solid fa-plus me-2"></i>Déclarer un accident
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="page-body">
      <div class="container-xl">

        <!-- Flash messages -->
        <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible mb-3" role="alert">
          <i class="fa-solid fa-circle-check me-2"></i>${success}
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        </c:if>

        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <i class="fa-solid fa-list me-2 text-muted"></i>Liste des accidents
            </h3>
            <div class="card-options ms-auto">
              <!-- Search -->
              <div class="input-group input-group-sm">
                <span class="input-group-text">
                  <i class="fa-solid fa-magnifying-glass"></i>
                </span>
                <input type="text" id="tableSearch" class="form-control" placeholder="Rechercher..." style="width:200px">
              </div>
            </div>
          </div>

          <div class="table-responsive">
            <table class="table table-vcenter card-table table-hover" id="accidentsTable">
              <thead>
                <tr>
                  <th style="width:50px">#</th>
                  <c:if test="${currentRole != 'DRIVER'}"><th>Chauffeur</th></c:if>
                  <th>Véhicule</th>
                  <th>Date</th>
                  <th>Lieu</th>
                  <th>Sévérité</th>
                  <th>Statut</th>
                  <th style="width:160px">Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="a" items="${accidents}">
                <tr>
                  <td class="text-muted">${a.id}</td>
                  <c:if test="${currentRole != 'DRIVER'}">
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <span class="avatar avatar-xs bg-red-lt text-red rounded-circle">
                        <i class="fa-solid fa-user fa-xs"></i>
                      </span>
                      ${a.driver.firstName} ${a.driver.lastName}
                    </div>
                  </td>
                  </c:if>
                  <td>
                    <div class="fw-semibold">${a.vehicle.brand} ${a.vehicle.model}</div>
                    <div class="text-muted small">${a.vehicle.registrationNumber}</div>
                  </td>
                  <td>${a.date}</td>
                  <td>${a.location}</td>
                  <td>
                    <span class="badge ${a.severity == 'SEVERE' ? 'bg-red' : a.severity == 'MODERATE' ? 'bg-yellow' : 'bg-green'} text-white">
                      <c:choose>
                        <c:when test="${a.severity == 'SEVERE'}"><i class="fa-solid fa-circle-exclamation me-1"></i>Grave</c:when>
                        <c:when test="${a.severity == 'MODERATE'}"><i class="fa-solid fa-circle-minus me-1"></i>Modéré</c:when>
                        <c:otherwise><i class="fa-solid fa-circle-check me-1"></i>Mineur</c:otherwise>
                      </c:choose>
                    </span>
                  </td>
                  <td>
                    <span class="badge ${a.status == 'DECLARED' ? 'bg-secondary' : a.status == 'UNDER_REVIEW' ? 'bg-azure' : 'bg-green'} text-white">
                      <c:choose>
                        <c:when test="${a.status == 'DECLARED'}">Déclaré</c:when>
                        <c:when test="${a.status == 'UNDER_REVIEW'}">En révision</c:when>
                        <c:otherwise>Résolu</c:otherwise>
                      </c:choose>
                    </span>
                  </td>
                  <td>
                    <div class="d-flex gap-1 flex-wrap">
                      <a href="?action=detail&id=${a.id}"
                         class="btn btn-sm btn-ghost-primary" title="Voir le détail">
                        <i class="fa-solid fa-eye"></i>
                      </a>
                      <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
                      <div class="dropdown d-inline">
                        <button class="btn btn-sm btn-ghost-secondary dropdown-toggle" data-bs-toggle="dropdown" title="Changer le statut">
                          <i class="fa-solid fa-sliders"></i>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                          <li><h6 class="dropdown-header">Changer le statut</h6></li>
                          <li><a class="dropdown-item" href="?action=updateStatus&id=${a.id}&status=DECLARED">
                            <i class="fa-solid fa-file-circle-plus me-2 text-secondary"></i>Déclaré</a></li>
                          <li><a class="dropdown-item" href="?action=updateStatus&id=${a.id}&status=UNDER_REVIEW">
                            <i class="fa-solid fa-magnifying-glass me-2 text-azure"></i>En révision</a></li>
                          <li><a class="dropdown-item" href="?action=updateStatus&id=${a.id}&status=RESOLVED">
                            <i class="fa-solid fa-circle-check me-2 text-green"></i>Résolu</a></li>
                        </ul>
                      </div>
                      </c:if>
                      <c:if test="${currentRole == 'ADMIN'}">
                      <a href="?action=delete&id=${a.id}"
                         onclick="return confirm('Supprimer cet accident définitivement ?')"
                         class="btn btn-sm btn-ghost-danger" title="Supprimer">
                        <i class="fa-solid fa-trash"></i>
                      </a>
                      </c:if>
                    </div>
                  </td>
                </tr>
                </c:forEach>
                <c:if test="${empty accidents}">
                <tr>
                  <td colspan="8" class="text-center text-muted py-5">
                    <i class="fa-solid fa-inbox fa-2x mb-2 d-block"></i>Aucun accident enregistré
                  </td>
                </tr>
                </c:if>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <div class="card-footer d-flex align-items-center justify-content-between">
            <p class="m-0 text-muted" id="pagination-info"></p>
            <ul class="pagination m-0" id="pagination-controls"></ul>
          </div>
        </div>

      </div>
    </div>
  </div><!-- /page-wrapper -->
</div><!-- /wrapper -->

<!-- ── Modal: Déclarer un accident ── -->
<div class="modal modal-blur fade" id="modalAccident" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      <form method="post"
            action="${pageContext.request.contextPath}/app/accidents"
            enctype="multipart/form-data">
        <input type="hidden" name="action" value="declare">
        <div class="modal-header">
          <h5 class="modal-title">
            <i class="fa-solid fa-triangle-exclamation text-danger me-2"></i>Déclarer un accident
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fermer"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">

            <!-- Driver select (ADMIN/MANAGER) -->
            <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
            <div class="col-md-6">
              <label class="form-label required">
                <i class="fa-solid fa-user me-1 text-muted"></i>Chauffeur
              </label>
              <select name="driverId" class="form-select" required>
                <option value="">— Sélectionner un chauffeur —</option>
                <c:forEach var="d" items="${drivers}">
                <option value="${d.id}">${d.firstName} ${d.lastName}</option>
                </c:forEach>
              </select>
            </div>
            </c:if>

            <!-- Vehicle -->
            <div class="col-md-6">
              <label class="form-label required">
                <i class="fa-solid fa-car me-1 text-muted"></i>Véhicule
              </label>
              <c:choose>
                <c:when test="${currentRole == 'DRIVER'}">
                  <c:choose>
                    <c:when test="${chauffeurVehicle != null}">
                      <input type="hidden" name="vehicleId" value="${chauffeurVehicle.id}">
                      <div class="form-control-plaintext fw-semibold">
                        <i class="fa-solid fa-car me-1 text-muted"></i>
                        ${chauffeurVehicle.brand} ${chauffeurVehicle.model}
                        <small class="text-muted">(${chauffeurVehicle.registrationNumber})</small>
                      </div>
                    </c:when>
                    <c:otherwise>
                      <div class="alert alert-warning py-2 mb-0">
                        <i class="fa-solid fa-circle-exclamation me-1"></i>
                        Aucun véhicule assigné. Contactez votre manager.
                      </div>
                    </c:otherwise>
                  </c:choose>
                </c:when>
                <c:otherwise>
                  <select name="vehicleId" class="form-select" required>
                    <option value="">— Sélectionner un véhicule —</option>
                    <c:forEach var="v" items="${vehicles}">
                    <option value="${v.id}">${v.registrationNumber} — ${v.brand} ${v.model}</option>
                    </c:forEach>
                  </select>
                </c:otherwise>
              </c:choose>
            </div>

            <!-- Date -->
            <div class="col-md-6">
              <label class="form-label required">
                <i class="fa-solid fa-calendar me-1 text-muted"></i>Date de l'accident
              </label>
              <input type="date" name="date" class="form-control" required>
            </div>

            <!-- Severity -->
            <div class="col-md-6">
              <label class="form-label required">
                <i class="fa-solid fa-gauge me-1 text-muted"></i>Sévérité
              </label>
              <select name="severity" class="form-select" required>
                <option value="MINOR">Mineur</option>
                <option value="MODERATE">Modéré</option>
                <option value="SEVERE">Grave</option>
              </select>
            </div>

            <!-- Location -->
            <div class="col-12">
              <label class="form-label">
                <i class="fa-solid fa-map-pin me-1 text-muted"></i>Lieu
              </label>
              <input type="text" name="location" class="form-control"
                     placeholder="Ex: Autoroute A1, km 45, Alger">
            </div>

            <!-- Description -->
            <div class="col-12">
              <label class="form-label">
                <i class="fa-solid fa-align-left me-1 text-muted"></i>Description
              </label>
              <textarea name="description" class="form-control" rows="3"
                        placeholder="Décrivez les circonstances de l'accident..."></textarea>
            </div>

            <!-- Photo upload with preview -->
            <div class="col-12">
              <label class="form-label">
                <i class="fa-solid fa-camera me-1 text-muted"></i>Photo de l'accident
                <small class="text-muted ms-1">(optionnel — analyse IA automatique)</small>
              </label>
              <input type="file" name="image" id="accidentPhoto" class="form-control" accept="image/*">
              <div class="form-text">
                <i class="fa-solid fa-robot me-1"></i>
                Joindre une photo pour la classification automatique par intelligence artificielle.
              </div>
              <div id="photo-preview-container" class="mt-2 d-none">
                <img id="img-preview" src="" alt="Aperçu" class="d-block">
              </div>
            </div>

            <!-- Map picker -->
            <div class="col-12">
              <label class="form-label">
                <i class="fa-solid fa-location-crosshairs me-1 text-muted"></i>Localisation GPS
                <small class="text-muted">(cliquer sur la carte pour placer le marqueur)</small>
              </label>
              <div class="mb-2">
                <button type="button" class="btn btn-sm btn-outline-primary" id="gps-btn">
                  <i class="fa-solid fa-crosshairs me-1"></i>Ma position GPS
                </button>
              </div>
              <div id="picker-map" style="height:300px;width:100%;border-radius:.5rem;border:1px solid var(--tblr-border-color);cursor:crosshair;"></div>
              <input type="hidden" name="latitude"  id="latitude">
              <input type="hidden" name="longitude" id="longitude">
              <small id="coords-display" class="text-muted mt-1 d-block">
                <i class="fa-solid fa-circle-info me-1"></i>Aucune position sélectionnée
              </small>
            </div>

          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-ghost-secondary" data-bs-dismiss="modal">
            <i class="fa-solid fa-xmark me-1"></i>Annuler
          </button>
          <c:choose>
            <c:when test="${currentRole == 'DRIVER' && chauffeurVehicle == null}">
              <button type="submit" class="btn btn-danger" disabled>
                <i class="fa-solid fa-paper-plane me-1"></i>Déclarer
              </button>
            </c:when>
            <c:otherwise>
              <button type="submit" class="btn btn-danger">
                <i class="fa-solid fa-paper-plane me-1"></i>Déclarer
              </button>
            </c:otherwise>
          </c:choose>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
<script>
(function() {
    // ── Map picker ──
    var pickerMap, pickerMarker;

    function setPickerPosition(latlng) {
        var lat = latlng.lat.toFixed(6), lng = latlng.lng.toFixed(6);
        document.getElementById('latitude').value  = lat;
        document.getElementById('longitude').value = lng;
        document.getElementById('coords-display').innerHTML =
            '<i class="fa-solid fa-location-dot me-1 text-danger"></i>Position : ' + lat + ', ' + lng;
        if (pickerMarker) pickerMarker.setLatLng(latlng);
        else pickerMarker = L.marker(latlng).addTo(pickerMap);
        pickerMap.panTo(latlng);
    }

    document.getElementById('modalAccident').addEventListener('shown.bs.modal', function() {
        if (!pickerMap) {
            pickerMap = L.map('picker-map').setView([36.7372, 3.0926], 5);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a>', maxZoom: 18
            }).addTo(pickerMap);
            pickerMap.on('click', function(e) { setPickerPosition(e.latlng); });
            // Tabler modal shifts layout — call multiple times to ensure correct tile render
            setTimeout(function() { pickerMap.invalidateSize(); }, 150);
            setTimeout(function() { pickerMap.invalidateSize(); }, 400);
        } else {
            pickerMap.invalidateSize();
        }
    });

    document.getElementById('modalAccident').addEventListener('hidden.bs.modal', function() {
        document.getElementById('latitude').value  = '';
        document.getElementById('longitude').value = '';
        document.getElementById('coords-display').innerHTML =
            '<i class="fa-solid fa-circle-info me-1"></i>Aucune position sélectionnée';
        if (pickerMarker) { pickerMarker.remove(); pickerMarker = null; }
    });

    // ── GPS auto-fill ──
    var gpsBtn = document.getElementById('gps-btn');
    if (gpsBtn) {
        gpsBtn.addEventListener('click', function() {
            if (!navigator.geolocation) {
                alert('La géolocalisation n\'est pas supportée par ce navigateur.');
                return;
            }
            gpsBtn.disabled = true;
            gpsBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i>Localisation...';
            navigator.geolocation.getCurrentPosition(
                function(pos) {
                    gpsBtn.disabled = false;
                    gpsBtn.innerHTML = '<i class="fa-solid fa-crosshairs me-1"></i>Ma position GPS';
                    var latlng = L.latLng(pos.coords.latitude, pos.coords.longitude);
                    setPickerPosition(latlng);
                    pickerMap.setView(latlng, 14);
                },
                function() {
                    gpsBtn.disabled = false;
                    gpsBtn.innerHTML = '<i class="fa-solid fa-crosshairs me-1"></i>Ma position GPS';
                    alert('Impossible d\'obtenir la position GPS. Vérifiez les permissions du navigateur.');
                },
                { enableHighAccuracy: true, timeout: 10000 }
            );
        });
    }

    // ── Photo preview ──
    var photoInput = document.getElementById('accidentPhoto');
    if (photoInput) {
        photoInput.addEventListener('change', function() {
            var file = this.files[0];
            var container = document.getElementById('photo-preview-container');
            var preview   = document.getElementById('img-preview');
            if (file && file.type.startsWith('image/')) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    container.classList.remove('d-none');
                };
                reader.readAsDataURL(file);
            } else {
                container.classList.add('d-none');
                preview.src = '';
            }
        });
    }

    // ── Table search ──
    var searchInput = document.getElementById('tableSearch');
    var table       = document.getElementById('accidentsTable');
    var rowsPerPage = 10;
    var currentPage = 1;
    var allRows     = [];

    function getRows() {
        return Array.from(table.querySelectorAll('tbody tr')).filter(function(r) {
            return !r.querySelector('td[colspan]');
        });
    }

    function filterRows() {
        var q = searchInput ? searchInput.value.toLowerCase() : '';
        allRows = getRows().filter(function(r) {
            return q === '' || r.textContent.toLowerCase().includes(q);
        });
        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        var start  = (currentPage - 1) * rowsPerPage;
        var end    = start + rowsPerPage;
        var total  = allRows.length;
        getRows().forEach(function(r) { r.style.display = 'none'; });
        allRows.slice(start, end).forEach(function(r) { r.style.display = ''; });

        var info = document.getElementById('pagination-info');
        var ctrl = document.getElementById('pagination-controls');
        if (info) info.textContent = total > 0 ?
            'Affichage ' + (Math.min(start + 1, total)) + '–' + Math.min(end, total) + ' sur ' + total + ' résultats' : 'Aucun résultat';

        if (!ctrl) return;
        var pages = Math.ceil(total / rowsPerPage);
        var html  = '';
        html += '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
                '<a class="page-link" onclick="goPage(' + (currentPage - 1) + ')">' +
                '<i class="fa-solid fa-chevron-left fa-xs"></i></a></li>';
        for (var p = 1; p <= pages; p++) {
            html += '<li class="page-item ' + (p === currentPage ? 'active' : '') + '">' +
                    '<a class="page-link" onclick="goPage(' + p + ')">' + p + '</a></li>';
        }
        html += '<li class="page-item ' + (currentPage === pages || pages === 0 ? 'disabled' : '') + '">' +
                '<a class="page-link" onclick="goPage(' + (currentPage + 1) + ')">' +
                '<i class="fa-solid fa-chevron-right fa-xs"></i></a></li>';
        ctrl.innerHTML = html;
    }

    window.goPage = function(p) {
        var pages = Math.ceil(allRows.length / rowsPerPage);
        if (p < 1 || p > pages) return;
        currentPage = p;
        renderPage();
    };

    if (searchInput) searchInput.addEventListener('input', filterRows);
    document.addEventListener('DOMContentLoaded', filterRows);
})();
</script>
</body>
</html>
