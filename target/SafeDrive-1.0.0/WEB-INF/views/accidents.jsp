<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>SafeDrive — Accidents</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <style>#picker-map { height: 260px; border-radius: 8px; border: 1px solid #dee2e6; cursor: crosshair; }</style>
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main-content">
    <div class="topbar">
        <h5 class="mb-0 fw-bold">Déclaration d'Accidents</h5>
        <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#modalAccident">
            Déclarer un accident
        </button>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>#</th>
                            <c:if test="${currentRole != 'DRIVER'}"><th>Chauffeur</th></c:if>
                            <th>Véhicule</th><th>Date</th><th>Lieu</th>
                            <th>Sévérité</th><th>Statut</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${accidents}">
                        <tr>
                            <td>${a.id}</td>
                            <c:if test="${currentRole != 'DRIVER'}">
                            <td>${a.driver.firstName} ${a.driver.lastName}</td>
                            </c:if>
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
                            <td>
                                <a href="?action=detail&id=${a.id}"
                                   class="btn btn-sm btn-outline-primary">Détail</a>
                                <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
                                <div class="dropdown d-inline">
                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                                        Statut
                                    </button>
                                    <ul class="dropdown-menu">
                                        <li><a class="dropdown-item" href="?action=updateStatus&id=${a.id}&status=DECLARED">Déclaré</a></li>
                                        <li><a class="dropdown-item" href="?action=updateStatus&id=${a.id}&status=UNDER_REVIEW">En révision</a></li>
                                        <li><a class="dropdown-item" href="?action=updateStatus&id=${a.id}&status=RESOLVED">Résolu</a></li>
                                    </ul>
                                </div>
                                </c:if>
                                <c:if test="${currentRole == 'ADMIN'}">
                                <a href="?action=delete&id=${a.id}"
                                   onclick="return confirm('Supprimer cet accident ?')"
                                   class="btn btn-sm btn-outline-danger">Supprimer</a>
                                </c:if>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty accidents}">
                        <tr><td colspan="8" class="text-center text-muted py-4">Aucun accident enregistré</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal Déclarer accident -->
<div class="modal fade" id="modalAccident" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="post"
                  action="${pageContext.request.contextPath}/app/accidents"
                  enctype="multipart/form-data">
                <input type="hidden" name="action" value="declare">
                <div class="modal-header">
                    <h5 class="modal-title">Déclarer un accident</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
                    <div class="col-md-6">
                        <label class="form-label">Chauffeur</label>
                        <select name="driverId" class="form-select" required>
                            <option value="">— Sélectionner —</option>
                            <c:forEach var="d" items="${drivers}">
                            <option value="${d.id}">${d.firstName} ${d.lastName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    </c:if>
                    <div class="col-md-6">
                        <label class="form-label">Véhicule</label>
                        <c:choose>
                            <c:when test="${currentRole == 'DRIVER'}">
                                <c:choose>
                                    <c:when test="${chauffeurVehicle != null}">
                                        <input type="hidden" name="vehicleId" value="${chauffeurVehicle.id}">
                                        <p class="form-control-plaintext fw-semibold mb-0">
                                            <i class="bi bi-truck me-1 text-secondary"></i>
                                            ${chauffeurVehicle.brand} ${chauffeurVehicle.model}
                                            <small class="text-muted">(${chauffeurVehicle.registrationNumber})</small>
                                        </p>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="form-control-plaintext text-danger fw-semibold mb-0">
                                            <i class="bi bi-exclamation-triangle-fill me-1"></i>
                                            Aucun véhicule assigné. Contactez votre manager.
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <select name="vehicleId" class="form-select" required>
                                    <option value="">— Sélectionner —</option>
                                    <c:forEach var="v" items="${vehicles}">
                                    <option value="${v.id}">${v.registrationNumber} — ${v.brand} ${v.model}</option>
                                    </c:forEach>
                                </select>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Date de l'accident</label>
                        <input type="date" name="date" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Sévérité</label>
                        <select name="severity" class="form-select" required>
                            <option value="MINOR">Mineur</option>
                            <option value="MODERATE">Modéré</option>
                            <option value="SEVERE">Grave</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Lieu</label>
                        <input type="text" name="location" class="form-control" placeholder="Ex: Autoroute A1, km 45">
                    </div>
                    <div class="col-12">
                        <label class="form-label">Description</label>
                        <textarea name="description" class="form-control" rows="3"
                                  placeholder="Décrivez les circonstances de l'accident..."></textarea>
                    </div>
                    <div class="col-12">
                        <label class="form-label">
                            Photo de l'accident
                            <small class="text-muted">(optionnel — analyse IA automatique)</small>
                        </label>
                        <input type="file" name="image" class="form-control" accept="image/*">
                        <div class="form-text">
                            <i class="bi bi-robot"></i>
                            Joindre une photo pour la classification automatique par intelligence artificielle
                        </div>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Localisation sur la carte <small class="text-muted">(cliquer pour placer le marqueur)</small></label>
                        <div id="picker-map"></div>
                        <input type="hidden" name="latitude"  id="acc-lat">
                        <input type="hidden" name="longitude" id="acc-lng">
                        <small id="coords-display" class="text-muted">Aucune position sélectionnée</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annuler</button>
                    <c:choose>
                        <c:when test="${currentRole == 'DRIVER' && chauffeurVehicle == null}">
                            <button type="submit" class="btn btn-danger" disabled>Déclarer</button>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="btn btn-danger">Déclarer</button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function() {
    var pickerMap, pickerMarker;

    document.getElementById('modalAccident').addEventListener('shown.bs.modal', function() {
        if (!pickerMap) {
            pickerMap = L.map('picker-map').setView([36.7372, 3.0926], 5);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
                maxZoom: 18
            }).addTo(pickerMap);

            pickerMap.on('click', function(e) {
                var lat = e.latlng.lat.toFixed(6);
                var lng = e.latlng.lng.toFixed(6);
                document.getElementById('acc-lat').value = lat;
                document.getElementById('acc-lng').value = lng;
                document.getElementById('coords-display').textContent = 'Position : ' + lat + ', ' + lng;
                if (pickerMarker) {
                    pickerMarker.setLatLng(e.latlng);
                } else {
                    pickerMarker = L.marker(e.latlng).addTo(pickerMap);
                }
            });
        } else {
            pickerMap.invalidateSize();
        }
    });

    document.getElementById('modalAccident').addEventListener('hidden.bs.modal', function() {
        document.getElementById('acc-lat').value = '';
        document.getElementById('acc-lng').value = '';
        document.getElementById('coords-display').textContent = 'Aucune position sélectionnée';
        if (pickerMarker) { pickerMarker.remove(); pickerMarker = null; }
    });
})();
</script>
</body>
</html>
