<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>SafeDrive — Gestion des Chauffeurs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main-content">

    <div class="topbar">
        <h5 class="mb-0 fw-bold">Gestion des Chauffeurs</h5>
    </div>

    <c:if test="${not empty success}">
    <div class="alert alert-success alert-dismissible fade show mx-0 mb-3" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>${success}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    </c:if>

    <!-- Cartes de synthèse -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-danger bg-opacity-10 p-3">
                        <i class="bi bi-people-fill text-danger fs-4"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Total chauffeurs</div>
                        <div class="fw-bold fs-4">${chauffeurs.size()}</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-success bg-opacity-10 p-3">
                        <i class="bi bi-person-check-fill text-success fs-4"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Chauffeurs assignés</div>
                        <div class="fw-bold fs-4">${assignedCount}</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-warning bg-opacity-10 p-3">
                        <i class="bi bi-car-front-fill text-warning fs-4"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Véhicules disponibles</div>
                        <div class="fw-bold fs-4">${vehiclesDispo.size()}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tableau des chauffeurs -->
    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Chauffeur</th>
                            <th>Email</th>
                            <th>Téléphone</th>
                            <th>Véhicule assigné</th>
                            <th class="text-center">Accidents</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${chauffeurs}">
                        <tr>
                            <td>
                                <div class="fw-semibold">${u.firstName} ${u.lastName}</div>
                                <small class="text-muted">${u.username}</small>
                            </td>
                            <td>${u.email}</td>
                            <td>${not empty u.phone ? u.phone : '—'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.assignedVehicle != null}">
                                        <span class="badge bg-danger bg-opacity-10 text-danger px-2 py-1 fs-6">
                                            <i class="bi bi-car-front me-1"></i>
                                            ${u.assignedVehicle.registrationNumber}
                                            — ${u.assignedVehicle.brand} ${u.assignedVehicle.model}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted fst-italic">Aucun véhicule</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <span class="badge ${accidentCounts[u.id] > 0 ? 'bg-warning text-dark' : 'bg-secondary'}">
                                    ${accidentCounts[u.id]}
                                </span>
                            </td>
                            <td>
                                <div class="d-flex gap-2">
                                    <!-- Bouton Attribuer / Modifier -->
                                    <button class="btn btn-sm btn-danger"
                                            data-bs-toggle="modal"
                                            data-bs-target="#modalAttribuer"
                                            data-chauffeur-id="${u.id}"
                                            data-chauffeur-nom="${u.firstName} ${u.lastName}">
                                        <i class="bi bi-car-front me-1"></i>
                                        ${u.assignedVehicle != null ? 'Modifier' : 'Attribuer'}
                                    </button>

                                    <!-- Bouton Désassigner (visible seulement si véhicule assigné) -->
                                    <c:if test="${u.assignedVehicle != null}">
                                    <form method="post" class="m-0"
                                          onsubmit="return confirm('Désassigner ${u.firstName} ${u.lastName} de son véhicule ?')">
                                        <input type="hidden" name="action"    value="unassign">
                                        <input type="hidden" name="vehicleId" value="${u.assignedVehicle.id}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                            <i class="bi bi-person-dash"></i> Désassigner
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
                                <i class="bi bi-people fs-2 d-block mb-2"></i>
                                Aucun chauffeur enregistré
                            </td>
                        </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal d'attribution -->
<div class="modal fade" id="modalAttribuer" tabindex="-1" aria-labelledby="modalAttribuerLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" id="formAttribuer">
                <input type="hidden" name="action"      value="assign">
                <input type="hidden" name="chauffeurId" id="modalChauffeurId">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalAttribuerLabel">
                        <i class="bi bi-car-front-fill me-2 text-danger"></i>Attribuer un véhicule
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted mb-3">
                        Sélectionner un véhicule pour
                        <strong id="modalChauffeurNom"></strong>
                    </p>
                    <c:choose>
                        <c:when test="${empty vehiclesDispo}">
                            <div class="alert alert-warning mb-0">
                                <i class="bi bi-exclamation-triangle me-2"></i>
                                Aucun véhicule disponible sans chauffeur.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <label class="form-label fw-semibold">Véhicule disponible</label>
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
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annuler</button>
                    <c:if test="${not empty vehiclesDispo}">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-check-lg me-1"></i>Attribuer
                    </button>
                    </c:if>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('modalAttribuer').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    document.getElementById('modalChauffeurId').value = btn.getAttribute('data-chauffeur-id');
    document.getElementById('modalChauffeurNom').textContent = btn.getAttribute('data-chauffeur-nom');
    // Réinitialiser la sélection
    const sel = document.querySelector('#formAttribuer select[name="vehicleId"]');
    if (sel) sel.selectedIndex = 0;
});
</script>
</body>
</html>
