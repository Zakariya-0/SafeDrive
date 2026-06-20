<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Chauffeurs</title>
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
              <li class="breadcrumb-item active">Chauffeurs</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-id-badge me-2 text-danger"></i>Gestion des Chauffeurs
            </h2>
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

        <!-- ── Stat cards ── -->
        <div class="row row-deck row-cards mb-4">
          <div class="col-md-4">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Total chauffeurs</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${chauffeurs.size()}</div>
                  </div>
                  <span class="avatar bg-red text-white rounded ms-3">
                    <i class="fa-solid fa-users"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Chauffeurs assignés</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${assignedCount}</div>
                  </div>
                  <span class="avatar bg-green text-white rounded ms-3">
                    <i class="fa-solid fa-user-check"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card stat-card">
              <div class="card-body">
                <div class="d-flex align-items-start">
                  <div class="flex-grow-1">
                    <div class="text-muted mb-1" style="font-size:.78rem;text-transform:uppercase;letter-spacing:.04em">Véhicules disponibles</div>
                    <div class="fw-bold" style="font-size:2rem;line-height:1">${vehiclesDispo.size()}</div>
                  </div>
                  <span class="avatar bg-yellow text-white rounded ms-3">
                    <i class="fa-solid fa-car"></i>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ── Drivers table ── -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <i class="fa-solid fa-list me-2 text-muted"></i>Liste des chauffeurs
            </h3>
            <div class="card-options ms-auto">
              <div class="input-group input-group-sm">
                <span class="input-group-text"><i class="fa-solid fa-magnifying-glass"></i></span>
                <input type="text" id="tableSearch" class="form-control" placeholder="Rechercher..." style="width:200px">
              </div>
            </div>
          </div>

          <div class="table-responsive">
            <table class="table table-vcenter card-table table-hover" id="chauffeursTable">
              <thead>
                <tr>
                  <th>Chauffeur</th>
                  <th>Email</th>
                  <th>Téléphone</th>
                  <th>Véhicule assigné</th>
                  <th class="text-center">Accidents</th>
                  <th style="width:180px">Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="u" items="${chauffeurs}">
                <tr>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <span class="avatar avatar-sm rounded-circle bg-green text-white"
                            style="font-size:.72rem">
                        ${u.firstName.substring(0,1)}${u.lastName.substring(0,1)}
                      </span>
                      <div>
                        <div class="fw-semibold">${u.firstName} ${u.lastName}</div>
                        <div class="text-muted small">${u.username}</div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <a href="mailto:${u.email}" class="text-reset">${u.email}</a>
                  </td>
                  <td class="text-muted">${not empty u.phone ? u.phone : '—'}</td>
                  <td>
                    <c:choose>
                      <c:when test="${u.assignedVehicle != null}">
                        <span class="badge bg-red-lt text-red">
                          <i class="fa-solid fa-car me-1"></i>
                          ${u.assignedVehicle.registrationNumber} — ${u.assignedVehicle.brand} ${u.assignedVehicle.model}
                        </span>
                      </c:when>
                      <c:otherwise>
                        <span class="text-muted fst-italic">Aucun véhicule</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="text-center">
                    <span class="badge ${accidentCounts[u.id] > 0 ? 'bg-yellow' : 'bg-secondary'} text-white">
                      <i class="fa-solid fa-triangle-exclamation me-1"></i>${accidentCounts[u.id]}
                    </span>
                  </td>
                  <td>
                    <div class="d-flex gap-2">
                      <button class="btn btn-sm btn-danger"
                              data-bs-toggle="modal"
                              data-bs-target="#modalAttribuer"
                              data-chauffeur-id="${u.id}"
                              data-chauffeur-nom="${u.firstName} ${u.lastName}">
                        <i class="fa-solid fa-car me-1"></i>
                        ${u.assignedVehicle != null ? 'Changer' : 'Attribuer'}
                      </button>
                      <c:if test="${u.assignedVehicle != null}">
                      <form method="post" class="m-0"
                            onsubmit="return confirm('Désassigner ${u.firstName} ${u.lastName} de son véhicule ?')">
                        <input type="hidden" name="action"    value="unassign">
                        <input type="hidden" name="vehicleId" value="${u.assignedVehicle.id}">
                        <button type="submit" class="btn btn-sm btn-ghost-danger" title="Désassigner">
                          <i class="fa-solid fa-user-minus me-1"></i>Retirer
                        </button>
                      </form>
                      </c:if>
                    </div>
                  </td>
                </tr>
                </c:forEach>
                <c:if test="${empty chauffeurs}">
                <tr>
                  <td colspan="6" class="text-center text-muted py-5">
                    <i class="fa-solid fa-users fa-2x mb-2 d-block"></i>Aucun chauffeur enregistré
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

<!-- ── Modal: Attribuer un véhicule ── -->
<div class="modal modal-blur fade" id="modalAttribuer" tabindex="-1"
     role="dialog" aria-labelledby="modalAttribuerLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <form method="post" id="formAttribuer">
        <input type="hidden" name="action"      value="assign">
        <input type="hidden" name="chauffeurId" id="modalChauffeurId">
        <div class="modal-header">
          <h5 class="modal-title" id="modalAttribuerLabel">
            <i class="fa-solid fa-car-side me-2 text-danger"></i>Attribuer un véhicule
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fermer"></button>
        </div>
        <div class="modal-body">
          <p class="text-muted mb-3">
            <i class="fa-solid fa-user me-1"></i>Sélectionner un véhicule pour
            <strong id="modalChauffeurNom"></strong>
          </p>
          <c:choose>
            <c:when test="${empty vehiclesDispo}">
              <div class="alert alert-warning mb-0">
                <i class="fa-solid fa-circle-exclamation me-2"></i>
                Aucun véhicule disponible sans chauffeur assigné.
              </div>
            </c:when>
            <c:otherwise>
              <label class="form-label fw-semibold required">Véhicule disponible</label>
              <select name="vehicleId" class="form-select" required>
                <option value="">— Choisir un véhicule —</option>
                <c:forEach var="v" items="${vehiclesDispo}">
                <option value="${v.id}">
                  ${v.registrationNumber} — ${v.brand} ${v.model} (${v.year})
                </option>
                </c:forEach>
              </select>
            </c:otherwise>
          </c:choose>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-ghost-secondary" data-bs-dismiss="modal">
            <i class="fa-solid fa-xmark me-1"></i>Annuler
          </button>
          <c:if test="${not empty vehiclesDispo}">
          <button type="submit" class="btn btn-danger">
            <i class="fa-solid fa-check me-1"></i>Attribuer
          </button>
          </c:if>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
<script>
document.getElementById('modalAttribuer').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    document.getElementById('modalChauffeurId').value  = btn.getAttribute('data-chauffeur-id');
    document.getElementById('modalChauffeurNom').textContent = btn.getAttribute('data-chauffeur-nom');
    const sel = document.querySelector('#formAttribuer select[name="vehicleId"]');
    if (sel) sel.selectedIndex = 0;
});

(function() {
    var searchInput = document.getElementById('tableSearch');
    var table       = document.getElementById('chauffeursTable');
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
