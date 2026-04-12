from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, validator
import joblib
import numpy as np
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="LocalMarket AI Service", version="1.0.0")
MODEL_PATH = os.path.join(os.path.dirname(__file__),"model","kmeans_model.pkl")
model_bundle = joblib.load(MODEL_PATH)
scaler: object = model_bundle["scaler"]
kmeans: object = model_bundle["kmeans"]

# IMPORTANT: Update this map after running train_model.py
# and inspecting the cluster centroids
CLUSTER_LABELS = {
     0: {"label": "Safe",             "action": "allow",  "color": "green"},
    1: {"label": "Potential Scalper","action": "review", "color": "amber"},
    2: {"label": "Fraud Anomaly",    "action": "flag",   "color": "red"},
}
class ListingAnalysisRequest(BaseModel):
    price: float = Field(..., gt= 0, description ="Listing price in INR")
    reported_condition: int = Field(..., ge = 0 , le=4, description="0=Poor, 1=Fair, 2=Good, 3=Very Good, 4=Like New")
    seller_rating: float = Field(...,ge=0.0, le = 5.0)
    days_active: int = Field(..., ge=0,
        description="Days since seller account was created")
    @validator("price")
    def price_must_be_positive(cls,v):
        if v <= 0:
            raise ValueError("Price must be grater than 0")
        return v
class ListingAnalysisResponse(BaseModel):
    cluster_id: int
    risk_label: str
    action: str
    color: str
    confidence_note: str

@app.get("/health")
async def health():
    return {"status": "ok", "model": "kmeans_v1"}

@app.post("/analyze-listing", response_model=ListingAnalysisResponse)
async def analyze_listing(payload: ListingAnalysisRequest):
    try:
        features = np.array([[
            payload.price,
            payload.reported_condition,
            payload.seller_rating,
            payload.days_active,
        ]])
        features_scaled = scaler.transform(features_scaled)[0]
        cluster_id = int(kmeans.predict(features_scaled)[0])
        distances = kmeans.transform(features_scaled)[0]
        assigned_distance = distances[cluster_id]
        confidence = "high" if assigned_distance < 1.5 else "moderate"
        info = CLUSTER_LABELS[cluster_id]
        return ListingAnalysisResponse(
            cluster_id=cluster_id,
            risk_label=info["label"],
            action=info["action"],
            color=info["color"],
            confidence_note=f"{confidence} confidence (distance={assigned_distance:.2f})",

        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    