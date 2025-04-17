# Gunakan image Python yang sudah ada di Docker Hub
FROM python:3.13-slim-bullseye

# Set working directory di dalam container
WORKDIR /app

# Menyalin file requirement dan kode aplikasi
COPY requirements.txt /app/
COPY . /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000 (port default Flask)
EXPOSE 5000

# Jalankan aplikasi Flask
CMD ["python", "app.py"]
