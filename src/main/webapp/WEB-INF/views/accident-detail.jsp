<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Accident #${accident.id}</title>
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
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/app/accidents">Accidents</a></li>
              <li class="breadcrumb-item active">Accident #${accident.id}</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-file-circle-exclamation me-2 text-danger"></i>
              Accident #${accident.id}
            </h2>
          </div>
          <div class="col-auto ms-auto d-flex gap-2">
            <a href="${pageContext.request.contextPath}/app/accidents" class="btn btn-ghost-secondary">
              <i class="fa-solid fa-arrow-left me-1"></i>Retour
            </a>
            <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
              <c:if test="${accident.status != 'RESOLVED'}">
              <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=RESOLVED&returnTo=detail"
                 class="btn btn-success"
                 onclick="return confirm('Marquer cet accident comme résolu ?')">
                <i class="fa-solid fa-circle-check me-1"></i>Marquer comme traité
              </a>
              </c:if>
              <a href="${pageContext.request.contextPath}/app/reports?type=accident-single&id=${accident.id}"
                 class="btn btn-ghost-dark">
                <i class="fa-solid fa-file-pdf me-1"></i>Télécharger PDF
              </a>
            </c:if>
          </div>
        </div>
      </div>
    </div>

    <div class="page-body">
      <div class="container-xl">

        <!-- ── AI result alert (shown after new declaration) ── -->
        <c:if test="${newDeclaration}">
        <div class="alert alert-success alert-dismissible mb-4" role="alert">
          <div class="d-flex">
            <div class="me-3"><i class="fa-solid fa-robot fa-2x"></i></div>
            <div>
              <h4 class="alert-title mb-1">Accident déclaré avec succès !</h4>
              <c:choose>
                <c:when test="${accident.aiSeverity == 'EN_ATTENTE' || empty accident.aiSeverity}">
                  Aucune image fournie — analyse IA non disponible.
                </c:when>
                <c:otherwise>
                  Résultat de l'analyse IA :
                  <span class="badge ms-1 ${accident.aiSeverity == 'GRAVE' ? 'bg-danger' : 'bg-success'}">
                    ${accident.aiSeverity == 'GRAVE' ? 'GRAVE' : 'LÉGER'}
                  </span>
                  <c:if test="${aiConfPct != null}">
                    — Confiance : <strong>${aiConfPct}%</strong>
                  </c:if>
                  — <em>Gravité détectée automatiquement par l'IA</em>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        </c:if>

        <div class="row row-cards">

          <!-- ── Left: Main info ── -->
          <div class="col-lg-8">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fa-solid fa-circle-info me-2 text-muted"></i>Informations de l'accident
                </h3>
              </div>
              <div class="card-body">
                <div class="row g-4">

                  <c:if test="${currentRole != 'DRIVER'}">
                  <div class="col-sm-6">
                    <div class="info-label"><i class="fa-solid fa-user me-1"></i>Chauffeur</div>
                    <div class="info-value d-flex align-items-center gap-2">
                      <span class="avatar avatar-sm bg-green text-white rounded-circle" style="font-size:.7rem">
                        ${accident.driver.firstName.substring(0,1)}${accident.driver.lastName.substring(0,1)}
                      </span>
                      ${accident.driver.firstName} ${accident.driver.lastName}
                    </div>
                  </div>
                  </c:if>

                  <div class="col-sm-6">
                    <div class="info-label"><i class="fa-solid fa-car me-1"></i>Véhicule</div>
                    <div class="info-value">
                      ${accident.vehicle.brand} ${accident.vehicle.model}
                      <span class="badge bg-secondary-lt text-secondary ms-1">${accident.vehicle.registrationNumber}</span>
                    </div>
                  </div>

                  <div class="col-sm-6">
                    <div class="info-label"><i class="fa-solid fa-calendar me-1"></i>Date</div>
                    <div class="info-value">${accident.date}</div>
                  </div>

                  <div class="col-sm-6">
                    <div class="info-label"><i class="fa-solid fa-location-dot me-1"></i>Lieu</div>
                    <div class="info-value">
                      <c:choose>
                        <c:when test="${not empty accident.location}">${accident.location}</c:when>
                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                      </c:choose>
                    </div>
                  </div>

                  <div class="col-sm-6">
                    <div class="info-label"><i class="fa-solid fa-gauge me-1"></i>Gravité</div>
                    <div class="info-value">
                      <span class="badge fs-6 text-white ${accident.severity == 'SEVERE' ? 'bg-red' : accident.severity == 'MODERATE' ? 'bg-yellow' : 'bg-green'}">
                        <c:choose>
                          <c:when test="${accident.severity == 'SEVERE'}"><i class="fa-solid fa-circle-exclamation me-1"></i>Grave</c:when>
                          <c:when test="${accident.severity == 'MODERATE'}"><i class="fa-solid fa-circle-minus me-1"></i>Modéré</c:when>
                          <c:otherwise><i class="fa-solid fa-circle-check me-1"></i>Mineur</c:otherwise>
                        </c:choose>
                      </span>
                    </div>
                  </div>

                  <div class="col-sm-6">
                    <div class="info-label"><i class="fa-solid fa-flag me-1"></i>Statut</div>
                    <div class="info-value">
                      <span class="badge fs-6 text-white ${accident.status == 'DECLARED' ? 'bg-secondary' : accident.status == 'UNDER_REVIEW' ? 'bg-azure' : 'bg-green'}">
                        <c:choose>
                          <c:when test="${accident.status == 'DECLARED'}"><i class="fa-solid fa-file me-1"></i>Déclaré</c:when>
                          <c:when test="${accident.status == 'UNDER_REVIEW'}"><i class="fa-solid fa-magnifying-glass me-1"></i>En révision</c:when>
                          <c:otherwise><i class="fa-solid fa-circle-check me-1"></i>Résolu</c:otherwise>
                        </c:choose>
                      </span>
                    </div>
                  </div>

                  <div class="col-12">
                    <div class="info-label"><i class="fa-solid fa-align-left me-1"></i>Description</div>
                    <div class="info-value mt-1">
                      <c:choose>
                        <c:when test="${not empty accident.description}">${accident.description}</c:when>
                        <c:otherwise><span class="text-muted fst-italic">Aucune description fournie</span></c:otherwise>
                      </c:choose>
                    </div>
                  </div>

                  <!-- AI Analysis -->
                  <div class="col-12">
                    <div class="info-label"><i class="fa-solid fa-robot me-1"></i>Analyse IA</div>
                    <div class="d-flex flex-wrap align-items-center gap-3 mt-1">
                      <c:choose>
                        <c:when test="${accident.aiSeverity == 'GRAVE'}">
                          <span class="badge bg-danger fs-6">
                            <i class="fa-solid fa-circle-exclamation me-1"></i>GRAVE
                          </span>
                        </c:when>
                        <c:when test="${accident.aiSeverity == 'LEGER'}">
                          <span class="badge bg-success fs-6">
                            <i class="fa-solid fa-circle-check me-1"></i>LÉGER
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge bg-secondary fs-6">
                            <i class="fa-solid fa-hourglass me-1"></i>EN ATTENTE
                          </span>
                        </c:otherwise>
                      </c:choose>
                      <c:if test="${aiConfPct != null}">
                      <span class="text-muted small">
                        <i class="fa-solid fa-chart-simple me-1"></i>Confiance IA : <strong>${aiConfPct}%</strong>
                      </span>
                      </c:if>
                      <span class="text-muted small fst-italic">
                        Gravité détectée automatiquement
                      </span>
                    </div>
                    <c:if test="${accident.graviteManuelle == true}">
                    <div class="mt-2 small text-warning fw-semibold">
                      <i class="fa-solid fa-triangle-exclamation me-1"></i>
                      Gravité modifiée manuellement par
                      ${currentRole == 'ADMIN' ? "l'Admin" : 'le Manager'}
                    </div>
                    </c:if>
                  </div>

                  <!-- Accident Photo (ADMIN / MANAGER only) -->
                  <c:if test="${(currentRole == 'ADMIN' || currentRole == 'MANAGER') && not empty accident.photoPath}">
                  <div class="col-12">
                    <div class="info-label mb-2">
                      <i class="fa-solid fa-camera me-1"></i>Photo de l'accident
                    </div>
                    <div class="text-center">
                      <img src="${pageContext.request.contextPath}/app/accidents?action=photo&id=${accident.id}"
                           alt="Photo de l'accident #${accident.id}"
                           class="rounded"
                           style="max-width:100%; max-height:480px; object-fit:contain; border:1px solid var(--tblr-border-color); cursor:zoom-in;"
                           onclick="this.style.maxHeight = this.style.maxHeight === 'none' ? '480px' : 'none';"
                           title="Cliquer pour agrandir">
                    </div>
                    <small class="text-muted mt-1 d-block text-center">
                      <i class="fa-solid fa-circle-info me-1"></i>Cliquer sur la photo pour agrandir
                    </small>
                  </div>
                  </c:if>

                  <!-- GPS Map -->
                  <c:if test="${accident.latitude != null && accident.longitude != null}">
                  <div class="col-12">
                    <div class="info-label mb-2">
                      <i class="fa-solid fa-location-dot me-1"></i>Localisation GPS
                    </div>
                    <div id="detail-map"></div>
                    <small class="text-muted mt-1 d-block">
                      <i class="fa-solid fa-crosshairs me-1"></i>
                      ${accident.latitude}, ${accident.longitude}
                    </small>
                  </div>
                  </c:if>

                </div><!-- /row -->
              </div>
            </div>
          </div><!-- /col-lg-8 -->

          <!-- ── Right: Actions ── -->
          <div class="col-lg-4">

            <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">

            <!-- Reclassify severity -->
            <div class="card mb-3">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fa-solid fa-pen-to-square me-2 text-muted"></i>Reclassifier la gravité
                </h3>
              </div>
              <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/app/accidents">
                  <input type="hidden" name="action" value="reclassify">
                  <input type="hidden" name="id"     value="${accident.id}">
                  <div class="mb-3">
                    <label class="form-label">Nouvelle gravité</label>
                    <select name="severity" class="form-select">
                      <option value="MINOR"    ${accident.severity == 'MINOR'    ? 'selected' : ''}>Mineur</option>
                      <option value="MODERATE" ${accident.severity == 'MODERATE' ? 'selected' : ''}>Modéré</option>
                      <option value="SEVERE"   ${accident.severity == 'SEVERE'   ? 'selected' : ''}>Grave</option>
                    </select>
                  </div>
                  <button type="submit" class="btn btn-warning w-100">
                    <i class="fa-solid fa-rotate me-1"></i>Appliquer
                  </button>
                </form>
              </div>
            </div>

            <!-- Change status -->
            <div class="card mb-3">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fa-solid fa-sliders me-2 text-muted"></i>Changer le statut
                </h3>
              </div>
              <div class="card-body d-grid gap-2">
                <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=DECLARED&returnTo=detail"
                   class="btn btn-outline-secondary ${accident.status == 'DECLARED' ? 'active' : ''}">
                  <i class="fa-solid fa-file me-1"></i>Déclaré
                </a>
                <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=UNDER_REVIEW&returnTo=detail"
                   class="btn btn-outline-azure ${accident.status == 'UNDER_REVIEW' ? 'active' : ''}">
                  <i class="fa-solid fa-magnifying-glass me-1"></i>En révision
                </a>
                <a href="${pageContext.request.contextPath}/app/accidents?action=updateStatus&id=${accident.id}&status=RESOLVED&returnTo=detail"
                   class="btn btn-outline-success ${accident.status == 'RESOLVED' ? 'active' : ''}">
                  <i class="fa-solid fa-circle-check me-1"></i>Résolu
                </a>
              </div>
            </div>

            </c:if>

            <!-- Metadata -->
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fa-solid fa-clock me-2 text-muted"></i>Métadonnées
                </h3>
              </div>
              <div class="card-body">
                <div class="info-label">Enregistré le</div>
                <div class="info-value">${accident.createdAt}</div>
              </div>
            </div>

          </div><!-- /col-lg-4 -->
        </div><!-- /row -->
      </div>
    </div>
  </div><!-- /page-wrapper -->
</div><!-- /wrapper -->

<c:if test="${accident.latitude != null && accident.longitude != null}">
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(function() {
    var lat = ${accident.latitude};
    var lng = ${accident.longitude};
    var map = L.map('detail-map').setView([lat, lng], 14);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
        maxZoom: 18
    }).addTo(map);
    var icon = L.divIcon({
        className: '',
        html: '<div style="width:16px;height:16px;border-radius:50%;background:#d63939;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,.4)"></div>',
        iconSize: [16, 16], iconAnchor: [8, 8]
    });
    L.marker([lat, lng], { icon: icon }).addTo(map);
})();
</script>
</c:if>
<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
</body>
</html>
