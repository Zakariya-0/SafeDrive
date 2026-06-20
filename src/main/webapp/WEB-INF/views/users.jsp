<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Utilisateurs</title>
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
              <li class="breadcrumb-item active">Utilisateurs</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-users-gear me-2 text-danger"></i>Gestion des Utilisateurs
            </h2>
          </div>
          <div class="col-auto ms-auto">
            <button class="btn btn-danger"
                    data-bs-toggle="modal" data-bs-target="#modalUser"
                    data-mode="create">
              <i class="fa-solid fa-user-plus me-2"></i>Nouvel utilisateur
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="page-body">
      <div class="container-xl">

        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <i class="fa-solid fa-list me-2 text-muted"></i>Liste des utilisateurs
            </h3>
            <div class="card-options ms-auto">
              <div class="input-group input-group-sm">
                <span class="input-group-text"><i class="fa-solid fa-magnifying-glass"></i></span>
                <input type="text" id="tableSearch" class="form-control" placeholder="Rechercher..." style="width:200px">
              </div>
            </div>
          </div>

          <div class="table-responsive">
            <table class="table table-vcenter card-table table-hover" id="usersTable">
              <thead>
                <tr>
                  <th style="width:50px">#</th>
                  <th>Nom complet</th>
                  <th>Identifiant</th>
                  <th>Email</th>
                  <th>Téléphone</th>
                  <th>Rôle</th>
                  <th>Statut</th>
                  <th style="width:160px">Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="u" items="${users}">
                <tr>
                  <td class="text-muted">${u.id}</td>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <span class="avatar avatar-sm rounded-circle ${u.role == 'ADMIN' ? 'bg-red' : u.role == 'MANAGER' ? 'bg-blue' : 'bg-green'} text-white" style="font-size:.75rem">
                        ${u.firstName.substring(0,1)}${u.lastName.substring(0,1)}
                      </span>
                      <div>
                        <div class="fw-semibold">${u.firstName} ${u.lastName}</div>
                      </div>
                    </div>
                  </td>
                  <td class="text-muted">${u.username}</td>
                  <td>
                    <a href="mailto:${u.email}" class="text-reset">${u.email}</a>
                  </td>
                  <td class="text-muted">${not empty u.phone ? u.phone : '—'}</td>
                  <td>
                    <span class="badge text-white ${u.role == 'ADMIN' ? 'bg-red' : u.role == 'MANAGER' ? 'bg-blue' : 'bg-green'}">
                      <c:choose>
                        <c:when test="${u.role == 'ADMIN'}"><i class="fa-solid fa-shield-halved me-1"></i>Admin</c:when>
                        <c:when test="${u.role == 'MANAGER'}"><i class="fa-solid fa-briefcase me-1"></i>Manager</c:when>
                        <c:otherwise><i class="fa-solid fa-id-badge me-1"></i>Chauffeur</c:otherwise>
                      </c:choose>
                    </span>
                  </td>
                  <td>
                    <span class="badge ${u.active ? 'bg-green' : 'bg-secondary'} text-white">
                      <i class="fa-solid ${u.active ? 'fa-circle-check' : 'fa-circle-xmark'} me-1"></i>
                      ${u.active ? 'Actif' : 'Inactif'}
                    </span>
                  </td>
                  <td>
                    <div class="d-flex gap-1">
                      <button type="button"
                         class="btn btn-sm btn-ghost-primary" title="Modifier"
                         data-bs-toggle="modal" data-bs-target="#modalUser"
                         data-mode="edit"
                         data-id="${u.id}"
                         data-firstname="${u.firstName}"
                         data-lastname="${u.lastName}"
                         data-email="${u.email}"
                         data-phone="${u.phone}"
                         data-role="${u.role}">
                        <i class="fa-solid fa-pen"></i>
                      </button>
                      <a href="?action=toggle&id=${u.id}"
                         class="btn btn-sm btn-ghost-warning" title="${u.active ? 'Désactiver' : 'Activer'}">
                        <i class="fa-solid fa-power-off"></i>
                      </a>
                      <a href="?action=delete&id=${u.id}"
                         onclick="return confirm('Supprimer cet utilisateur définitivement ?')"
                         class="btn btn-sm btn-ghost-danger" title="Supprimer">
                        <i class="fa-solid fa-trash"></i>
                      </a>
                    </div>
                  </td>
                </tr>
                </c:forEach>
                <c:if test="${empty users}">
                <tr>
                  <td colspan="8" class="text-center text-muted py-5">
                    <i class="fa-solid fa-users-slash fa-2x mb-2 d-block"></i>Aucun utilisateur enregistré
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

