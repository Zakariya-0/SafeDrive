<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Rapports</title>
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
              <li class="breadcrumb-item active">Rapports</li>
            </ol>
            <h2 class="page-title">
              <i class="fa-solid fa-file-pdf me-2 text-danger"></i>Génération de Rapports PDF
            </h2>
          </div>
        </div>
      </div>
    </div>

    <div class="page-body">
      <div class="container-xl">

        <div class="row row-cards">

          <!-- Accidents report (all roles) -->
          <div class="col-md-4">
            <div class="card h-100">
              <div class="card-body d-flex flex-column">
                <div class="mb-3">
                  <span class="avatar bg-red text-white mb-3 rounded">
                    <i class="fa-solid fa-triangle-exclamation fa-lg"></i>
                  </span>
                  <c:choose>
                    <c:when test="${currentRole == 'DRIVER'}">
                      <h3 class="card-title mb-1">Mes Accidents</h3>
                      <p class="text-muted">
                        Exporter la liste de vos propres accidents avec leur statut, sévérité et détails en PDF.
                      </p>
                    </c:when>
                    <c:otherwise>
                      <h3 class="card-title mb-1">Rapport des Accidents</h3>
                      <p class="text-muted">
                        Exporter la liste complète des accidents de tous les chauffeurs avec leur statut et détails en PDF.
                      </p>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="mt-auto">
                  <div class="d-flex align-items-center gap-2 mb-3 text-muted small">
                    <i class="fa-solid fa-circle-info"></i>
                    Format PDF — généré à la volée
                  </div>
                  <a href="${pageContext.request.contextPath}/app/reports?type=accidents"
                     class="btn btn-danger w-100">
                    <i class="fa-solid fa-file-arrow-down me-2"></i>Télécharger PDF
                  </a>
                </div>
              </div>
            </div>
          </div>

          <!-- Vehicles report (ADMIN & MANAGER) -->
          <c:if test="${currentRole == 'ADMIN' || currentRole == 'MANAGER'}">
          <div class="col-md-4">
            <div class="card h-100">
              <div class="card-body d-flex flex-column">
                <div class="mb-3">
                  <span class="avatar bg-blue text-white mb-3 rounded">
                    <i class="fa-solid fa-car fa-lg"></i>
                  </span>
                  <h3 class="card-title mb-1">Rapport des Véhicules</h3>
                  <p class="text-muted">
                    Exporter l'inventaire complet de la flotte avec l'état, le kilométrage et les chauffeurs assignés en PDF.
                  </p>
                </div>
                <div class="mt-auto">
                  <div class="d-flex align-items-center gap-2 mb-3 text-muted small">
                    <i class="fa-solid fa-circle-info"></i>
                    Format PDF — généré à la volée
                  </div>
                  <a href="${pageContext.request.contextPath}/app/reports?type=vehicles"
                     class="btn btn-primary w-100">
                    <i class="fa-solid fa-file-arrow-down me-2"></i>Télécharger PDF
                  </a>
                </div>
              </div>
            </div>
          </div>

          <!-- Stat summary card -->
          <div class="col-md-4">
            <div class="card h-100 bg-dark text-white">
              <div class="card-body d-flex flex-column">
                <div class="mb-3">
                  <span class="avatar bg-white text-dark mb-3 rounded">
                    <i class="fa-solid fa-chart-bar fa-lg"></i>
                  </span>
                  <h3 class="card-title mb-1 text-white">Conseil</h3>
                  <p style="color:rgba(255,255,255,.7)">
                    Exportez régulièrement vos rapports pour un suivi optimal de votre flotte.
                    Les PDF incluent date, heure et signature numérique.
                  </p>
                </div>
                <div class="mt-auto">
                  <div class="d-flex flex-column gap-2">
                    <div class="d-flex align-items-center gap-2" style="color:rgba(255,255,255,.6);font-size:.85rem">
                      <i class="fa-solid fa-circle-check text-success"></i>
                      Données en temps réel
                    </div>
                    <div class="d-flex align-items-center gap-2" style="color:rgba(255,255,255,.6);font-size:.85rem">
                      <i class="fa-solid fa-circle-check text-success"></i>
                      Format professionnel iText 7
                    </div>
                    <div class="d-flex align-items-center gap-2" style="color:rgba(255,255,255,.6);font-size:.85rem">
                      <i class="fa-solid fa-circle-check text-success"></i>
                      Sécurisé — accès rôle basé
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          </c:if>

        </div><!-- /row -->
      </div>
    </div>
  </div><!-- /page-wrapper -->
</div><!-- /wrapper -->

<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
</body>
</html>
