<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SafeDrive — Connexion</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/css/tabler.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    body {
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
      min-height: 100vh;
    }
    .login-card { border-radius: 1rem; box-shadow: 0 25px 60px rgba(0,0,0,.45); border: none; }
    .brand-icon { font-size: 2.5rem; color: #e94560; }
  </style>
</head>
<body class="d-flex align-items-center">
<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-sm-10 col-md-7 col-lg-4">

      <!-- Card -->
      <div class="card login-card">
        <div class="card-body p-5">

          <!-- Brand -->
          <div class="text-center mb-4">
            <div class="brand-icon mb-2">
              <i class="fa-solid fa-shield-halved"></i>
            </div>
            <h2 class="fw-bold mb-0">SafeDrive</h2>
            <p class="text-muted mt-1 mb-0">Connectez-vous à votre espace</p>
          </div>

          <!-- Error alert -->
          <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-danger alert-dismissible mb-4 py-2" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
          <% } %>

          <!-- Login form -->
          <form action="${pageContext.request.contextPath}/login" method="post">

            <div class="mb-3">
              <label class="form-label fw-semibold">
                <i class="fa-solid fa-user fa-sm me-1 text-muted"></i>Nom d'utilisateur
              </label>
              <input type="text" name="username" class="form-control form-control-lg"
                     required autofocus placeholder="ex: admin">
            </div>

            <div class="mb-4">
              <label class="form-label fw-semibold">
                <i class="fa-solid fa-lock fa-sm me-1 text-muted"></i>Mot de passe
              </label>
              <input type="password" name="password" class="form-control form-control-lg"
                     required placeholder="••••••••">
            </div>

            <button type="submit" class="btn btn-danger w-100 btn-lg fw-semibold">
              <i class="fa-solid fa-right-to-bracket me-2"></i>Connexion
            </button>
          </form>

        </div>
      </div>

      <div class="text-center mt-3">
        <small class="text-white-50">SafeDrive &copy; 2026 — Gestion de flotte</small>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
</body>
</html>
