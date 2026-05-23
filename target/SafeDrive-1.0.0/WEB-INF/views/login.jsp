<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SafeDrive — Connexion</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            min-height: 100vh;
        }
        .login-card { border-radius: 16px; box-shadow: 0 25px 60px rgba(0,0,0,.4); }
        .brand-logo  { font-size: 2rem; font-weight: 700; color: #e94560; }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-sm-10 col-md-6 col-lg-4">
            <div class="card login-card">
                <div class="card-body p-5">
                    <div class="text-center mb-4">
                        <div class="brand-logo">SafeDrive</div>
                        <p class="text-muted mt-1 small">Connectez-vous à votre espace</p>
                    </div>

                    <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger py-2">
                        ${error}
                    </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/login" method="post">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Nom d'utilisateur</label>
                            <input type="text" name="username" class="form-control" required autofocus
                                   placeholder="ex: admin">
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Mot de passe</label>
                            <input type="password" name="password" class="form-control" required
                                   placeholder="••••••••">
                        </div>
                        <button type="submit" class="btn btn-danger w-100 py-2 fw-semibold">
                            Connexion
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
