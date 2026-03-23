# ---- Stage 1: Build & Test ----
FROM python:3.12-slim AS builder

WORKDIR /app

# Install dependencies first (layer caching — only re-runs if requirements.txt changes)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY app/ .

# Run tests inside the build stage — if tests fail, image will NOT be built
RUN pytest tests/ -v


# ---- Stage 2: Production Image ----
FROM python:3.12-slim AS production

WORKDIR /app

# Only copy what's needed for runtime
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/app.py .

# Environment defaults (can be overridden at runtime)
ENV ENVIRONMENT=production
ENV APP_VERSION=1.0.0
ENV PORT=5000

EXPOSE 5000

# Run as non-root user for security
RUN useradd -m appuser
USER appuser

CMD ["python", "app.py"]
