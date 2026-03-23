from flask import Flask, jsonify, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import os
import socket
import time

app = Flask(__name__)

# Secret key loaded from environment — injected by K8s Secret or Azure KeyVault
app.secret_key = os.getenv("APP_SECRET_KEY", "dev-only-insecure-key")

# --- Prometheus metrics ---
# Counter: total number of requests per endpoint and status code
REQUEST_COUNT = Counter(
    "app_request_count",
    "Total HTTP request count",
    ["endpoint", "status_code"]
)

# Histogram: tracks how long each request takes
REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "HTTP request latency in seconds",
    ["endpoint"]
)


# --- Helper: track every request automatically ---
def track(endpoint):
    def decorator(fn):
        def wrapper(*args, **kwargs):
            start = time.time()
            response = fn(*args, **kwargs)
            duration = time.time() - start
            status = response[1] if isinstance(response, tuple) else 200
            REQUEST_COUNT.labels(endpoint=endpoint, status_code=status).inc()
            REQUEST_LATENCY.labels(endpoint=endpoint).observe(duration)
            return response
        wrapper.__name__ = fn.__name__
        return wrapper
    return decorator


# --- Routes ---

@app.route("/")
@track("/")
def home():
    return jsonify({
        "message": "DevOps Lab API is running!",
        "host": socket.gethostname(),
        "version": os.getenv("APP_VERSION", "1.0.0")
    })

@app.route("/health")
@track("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/info")
@track("/info")
def info():
    return jsonify({
        "app": "devops-lab",
        "environment": os.getenv("ENVIRONMENT", "development"),
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "secret_loaded": app.secret_key != "dev-only-insecure-key"   # never expose the value
    })

@app.route("/metrics")
def metrics():
    # Prometheus scrapes this endpoint every 15s
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
