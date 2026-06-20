<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="navbar navbar-vertical navbar-expand-lg" data-bs-theme="dark">
  <div class="container-fluid">

    <!-- Mobile toggle -->
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
            data-bs-target="#navbar-menu" aria-controls="navbar-menu"
            aria-expanded="false" aria-label="Ouvrir le menu">
      <span class="navbar-toggler-icon"></span>
    </button>

    <!-- Brand -->
    <a href="${pageContext.request.contextPath}/app/dashboard"
       class="navbar-brand d-flex align-items-center gap-2 py-3">
      <i class="fa-solid fa-shield-halved fa-lg" style="color:#e94560"></i>
      <span class="fw-bold fs-5">SafeDrive</span>
    </a>

    <!-- Collapsible nav -->
    <div class="collapse navbar-collapse" id="navbar-menu">
      <ul class="navbar-nav pt-lg-3 flex-grow-1">

        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/app/dashboard">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-gauge-high"></i>
            </span>
            <span class="nav-link-title">Tableau de bord</span>
          </a>
        </li>

        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/app/vehicles">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-car"></i>
            </span>
            <span class="nav-link-title">Véhicules</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/app/chauffeurs">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-id-badge"></i>
            </span>
            <span class="nav-link-title">Chauffeurs</span>
          </a>
        </li>
        </c:if>

        <c:if test="${currentRole == 'ADMIN'}">
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/app/users">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-users-gear"></i>
            </span>
            <span class="nav-link-title">Utilisateurs</span>
          </a>
        </li>
        </c:if>

        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/app/accidents">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-triangle-exclamation"></i>
            </span>
            <span class="nav-link-title">Accidents</span>
          </a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/app/reports">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-file-pdf"></i>
            </span>
            <span class="nav-link-title">Rapports</span>
          </a>
        </li>

        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/app/livetracking">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-location-dot"></i>
            </span>
            <span class="nav-link-title">Suivi en Direct</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link d-flex align-items-center" href="#"
             data-bs-toggle="offcanvas" data-bs-target="#notifCanvas"
             aria-controls="notifCanvas">
            <span class="nav-link-icon d-md-none d-lg-inline-block">
              <i class="fa-solid fa-bell"></i>
            </span>
            <span class="nav-link-title flex-grow-1">Notifications</span>
            <span id="notif-badge" class="badge bg-danger d-none" style="font-size:.7rem">0</span>
          </a>
        </li>
        </c:if>
      </ul>

      <!-- ── Sidebar footer: GPS + user info + logout ── -->
      <div style="border-top:1px solid rgba(255,255,255,.1); padding:.9rem 1rem .8rem">
        <c:if test="${currentRole == 'DRIVER'}">
        <div class="d-flex align-items-center gap-2 mb-2">
          <i class="fa-solid fa-satellite-dish fa-sm" style="color:rgba(255,255,255,.35)"></i>
          <small id="gps-status" style="color:rgba(255,255,255,.45);font-size:.77rem">GPS inactif</small>
        </div>
        </c:if>
        <div class="d-flex align-items-center gap-2">
          <div class="sidebar-user-avatar">
            <i class="fa-solid fa-user fa-xs"></i>
          </div>
          <div class="flex-grow-1 overflow-hidden">
            <div class="text-white fw-semibold text-truncate" style="font-size:.82rem">${currentUser}</div>
            <span class="badge bg-danger mt-1" style="font-size:.62rem">${currentRole}</span>
          </div>
          <a href="${pageContext.request.contextPath}/logout"
             class="btn btn-ghost-danger btn-icon btn-sm" title="Déconnexion">
            <i class="fa-solid fa-right-from-bracket"></i>
          </a>
        </div>
      </div>

    </div><!-- /collapse -->
  </div>
</aside>

<!-- ── Toast container (used by notification polling) ── -->
<div class="position-fixed top-0 end-0 p-3" style="z-index:9999" id="toast-container"></div>

<c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
<!-- Notification offcanvas panel -->
<div class="offcanvas offcanvas-end" tabindex="-1" id="notifCanvas"
     aria-labelledby="notifCanvasLabel" style="width:360px">
  <div class="offcanvas-header border-bottom">
    <div class="d-flex align-items-center gap-2">
      <i class="fa-solid fa-bell text-danger"></i>
      <h6 class="offcanvas-title fw-bold mb-0" id="notifCanvasLabel">Notifications</h6>
    </div>
    <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Fermer"></button>
  </div>
  <div class="offcanvas-body p-0" id="notif-list-body">
    <div class="p-4 text-center text-muted">
      <i class="fa-solid fa-spinner fa-spin me-1"></i> Chargement...
    </div>
  </div>
  <div class="p-2 border-top">
    <button id="notif-mark-all-read" class="btn btn-sm btn-outline-secondary w-100">
      <i class="fa-solid fa-check-double me-1"></i>Tout marquer comme lu
    </button>
  </div>
