FROM python:3.11-slim

# Reduce image size and avoid caches
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Reduce number of threads (helps with RAM on small instances)
ENV OMP_NUM_THREADS=1
ENV MKL_NUM_THREADS=1

WORKDIR /app

# Install system deps needed to build torch / fastai wheels (keep minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app and model
COPY app_fastai.py .
# Copy your model into the image; adjust the path if different
COPY product_classifier.pkl .

EXPOSE 8000

# Use single worker and bind host so it's accessible.
CMD ["uvicorn", "app_fastai:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
