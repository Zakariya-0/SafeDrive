<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Véhicules</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/css/tabler.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
              <li class="breadcrumb-item active">Véhicules</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-car me-2 text-danger"></i>Gestion des Véhicules
            </h2>
          </div>
          <div class="col-auto ms-auto">
            <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
            <button class="btn btn-danger"
                    data-bs-toggle="modal" data-bs-target="#modalVehicle"
                    data-mode="create">
              <i class="fa-solid fa-plus me-2"></i>Nouveau véhicule
            </button>
            </c:if>
          </div>
        </div>
      </div>
    </div>

    <div class="page-body">
      <div class="container-xl">

        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <i class="fa-solid fa-list me-2 text-muted"></i>Flotte de véhicules
            </h3>
            <div class="card-options ms-auto">
              <div class="input-group input-group-sm">
                <span class="input-group-text"><i class="fa-solid fa-magnifying-glass"></i></span>
                <input type="text" id="tableSearch" class="form-control" placeholder="Rechercher..." style="width:200px">
              </div>
            </div>
          </div>

          <div class="table-responsive">
            <table class="table table-vcenter card-table table-hover" id="vehiclesTable">
              <thead>
                <tr>
                  <th>Immatriculation</th>
                  <th>Marque / Modèle</th>
                  <th>Année</th>
                  <th>Kilométrage</th>
                  <th>Chauffeur assigné</th>
                  <th>Statut</th>
                  <th style="width:120px">Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="v" items="${vehicles}">
                <tr>
                  <td>
                    <span class="fw-bold text-danger">${v.registrationNumber}</span>
                  </td>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <span class="avatar avatar-xs bg-blue-lt text-blue rounded">
                        <i class="fa-solid fa-car fa-xs"></i>
                      </span>
                      <div>
                        <div class="fw-semibold">${v.brand} ${v.model}</div>
                      </div>
                    </div>
                  </td>
                  <td class="text-muted">${v.year}</td>
                  <td>
                    <div class="d-flex align-items-center gap-1">
                      <i class="fa-solid fa-gauge-simple fa-sm text-muted"></i>
                      ${v.mileage} km
                    </div>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${v.assignedDriver != null}">
                        <div class="d-flex align-items-center gap-2">
                          <span class="avatar avatar-xs bg-green-lt text-green rounded-circle">
                            <i class="fa-solid fa-user fa-xs"></i>
                          </span>
                          ${v.assignedDriver.firstName} ${v.assignedDriver.lastName}
                        </div>
                      </c:when>
                      <c:otherwise>
                        <span class="text-muted fst-italic">Non assigné</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <span class="badge text-white ${v.status == 'AVAILABLE' ? 'bg-green' : v.status == 'IN_USE' ? 'bg-blue' : v.status == 'MAINTENANCE' ? 'bg-yellow' : 'bg-secondary'}">
                      <c:choose>
                        <c:when test="${v.status == 'AVAILABLE'}"><i class="fa-solid fa-circle-check me-1"></i>Disponible</c:when>
                        <c:when test="${v.status == 'IN_USE'}"><i class="fa-solid fa-road me-1"></i>En service</c:when>
                        <c:when test="${v.status == 'MAINTENANCE'}"><i class="fa-solid fa-wrench me-1"></i>Maintenance</c:when>
                        <c:otherwise><i class="fa-solid fa-ban me-1"></i>Retiré</c:otherwise>
                      </c:choose>
                    </span>
                  </td>
                  <td>
                    <div class="d-flex gap-1">
                      <button type="button"
                         class="btn btn-sm btn-ghost-primary" title="Modifier"
                         data-bs-toggle="modal" data-bs-target="#modalVehicle"
                         data-mode="edit"
                         data-id="${v.id}"
                         data-brand="${v.brand}"
                         data-model="${v.model}"
                         data-year="${v.year}"
                         data-mileage="${v.mileage}"
                         data-status="${v.status}"
                         data-driverid="${v.assignedDriver != null ? v.assignedDriver.id : ''}">
                        <i class="fa-solid fa-pen"></i>
                      </button>
                      <c:if test="${currentRole == 'ADMIN'}">
                      <a href="?action=delete&id=${v.id}"
                         onclick="return confirm('Supprimer ce véhicule ?')"
                         class="btn btn-sm btn-ghost-danger" title="Supprimer">
                        <i class="fa-solid fa-trash"></i>
                      </a>
                      </c:if>
                    </div>
                  </td>
                </tr>
                </c:forEach>
                <c:if test="${empty vehicles}">
                <tr>
                  <td colspan="7" class="text-center text-muted py-5">
                    <i class="fa-solid fa-car-burst fa-2x mb-2 d-block"></i>Aucun véhicule enregistré
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
  </div>
</div>

