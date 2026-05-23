<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>SafeDrive — Véhicules</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main-content">
    <div class="topbar">
        <h5 class="mb-0 fw-bold">Gestion des Véhicules</h5>
        <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
        <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#modalVehicle">
            Nouveau véhicule
        </button>
        </c:if>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Immatriculation</th><th>Marque / Modèle</th><th>Année</th>
                            <th>Kilométrage</th><th>Chauffeur assigné</th><th>Statut</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="v" items="${vehicles}">
                        <tr>
                            <td class="fw-semibold">${v.registrationNumber}</td>
                            <td>${v.brand} ${v.model}</td>
                            <td>${v.year}</td>
                            <td>${v.mileage} km</td>
                            <td>${v.assignedDriver != null ? v.assignedDriver.firstName.concat(' ').concat(v.assignedDriver.lastName) : '—'}</td>
                            <td>
                                <span class="badge
                                    ${v.status == 'AVAILABLE'   ? 'bg-success' :
                                      v.status == 'IN_USE'      ? 'bg-primary' :
                                      v.status == 'MAINTENANCE' ? 'bg-warning text-dark' : 'bg-secondary'}">
                                    ${v.status}
                                </span>
                            </td>
                            <td>
                                <a href="?action=edit&id=${v.id}" class="btn btn-sm btn-outline-primary">Modifier</a>
                                <c:if test="${currentRole == 'ADMIN'}">
                                <a href="?action=delete&id=${v.id}"
                                   onclick="return confirm('Supprimer ce véhicule ?')"
                                   class="btn btn-sm btn-outline-danger">Supprimer</a>
                                </c:if>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty vehicles}">
                        <tr><td colspan="7" class="text-center text-muted py-4">Aucun véhicule enregistré</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal -->
<div class="modal fade" id="modalVehicle" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post">
                <div class="modal-header">
                    <h5 class="modal-title">${empty editVehicle ? 'Nouveau véhicule' : 'Modifier véhicule'}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <c:choose>
                        <c:when test="${not empty editVehicle}">
                            <input type="hidden" name="id" value="${editVehicle.id}">
                            <input type="hidden" name="action" value="update">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="create">
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${empty editVehicle}">
                    <div class="col-12">
                        <label class="form-label">Immatriculation</label>
                        <input type="text" name="registrationNumber" class="form-control" required>
                    </div>
                    </c:if>
                    <div class="col-6">
                        <label class="form-label">Marque</label>
                        <input type="text" name="brand" class="form-control" value="${editVehicle.brand}" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Modèle</label>
                        <input type="text" name="model" class="form-control" value="${editVehicle.model}" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Année</label>
                        <input type="number" name="year" class="form-control" value="${editVehicle.year}" min="1990" max="2030" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Kilométrage</label>
                        <input type="number" name="mileage" class="form-control" value="${editVehicle.mileage}" min="0">
                    </div>
                    <c:if test="${not empty editVehicle}">
                    <div class="col-6">
                        <label class="form-label">Statut</label>
                        <select name="status" class="form-select">
                            <option value="AVAILABLE"   ${editVehicle.status == 'AVAILABLE'   ? 'selected' : ''}>Disponible</option>
                            <option value="IN_USE"      ${editVehicle.status == 'IN_USE'      ? 'selected' : ''}>En service</option>
                            <option value="MAINTENANCE" ${editVehicle.status == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                            <option value="RETIRED"     ${editVehicle.status == 'RETIRED'     ? 'selected' : ''}>Retiré</option>
                        </select>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Chauffeur assigné</label>
                        <select name="assignedDriverId" class="form-select">
                            <option value="">— Aucun —</option>
                            <c:forEach var="d" items="${drivers}">
                            <option value="${d.id}" ${editVehicle.assignedDriver != null && editVehicle.assignedDriver.id == d.id ? 'selected' : ''}>
                                ${d.firstName} ${d.lastName}
                            </option>
                            </c:forEach>
                        </select>
                    </div>
                    </c:if>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annuler</button>
                    <button type="submit" class="btn btn-danger">Enregistrer</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<c:if test="${not empty editVehicle}">
<script>new bootstrap.Modal(document.getElementById('modalVehicle')).show();</script>
</c:if>
</body>
</html>
