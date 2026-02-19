FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000 \
    WORKERS=1 \
    THREADS=4 \
    TIMEOUT=180

WORKDIR /app

# Install system deps + curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libgl1 \
    libglib2.0-0 \
    libxext6 \
    libxrender1 \
    libsm6 \
  && rm -rf /var/lib/apt/lists/*

# Python deps
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# App
COPY app.py /app/app.py

EXPOSE 5000

# Prod server
CMD ["sh", "-c", "gunicorn -w ${WORKERS} --threads ${THREADS} -t ${TIMEOUT} -b 0.0.0.0:${PORT} app:app"]

# Healthcheck avec curl
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=5 \
  CMD curl -f http://127.0.0.1:5000/health || exit 1