<!-- ── Modal: Créer / Modifier utilisateur ── -->
<div class="modal modal-blur fade" id="modalUser" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <form action="" method="post" id="userForm">
        <input type="hidden" name="id"     id="userFormId"     value="">
        <input type="hidden" name="action" id="userFormAction" value="create">
        <div class="modal-header">
          <h5 class="modal-title">
            <i class="fa-solid fa-user-gear me-2 text-danger"></i>
            <span id="userModalTitle">Nouvel utilisateur</span>
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fermer"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-6">
              <label class="form-label required">Prénom</label>
              <input type="text" name="firstName" id="userFirstName" class="form-control"
                     placeholder="Ex: Mohamed" required>
            </div>
            <div class="col-6">
              <label class="form-label required">Nom</label>
              <input type="text" name="lastName" id="userLastName" class="form-control"
                     placeholder="Ex: Benali" required>
            </div>
            <div class="col-6" id="userUsernameWrap">
              <label class="form-label required">Nom d'utilisateur</label>
              <input type="text" name="username" id="userUsername" class="form-control"
                     placeholder="Ex: mbenali">
            </div>
            <div class="col-6" id="userPasswordWrap">
              <label class="form-label required">Mot de passe</label>
              <input type="password" name="password" id="userPassword" class="form-control"
                     placeholder="••••••••">
            </div>
            <div class="col-6">
              <label class="form-label required">Email</label>
              <input type="email" name="email" id="userEmail" class="form-control"
                     placeholder="m.benali@exemple.dz" required>
            </div>
            <div class="col-6">
              <label class="form-label">Téléphone</label>
              <input type="text" name="phone" id="userPhone" class="form-control"
                     placeholder="0555 123 456">
            </div>
            <div class="col-12">
              <label class="form-label required">Rôle</label>
              <select name="role" id="userRole" class="form-select" required>
                <option value="ADMIN">Admin — accès complet</option>
                <option value="MANAGER">Manager — gestion flotte</option>
                <option value="DRIVER">Chauffeur — déclaration accidents</option>
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
document.getElementById('modalUser').addEventListener('show.bs.modal', function(event) {
    var trigger = event.relatedTarget;
    var mode    = trigger ? trigger.dataset.mode : 'create';

    if (mode === 'edit') {
        document.getElementById('userModalTitle').textContent  = 'Modifier l\'utilisateur';
        document.getElementById('userFormAction').value        = 'update';
        document.getElementById('userFormId').value            = trigger.dataset.id;
        document.getElementById('userFirstName').value         = trigger.dataset.firstname;
        document.getElementById('userLastName').value          = trigger.dataset.lastname;
        document.getElementById('userEmail').value             = trigger.dataset.email;
        document.getElementById('userPhone').value             = trigger.dataset.phone || '';
        document.getElementById('userRole').value              = trigger.dataset.role;
        document.getElementById('userUsername').required       = false;
        document.getElementById('userPassword').required       = false;
        document.getElementById('userUsernameWrap').style.display = 'none';
        document.getElementById('userPasswordWrap').style.display = 'none';
    } else {
        document.getElementById('userModalTitle').textContent  = 'Nouvel utilisateur';
        document.getElementById('userFormAction').value        = 'create';
        document.getElementById('userFormId').value            = '';
        document.getElementById('userFirstName').value         = '';
        document.getElementById('userLastName').value          = '';
        document.getElementById('userEmail').value             = '';
        document.getElementById('userPhone').value             = '';
        document.getElementById('userRole').value              = 'DRIVER';
        document.getElementById('userUsername').value          = '';
        document.getElementById('userPassword').value          = '';
        document.getElementById('userUsername').required       = true;
        document.getElementById('userPassword').required       = true;
        document.getElementById('userUsernameWrap').style.display = '';
        document.getElementById('userPasswordWrap').style.display = '';
    }
});
</script>
<script>
(function() {
    var searchInput = document.getElementById('tableSearch');
    var table       = document.getElementById('usersTable');
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
