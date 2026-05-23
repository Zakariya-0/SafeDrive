# SafeDrive
SafeDrive — Plateforme intelligente de gestion de flotte et de traitement automatique des accidents

SafeDrive est une application web d'entreprise développée en Java EE (Jakarta EE) 
avec Apache Tomcat 10.1, permettant la gestion complète d'une flotte de véhicules, 
la déclaration et le traitement des accidents routiers, et la classification 
automatique de la gravité des accidents par intelligence artificielle.

## Fonctionnalités principales

### Gestion des utilisateurs et des rôles
- 3 rôles distincts : Administrateur, Manager, Chauffeur
- Authentification sécurisée avec JWT (JSON Web Token)
- Gestion complète des profils utilisateurs

### Gestion de la flotte
- CRUD complet sur les véhicules
- Attribution des véhicules aux chauffeurs (un véhicule par chauffeur)
- Suivi GPS en temps réel des chauffeurs sur une carte interactive (Leaflet.js)
- Historique des positions GPS

### Déclaration et traitement des accidents
- Déclaration d'accidents par les chauffeurs (photo + GPS + description)
- Classification automatique de la gravité (MINEUR/GRAVE) par IA
- Localisation manuelle sur carte interactive ou GPS automatique
- Reclassification manuelle possible par le Manager/Admin
- Génération de rapports PDF individuels par accident (iText)

### Intelligence Artificielle
- Microservice Python FastAPI intégré
- Modèle MobileNetV2 entraîné sur un dataset réel de dommages automobiles
- Classification en temps réel lors de la déclaration d'un accident
- Score de confiance affiché avec chaque classification

### Notifications en temps réel
- Système WebSocket (Jakarta WebSocket JSR-356)
- Notification instantanée des Managers lors d'un accident grave
- Centre de notifications avec badge et historique

## Stack technique

### Backend
- Java 21
- Jakarta EE / Servlet API 6.0
- Apache Tomcat 10.1
- JPA / Hibernate 6 (ORM)
- PostgreSQL 16 (base de données)
- JWT (authentification)
- BCrypt (hachage des mots de passe)
- iText (génération PDF)
- Jakarta WebSocket (notifications temps réel)
- Maven (gestion des dépendances)

### Frontend
- JSP (JavaServer Pages)
- Bootstrap 5
- Leaflet.js (cartes interactives)
- JavaScript (Fetch API, WebSocket)

### Microservice IA
- Python 3.x
- FastAPI
- PyTorch
- MobileNetV2 (modèle pré-entraîné fine-tuné)
- Uvicorn

## Architecture
Le projet suit une architecture MVC en couches :
- Modèle : entités JPA (User, Vehicle, Accident, Notification...)
- DAO : accès aux données via EntityManager
- Service : logique métier
- Servlet : contrôleurs HTTP
- JSP : vues

## Prérequis
- Java 21
- Apache Maven 3.9+
- Apache Tomcat 10.1
- PostgreSQL 16
- Python 3.10+ (pour le microservice IA)

## Installation et démarrage

### Base de données
psql -U postgres -c "CREATE DATABASE safedrive_db;"

### Microservice IA
cd ai-service
pip install -r requirements.txt
python app.py

### Application principale
mvn clean package
# Déployer le WAR dans Tomcat ou utiliser Eclipse Run on Server

### Accès
http://localhost:8080/SafeDrive

## Auteur
Développé dans le cadre d'un projet de fin d'anneé par Zakariya SAHID.
