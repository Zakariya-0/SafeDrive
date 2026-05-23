# SafeDrive — Microservice IA de Classification d'Accidents

Le microservice FastAPI reçoit une image d'accident et retourne sa gravité
(`LEGER` ou `GRAVE`) avec un score de confiance.

## Prérequis

- Python 3.10+
- Le fichier `accident_model.pth` doit être placé dans `ai-service/`

## Installation

```bash
cd ai-service
pip install -r requirements.txt
```

## Démarrage

```bash
# Option 1 — script direct
python app.py

# Option 2 — uvicorn (production)
uvicorn app:app --host 127.0.0.1 --port 8001

# Option 3 — uvicorn avec rechargement auto (dev)
uvicorn app:app --host 127.0.0.1 --port 8001 --reload
```

Le service écoute sur **http://127.0.0.1:8001**.

## Endpoints

| Méthode | URL | Description |
|---------|-----|-------------|
| `GET`   | `/health`   | Vérifie que le service et le modèle sont chargés |
| `POST`  | `/classify` | Classifie une image (`multipart/form-data`, champ `file`) |

### Exemple de réponse `/classify`

```json
{ "severity": "GRAVE", "confidence": 0.92 }
```

### Test rapide avec curl

```bash
curl -X POST http://127.0.0.1:8001/classify \
     -F "file=@photo_accident.jpg"
```

## Architecture du modèle (`AccidentCNN`)

```
Conv2d(3→32) + BatchNorm + ReLU + MaxPool(2)
Conv2d(32→64) + BatchNorm + ReLU + MaxPool(2)
Conv2d(64→128) + BatchNorm + ReLU + AdaptiveAvgPool(4×4)
Linear(2048→256) → ReLU
Linear(256→64)   → ReLU
Linear(64→2)     → Softmax → [LEGER, GRAVE]
```

## Intégration avec le backend Java

Le servlet `AccidentServlet.java` appelle automatiquement le microservice
après réception du formulaire de déclaration d'accident (si une image est fournie).

- Si le service est indisponible → `aiSeverity = "EN_ATTENTE"`, aucune erreur levée
- Le résultat est stocké dans les colonnes `ai_severity` et `ai_confidence`
  de la table `accidents`

## Variables d'environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `MODEL_PATH` | `accident_model.pth` | Chemin vers le fichier `.pth` |
