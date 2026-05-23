<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>SafeDrive — Utilisateurs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main-content">
    <div class="topbar">
        <h5 class="mb-0 fw-bold">Gestion des Utilisateurs</h5>
        <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#modalUser">
            Nouvel utilisateur
        </button>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>#</th><th>Nom complet</th><th>Username</th><th>Email</th>
                            <th>Téléphone</th><th>Rôle</th><th>Statut</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.id}</td>
                            <td class="fw-semibold">${u.firstName} ${u.lastName}</td>
                            <td>${u.username}</td>
                            <td>${u.email}</td>
                            <td>${u.phone}</td>
                            <td><span class="badge ${u.role == 'ADMIN' ? 'bg-danger' : u.role == 'MANAGER' ? 'bg-primary' : 'bg-success'}">${u.role}</span></td>
                            <td>
                                <span class="badge ${u.active ? 'bg-success' : 'bg-secondary'}">
                                    ${u.active ? 'Actif' : 'Inactif'}
                                </span>
                            </td>
                            <td>
                                <a href="?action=edit&id=${u.id}" class="btn btn-sm btn-outline-primary">Modifier</a>
                                <a href="?action=toggle&id=${u.id}" class="btn btn-sm btn-outline-warning">Activer/Désactiver</a>
                                <a href="?action=delete&id=${u.id}"
                                   onclick="return confirm('Supprimer cet utilisateur ?')"
                                   class="btn btn-sm btn-outline-danger">Supprimer</a>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty users}">
                        <tr><td colspan="8" class="text-center text-muted py-4">Aucun utilisateur</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal create/edit user -->
<div class="modal fade" id="modalUser" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="" method="post">
                <div class="modal-header">
                    <h5 class="modal-title">${empty editUser ? 'Nouvel utilisateur' : 'Modifier utilisateur'}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <c:if test="${not empty editUser}">
                        <input type="hidden" name="id" value="${editUser.id}">
                        <input type="hidden" name="action" value="update">
                    </c:if>
                    <c:if test="${empty editUser}">
                        <input type="hidden" name="action" value="create">
                    </c:if>
                    <div class="col-6">
                        <label class="form-label">Prénom</label>
                        <input type="text" name="firstName" class="form-control" value="${editUser.firstName}" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Nom</label>
                        <input type="text" name="lastName" class="form-control" value="${editUser.lastName}" required>
                    </div>
                    <c:if test="${empty editUser}">
                    <div class="col-6">
                        <label class="form-label">Username</label>
                        <input type="text" name="username" class="form-control" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Mot de passe</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    </c:if>
                    <div class="col-6">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" value="${editUser.email}" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Téléphone</label>
                        <input type="text" name="phone" class="form-control" value="${editUser.phone}">
                    </div>
                    <div class="col-12">
                        <label class="form-label">Rôle</label>
                        <select name="role" class="form-select" required>
                            <option value="ADMIN"   ${editUser.role == 'ADMIN'   ? 'selected' : ''}>Admin</option>
                            <option value="MANAGER" ${editUser.role == 'MANAGER' ? 'selected' : ''}>Manager</option>
                            <option value="DRIVER"  ${editUser.role == 'DRIVER'  ? 'selected' : ''}>Chauffeur</option>
                        </select>
                    </div>
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
<c:if test="${not empty editUser}">
<script>new bootstrap.Modal(document.getElementById('modalUser')).show();</script>
</c:if>
</body>
</html>
