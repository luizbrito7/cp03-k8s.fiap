# store-api endurecida: multi-stage + distroless nonroot
# ---------- build ----------
# mesmo Debian 12 / Python 3.11 da imagem final: o venv aponta para /usr/bin/python3,
# que existe nas duas (um builder python:3.12-slim gera um venv que nao roda no distroless)
FROM debian:12-slim AS builder
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3-venv \
 && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
# pip e setuptools so servem para instalar; o setuptools 66 do Debian tem CVE HIGH
RUN pip install --no-cache-dir -r requirements.txt \
 && pip uninstall -y pip setuptools

# ---------- runtime ----------
FROM gcr.io/distroless/python3-debian12:nonroot
ARG APP_VERSION=1.1
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY --chown=65532:65532 main.py .
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_VERSION=$APP_VERSION
USER 65532:65532
EXPOSE 8000
ENTRYPOINT ["/opt/venv/bin/python3", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
