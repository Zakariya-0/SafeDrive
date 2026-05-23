<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="sidebar">
    <div class="brand">SafeDrive</div>
    <nav class="mt-2">
        <a href="${pageContext.request.contextPath}/app/dashboard" class="nav-link">
            Dashboard
        </a>
        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <a href="${pageContext.request.contextPath}/app/vehicles" class="nav-link">
            Véhicules
        </a>
        <a href="${pageContext.request.contextPath}/app/chauffeurs" class="nav-link">
            Chauffeurs
        </a>
        </c:if>
        <c:if test="${currentRole == 'ADMIN'}">
        <a href="${pageContext.request.contextPath}/app/users" class="nav-link">
            Utilisateurs
        </a>
        </c:if>
        <a href="${pageContext.request.contextPath}/app/accidents" class="nav-link">
            Accidents
        </a>
        <a href="${pageContext.request.contextPath}/app/reports" class="nav-link">
            Rapports
        </a>
        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <a href="${pageContext.request.contextPath}/app/livetracking" class="nav-link">
            Suivi en Direct
        </a>
        <a href="#" class="nav-link" style="justify-content:space-between"
           data-bs-toggle="offcanvas" data-bs-target="#notifCanvas" aria-controls="notifCanvas">
            Notifications
            <span id="notif-badge" class="badge bg-danger rounded-pill"
                  style="display:none;font-size:.7rem">0</span>
        </a>
        </c:if>
    </nav>
    <div class="sidebar-footer">
        <c:if test="${currentRole == 'DRIVER'}">
        <div class="px-3 pb-2">
            <small id="gps-status" class="text-muted">GPS inactif</small>
        </div>
        </c:if>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link text-danger">
            Déconnexion
        </a>
    </div>
</div>

<c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
<!-- Notification offcanvas panel -->
<div class="offcanvas offcanvas-end" tabindex="-1" id="notifCanvas"
     aria-labelledby="notifCanvasLabel" style="width:360px">
    <div class="offcanvas-header border-bottom">
        <h6 class="offcanvas-title fw-bold mb-0" id="notifCanvasLabel">Notifications</h6>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas"
                aria-label="Fermer"></button>
    </div>
    <div class="offcanvas-body p-0" id="notif-list-body">
        <div class="p-4 text-center text-muted">Chargement...</div>
    </div>
    <div class="p-2 border-top">
        <button id="notif-mark-all-read"
                class="btn btn-sm btn-outline-secondary w-100">
            Tout marquer comme lu
        </button>
    </div>
</div>

<script>
(function() {
    const CTX = '${pageContext.request.contextPath}';

    function updateBadge(count) {
        const badge = document.getElementById('notif-badge');
        if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count;
            badge.style.display = '';
        } else {
            badge.style.display = 'none';
        }
    }

    function fetchCount() {
        fetch(CTX + '/app/api/notifications')
            .then(r => r.json())
            .then(data => updateBadge(data.count))
            .catch(() => {});
    }

    function fetchList() {
        const body = document.getElementById('notif-list-body');
        fetch(CTX + '/app/api/notifications')
            .then(r => r.json())
            .then(data => {
                updateBadge(data.count);
                if (!data.items || data.items.length === 0) {
                    body.innerHTML = '<div class="p-4 text-center text-muted">Aucune notification</div>';
                    return;
                }
                let html = '';
                data.items.forEach(n => {
                    const bg    = n.read ? '' : 'background:#fff8f0;';
                    const dot   = n.read ? '' : '<span style="width:8px;height:8px;background:#e94560;border-radius:50%;display:inline-block;margin-right:6px;flex-shrink:0"></span>';
                    const accId = n.accidentId || 0;
                    const href  = accId ? (CTX + '/app/accidents?action=detail&id=' + accId) : '#';
                    html += '<a href="' + href + '" ' +
                            'class="px-3 py-2 border-bottom d-flex align-items-start text-decoration-none" ' +
                            'style="color:inherit;' + bg + '" ' +
                            'onclick="return markNotifRead(event,' + n.id + ',' + (accId ? 'true' : 'false') + ')">' +
                            dot +
                            '<div>' +
                            '<div style="font-size:.85rem;color:#212529">' + escHtml(n.message) + '</div>' +
                            '<small class="text-muted">' + escHtml(n.createdAt) + '</small>' +
                            '</div></a>';
                });
                body.innerHTML = html;
            })
            .catch(() => {
                body.innerHTML = '<div class="p-4 text-center text-danger">Erreur de chargement</div>';
            });
    }

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;')
                        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function markNotifRead(e, id, hasAccident) {
        // Fire-and-forget : marquer comme lue sans bloquer la navigation
        fetch(CTX + '/app/notifications/read', {
            method:  'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body:    'notificationId=' + id
        }).then(function() { fetchCount(); }).catch(function() {});

        if (!hasAccident) {
            // Pas de page détail → empêcher href="#" et rafraîchir la liste
            e.preventDefault();
            setTimeout(fetchList, 300);
            return false;
        }
        // Avec accident : laisser l'<a href> naviguer vers la page détail
        return true;
    }

    document.addEventListener('DOMContentLoaded', function() {
        fetchCount();
        setInterval(fetchCount, 30000);

        const canvas = document.getElementById('notifCanvas');
        if (canvas) {
            canvas.addEventListener('show.bs.offcanvas', fetchList);
        }

        const markBtn = document.getElementById('notif-mark-all-read');
        if (markBtn) {
            markBtn.addEventListener('click', function() {
                fetch(CTX + '/app/api/notifications/read', { method: 'POST' })
                    .then(() => fetchList())
                    .catch(() => {});
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

    if (!navigator.geolocation) {
        status.textContent = 'GPS non supporté';
        return;
    }

    navigator.geolocation.watchPosition(
        function(pos) {
            fetch(CTX + '/app/api/locations/update', {
                method:  'POST',
                headers: { 'Content-Type': 'application/json' },
                body:    JSON.stringify({
                    lat: pos.coords.latitude,
                    lng: pos.coords.longitude
                })
            });
            status.textContent = 'GPS actif';
        },
        function(err) {
            status.textContent = 'GPS refusé';
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 5000 }
    );
})();
</script>
</c:if>
