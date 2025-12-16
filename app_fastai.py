# app_fastai.py
from fastapi import FastAPI
from pydantic import BaseModel
from fastai.text.all import load_learner
import os

MODEL_PATH = os.environ.get("MODEL_PATH", "product_classifier.pkl")

app = FastAPI(title="FastAI text classifier")

class InputText(BaseModel):
    text: str

# Load learner once at startup
learner = load_learner(MODEL_PATH)

@app.post("/predict")
def predict(payload: InputText):
    # learner.predict returns (category, tensor, probs)
    pred = learner.predict(payload.text)
    label = str(pred[0])
    tensor = pred[1].tolist()
    probs = pred[2].tolist() # probabilities
    return {"label": label, "tensor": tensor, "probs": probs}
