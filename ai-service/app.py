"""
SafeDrive AI Microservice — Classification d'accidents
POST /classify  → { "severity": "GRAVE"|"LEGER", "confidence": 0.92 }
GET  /health    → { "status": "ok", "model": "loaded"|"not_found" }
"""

import io
import os
import logging

import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as T
from PIL import Image
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse

# ── Architecture du modèle : MobileNetV2 + classifier personnalisé ────────────

def _build_model() -> nn.Module:
    """
    MobileNetV2 backbone (features.0–18) avec un classifier remplacé :
      Dropout → Linear(1280, 128) → ReLU → Dropout → Linear(128, 2)
    Correspond aux clés : features.*.weight / classifier.1.weight / classifier.4.weight
    """
    m = models.mobilenet_v2(weights=None)
    m.classifier = nn.Sequential(
        nn.Dropout(0.2),
        nn.Linear(1280, 128),
        nn.ReLU(),
        nn.Dropout(0.2),
        nn.Linear(128, 2),
    )
    return m


# ── Chargement du modèle au démarrage ────────────────────────────────────────

CLASSES     = ["LEGER", "GRAVE"]
MODEL_PATH  = os.environ.get("MODEL_PATH", "accident_model.pth")
DEVICE      = torch.device("cuda" if torch.cuda.is_available() else "cpu")

_model: nn.Module | None = None
_model_loaded: bool = False
_transform  = None   # initialisé dans _load_model()


def _build_transform(img_size: int) -> T.Compose:
    return T.Compose([
        T.Resize((img_size, img_size)),
        T.ToTensor(),
        T.Normalize(mean=[0.485, 0.456, 0.406],
                    std =[0.229, 0.224, 0.225]),
    ])


def _load_model() -> None:
    global _model, _model_loaded, CLASSES, _transform
    # Toujours construire un transform par défaut pour éviter les None
    _transform = _build_transform(224)

    if not os.path.exists(MODEL_PATH):
        logging.warning(f"Fichier modèle introuvable : {MODEL_PATH}")
        return
    try:
        # weights_only=False : le checkpoint peut contenir des listes/scalaires Python
        checkpoint = torch.load(MODEL_PATH, map_location=DEVICE, weights_only=False)

        # ── Format checkpoint dict ─────────────────────────────────────────
        # { "model_state_dict": {...}, "class_names": [...], "img_size": 224 }
        if isinstance(checkpoint, dict) and "model_state_dict" in checkpoint:
            state_dict = checkpoint["model_state_dict"]
            CLASSES    = checkpoint.get("class_names", ["LEGER", "GRAVE"])
            img_size   = int(checkpoint.get("img_size", 224))
        # ── Format state_dict direct ───────────────────────────────────────
        else:
            state_dict = checkpoint
            img_size   = 224

        m = _build_model()
        m.load_state_dict(state_dict)
        m.eval()

        _model        = m
        _model_loaded = True
        _transform    = _build_transform(img_size)

        logging.info(
            f"Modèle chargé | device={DEVICE} | classes={CLASSES} | img_size={img_size}"
        )
    except Exception as exc:
        logging.error(f"Impossible de charger le modèle : {exc}")

_load_model()

# ── Application FastAPI ───────────────────────────────────────────────────────

app = FastAPI(
    title="SafeDrive AI Service",
    description="Classification d'images d'accidents (LEGER / GRAVE)",
    version="1.0.0",
)


@app.get("/health")
def health() -> dict:
    """Vérifie que le service et le modèle sont disponibles."""
    return {
        "status": "ok",
        "model": "loaded" if _model_loaded else "not_found",
        "device": str(DEVICE),
    }


@app.post("/classify")
async def classify(file: UploadFile = File(..., description="Image de l'accident (JPEG/PNG)")) -> dict:
    """
    Classifie une image d'accident.

    Retourne :
        { "severity": "GRAVE" | "LEGER", "confidence": 0.92 }
    """
    if not _model_loaded:
        raise HTTPException(
            status_code=503,
            detail="Modèle non chargé — vérifiez que accident_model.pth est présent",
        )

    # Lecture et validation de l'image
    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="Fichier image vide")

    try:
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception:
        raise HTTPException(status_code=422, detail="Format d'image non reconnu")

    # Inférence
    try:
        tensor = _transform(image).unsqueeze(0).to(DEVICE)

        with torch.no_grad():
            logits = _model(tensor)
            probs  = torch.softmax(logits, dim=1)[0]
            pred   = int(probs.argmax().item())
            conf   = float(probs[pred].item())

        return {
            "severity":   CLASSES[pred],
            "confidence": round(conf, 4),
        }
    except Exception as exc:
        logging.exception("Erreur lors de la classification")
        raise HTTPException(status_code=500, detail=f"Erreur de classification : {exc}")


# ── Point d'entrée direct ─────────────────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8001, reload=False)
