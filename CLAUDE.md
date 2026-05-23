# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Full build → target/SafeDrive-1.0.0.war
mvn clean package

# Compile only
mvn compile
```

Deploy the WAR to Tomcat's `webapps/` directory or use Eclipse's built-in server integration.
App runs at: `http://localhost:8080/SafeDrive`

Before first run, create the PostgreSQL database:
```sql
CREATE DATABASE safedrive_db;
```
Hibernate `hbm2ddl.auto=update` will create all tables on first startup.
Credentials are in `src/main/resources/META-INF/persistence.xml`.

## Tech Stack

- **Java 21**, WAR on **Apache Tomcat 10.1**
- **Servlet 6.0** — use `jakarta.servlet.*`, never `javax.servlet.*`
- **Hibernate 6 / JPA 3.1** with `RESOURCE_LOCAL` transactions (no app-server JTA)
- **PostgreSQL 42.7** JDBC driver
- **jjwt 0.12** for JWT (stored as `HttpOnly` cookie named `jwt`)
- **iText 7** for PDF generation
- **BCrypt** (jbcrypt) for password hashing
- **Bootstrap 5.3** + **Bootstrap Icons** loaded from CDN in JSPs

## Architecture

```
filter/AuthFilter        — validates JWT cookie on every /app/* request;
                           sets currentUser / currentRole / currentUserId
                           as request attributes consumed by all JSPs

servlet/LoginServlet     — GET shows login.jsp; POST authenticates,
                           generates JWT, sets cookie, redirects to /app/dashboard
servlet/LogoutServlet    — clears the jwt cookie
servlet/DashboardServlet — aggregates stats for all roles; forwards to dashboard.jsp
servlet/UserServlet      — ADMIN only; CRUD for users
servlet/VehicleServlet   — ADMIN/MANAGER; CRUD for vehicles
servlet/AccidentServlet  — all roles; DRIVER sees only own accidents
servlet/ReportServlet    — ADMIN/MANAGER; streams PDF via iText7

service/*                — business logic, password hashing, BCrypt checks
dao/*                    — JPA EntityManager operations (open/close per method)
model/                   — JPA entities: User, Vehicle, Accident
                           Enums: Role, VehicleStatus, AccidentSeverity, AccidentStatus
config/HibernateUtil     — singleton EntityManagerFactory
config/JwtUtil           — sign/validate JWT tokens
```

### URL map

| URL pattern         | Servlet / resource          | Roles         |
|---------------------|-----------------------------|---------------|
| `/login`            | LoginServlet                | public        |
| `/logout`           | LogoutServlet               | public        |
| `/app/dashboard`    | DashboardServlet            | all           |
| `/app/users`        | UserServlet                 | ADMIN         |
| `/app/vehicles`     | VehicleServlet              | ADMIN/MANAGER |
| `/app/accidents`    | AccidentServlet             | all           |
| `/app/reports`      | ReportServlet (+ PDF dl)    | ADMIN/MANAGER |

JSP views live in `src/main/webapp/WEB-INF/views/`. `sidebar.jsp` is a shared include.
Shared CSS: `src/main/webapp/assets/css/style.css`.

### Role behaviour

| Feature              | ADMIN | MANAGER | DRIVER |
|----------------------|-------|---------|--------|
| User management      | ✓     |         |        |
| Vehicle CRUD         | ✓     | ✓       |        |
| Accident declare     | ✓     | ✓       | ✓ (own)|
| Accident status edit | ✓     | ✓       |        |
| PDF reports          | ✓     | ✓       |        |
| Dashboard full stats | ✓     | ✓       |        |