<!-- ── Modal: Créer / Modifier véhicule ── -->
<div class="modal modal-blur fade" id="modalVehicle" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <form method="post" id="vehicleForm">
        <input type="hidden" name="id"     id="vehicleFormId"     value="">
        <input type="hidden" name="action" id="vehicleFormAction" value="create">
        <div class="modal-header">
          <h5 class="modal-title">
            <i class="fa-solid fa-car me-2 text-danger"></i>
            <span id="vehicleModalTitle">Nouveau véhicule</span>
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fermer"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">

            <div class="col-12" id="vehicleRegWrap">
              <label class="form-label required">Immatriculation</label>
              <input type="text" name="registrationNumber" id="vehicleReg" class="form-control"
                     placeholder="Ex: 100-A-123">
            </div>

            <div class="col-6">
              <label class="form-label required">Marque</label>
              <input type="text" name="brand" id="vehicleBrand" class="form-control"
                     placeholder="Ex: Toyota" required>
            </div>
            <div class="col-6">
              <label class="form-label required">Modèle</label>
              <input type="text" name="model" id="vehicleModel" class="form-control"
                     placeholder="Ex: Hilux" required>
            </div>
            <div class="col-6">
              <label class="form-label required">Année</label>
              <input type="number" name="year" id="vehicleYear" class="form-control"
                     min="1990" max="2030" required>
            </div>
            <div class="col-6">
              <label class="form-label">Kilométrage</label>
              <div class="input-group">
                <input type="number" name="mileage" id="vehicleMileage" class="form-control"
                       min="0" placeholder="0">
                <span class="input-group-text">km</span>
              </div>
            </div>

            <div class="col-6" id="vehicleStatusWrap">
              <label class="form-label">Statut</label>
              <select name="status" id="vehicleStatus" class="form-select">
                <option value="AVAILABLE">Disponible</option>
                <option value="IN_USE">En service</option>
                <option value="MAINTENANCE">Maintenance</option>
                <option value="RETIRED">Retiré</option>
              </select>
            </div>
            <div class="col-6" id="vehicleDriverWrap">
              <label class="form-label">Chauffeur assigné</label>
              <select name="assignedDriverId" id="vehicleDriver" class="form-select">
                <option value="">— Aucun —</option>
                <c:forEach var="d" items="${drivers}">
                <option value="${d.id}">${d.firstName} ${d.lastName}</option>
                </c:forEach>
              </select>
            </div>

          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-ghost-secondary" data-bs-dismiss="modal">
            <i class="fa-solid fa-xmark me-1"></i>Annuler
          </button>
          <button type="submit" class="btn btn-danger">
            <i class="fa-solid fa-floppy-disk me-1"></i>Enregistrer
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
<script>
document.getElementById('modalVehicle').addEventListener('show.bs.modal', function(event) {
    var trigger = event.relatedTarget;
    var mode    = trigger ? trigger.dataset.mode : 'create';

    if (mode === 'edit') {
        document.getElementById('vehicleModalTitle').textContent       = 'Modifier le véhicule';
        document.getElementById('vehicleFormAction').value             = 'update';
        document.getElementById('vehicleFormId').value                 = trigger.dataset.id;
        document.getElementById('vehicleBrand').value                  = trigger.dataset.brand;
        document.getElementById('vehicleModel').value                  = trigger.dataset.model;
        document.getElementById('vehicleYear').value                   = trigger.dataset.year;
        document.getElementById('vehicleMileage').value                = trigger.dataset.mileage;
        document.getElementById('vehicleReg').required                 = false;
        document.getElementById('vehicleRegWrap').style.display        = 'none';
        document.getElementById('vehicleStatusWrap').style.display     = '';
        document.getElementById('vehicleDriverWrap').style.display     = '';
        document.getElementById('vehicleStatus').value                 = trigger.dataset.status;
        document.getElementById('vehicleDriver').value                 = trigger.dataset.driverid || '';
    } else {
        document.getElementById('vehicleModalTitle').textContent       = 'Nouveau véhicule';
        document.getElementById('vehicleFormAction').value             = 'create';
        document.getElementById('vehicleFormId').value                 = '';
        document.getElementById('vehicleBrand').value                  = '';
        document.getElementById('vehicleModel').value                  = '';
        document.getElementById('vehicleYear').value                   = '';
        document.getElementById('vehicleMileage').value                = '';
        document.getElementById('vehicleReg').value                    = '';
        document.getElementById('vehicleReg').required                 = true;
        document.getElementById('vehicleRegWrap').style.display        = '';
        document.getElementById('vehicleStatusWrap').style.display     = 'none';
        document.getElementById('vehicleDriverWrap').style.display     = 'none';
    }
});
</script>
<script>
(function() {
    var searchInput = document.getElementById('tableSearch');
    var table       = document.getElementById('vehiclesTable');
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
        var start = (currentPage - 1) * rowsPerPage;
        var end   = start + rowsPerPage;
        var total = allRows.length;
        getRows().forEach(function(r) { r.style.display = 'none'; });
        allRows.slice(start, end).forEach(function(r) { r.style.display = ''; });

        var info = document.getElementById('pagination-info');
        var ctrl = document.getElementById('pagination-controls');
        if (info) info.textContent = total > 0 ?
            'Affichage ' + Math.min(start + 1, total) + '–' + Math.min(end, total) + ' sur ' + total : 'Aucun résultat';

        if (!ctrl) return;
        var pages = Math.ceil(total / rowsPerPage);
        var html  = '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') +
                    '"><a class="page-link" onclick="goPage(' + (currentPage - 1) + ')">' +
                    '<i class="fa-solid fa-chevron-left fa-xs"></i></a></li>';
        for (var p = 1; p <= pages; p++) {
            html += '<li class="page-item ' + (p === currentPage ? 'active' : '') +
                    '"><a class="page-link" onclick="goPage(' + p + ')">' + p + '</a></li>';
        }
        html += '<li class="page-item ' + (currentPage === pages || pages === 0 ? 'disabled' : '') +
                '"><a class="page-link" onclick="goPage(' + (currentPage + 1) + ')">' +
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