</div>

<script>
(function() {
    const CTX = '${pageContext.request.contextPath}';
    let prevCount = -1;

    function showToast(message) {
        const container = document.getElementById('toast-container');
        if (!container) return;
        const id = 'toast-' + Date.now();
        container.insertAdjacentHTML('beforeend',
            '<div class="toast show align-items-center text-white bg-danger border-0 mb-2" id="' + id + '" role="alert">' +
            '<div class="d-flex"><div class="toast-body"><i class="fa-solid fa-bell me-1"></i>' + message + '</div>' +
            '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>' +
            '</div></div>');
        setTimeout(function() { const el = document.getElementById(id); if (el) el.remove(); }, 5000);
    }

    function updateBadge(count) {
        const badge = document.getElementById('notif-badge');
        if (!badge) return;
        if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count;
            badge.classList.remove('d-none');
        } else {
            badge.classList.add('d-none');
        }
        if (prevCount >= 0 && count > prevCount) {
            const diff = count - prevCount;
            showToast(diff + ' nouvelle' + (diff > 1 ? 's' : '') + ' notification' + (diff > 1 ? 's' : ''));
        }
        prevCount = count;
    }

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function fetchCount() {
        fetch(CTX + '/app/api/notifications')
            .then(function(r) { return r.json(); })
            .then(function(data) { updateBadge(data.count); })
            .catch(function() {});
    }

    function fetchList() {
        const body = document.getElementById('notif-list-body');
        if (!body) return;
        fetch(CTX + '/app/api/notifications')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                updateBadge(data.count);
                if (!data.items || data.items.length === 0) {
                    body.innerHTML = '<div class="p-4 text-center text-muted"><i class="fa-solid fa-bell-slash fa-2x mb-3 d-block"></i>Aucune notification</div>';
                    return;
                }
                let html = '';
                data.items.forEach(function(n) {
                    const accId = n.accidentId || 0;
                    const href  = accId ? (CTX + '/app/accidents?action=detail&id=' + accId) : '#';
                    html += '<a href="' + href + '" class="px-3 py-2 border-bottom d-flex align-items-start text-decoration-none' +
                            (n.read ? '' : ' notif-item-unread') + '" style="color:inherit" ' +
                            'onclick="return markNotifRead(event,' + n.id + ',' + (accId ? 'true' : 'false') + ')">' +
                            (n.read ? '<span style="width:14px;flex-shrink:0" class="me-2"></span>' :
                                      '<span class="notif-dot me-2 flex-shrink-0 mt-1"></span>') +
                            '<div><div style="font-size:.85rem">' + escHtml(n.message) + '</div>' +
                            '<small class="text-muted">' + escHtml(n.createdAt) + '</small></div></a>';
                });
                body.innerHTML = html;
            })
            .catch(function() {
                body.innerHTML = '<div class="p-4 text-center text-danger">Erreur de chargement</div>';
            });
    }

    function markNotifRead(e, id, hasAccident) {
        fetch(CTX + '/app/notifications/read', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'notificationId=' + id
        }).then(function() { fetchCount(); }).catch(function() {});
        if (!hasAccident) { e.preventDefault(); setTimeout(fetchList, 300); return false; }
        return true;
    }

    document.addEventListener('DOMContentLoaded', function() {
        fetchCount();
        setInterval(fetchCount, 30000);
        const canvas = document.getElementById('notifCanvas');
        if (canvas) canvas.addEventListener('show.bs.offcanvas', fetchList);
        const markBtn = document.getElementById('notif-mark-all-read');
        if (markBtn) {
            markBtn.addEventListener('click', function() {
                fetch(CTX + '/app/api/notifications/read', { method: 'POST' })
                    .then(function() { fetchList(); }).catch(function() {});
            });
        }
    });
})();
</script>
</c:if>

<c:if test="${currentRole == 'DRIVER'}">
<script>
(function() {
    const CTX    = '${pageContext.request.contextPath}';
    const status = document.getElementById('gps-status');
    if (!navigator.geolocation) { if (status) status.textContent = 'GPS non supporté'; return; }
    navigator.geolocation.watchPosition(
        function(pos) {
            fetch(CTX + '/app/api/locations/update', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ lat: pos.coords.latitude, lng: pos.coords.longitude })
            });
            if (status) { status.textContent = 'GPS actif'; status.style.color = '#26a269'; }
        },
        function() { if (status) status.textContent = 'GPS refusé'; },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 5000 }
    );
})();
</script>
</c:if>
