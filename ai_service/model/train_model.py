import numpy as np
import joblib
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans


# Synthetic training data representing listing patterns:
# [Price, ReportedCondition (0=poor..4=new), SellerRating (0-5), DaysActive]
np.random.seed(42)
safe_listings = np.column_stack([
    np.random.uniform(500,5000,200), # Reasonable price
    np.random.randint(2,5,200), # Good condition
    np.random.uniform(3.5,5.0,200), # High seller rating
    np.random.randint(1,30,200), # listed for 1 - 30 days
])
scalper_listings = np.column_stack([
    np.random.uniform(8000, 30000, 100),     # inflated prices
    np.random.randint(3, 5, 100),            # claim near-new
    np.random.uniform(2.0, 3.5, 100),        # medium seller rating
    np.random.randint(0, 5, 100),            # listed very recently
])

fraud_listings = np.column_stack([
    np.random.uniform(50, 400, 100),         # suspiciously cheap
    np.random.randint(4, 5, 100),            # claim brand new
    np.random.uniform(0.0, 2.0, 100),        # low/no rating
    np.random.randint(0, 2, 100),            # just listed
])
X = np.vstack([safe_listings, scalper_listings, fraud_listings])
# Scale Features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
# Train 
kmeans = KMeans(n_clusters = 3, random_state = 42, n_init = 10)
kmeans.fit(X_scaled)

# Map cluster IDs to human-readable labels
# Inspect centroids to assign labels correctly after training
centroids = scaler.inverse_transform(kmeans.cluster_centers_)
print("Cluster centroids (Price, Condition, Rating, DaysActive):")
for i, c in enumerate(centroids):
    print(f"  Cluster {i}: {c}")

joblib.dump({'scaler': scaler, 'kmeans': kmeans}, 'kmeans_model.pkl')
print("Model saved to kmeans_model.pkl")