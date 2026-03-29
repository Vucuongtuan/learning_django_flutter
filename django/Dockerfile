# Sử dụng Python 3.12 slim
FROM python:3.12-slim

# Thiết lập biến môi trường
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Thiết lập thư mục làm việc
WORKDIR /app

# Cài đặt các dependencies hệ thống (cần cho psycopg2 và pycairo/xhtml2pdf)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    pkg-config \
    libcairo2-dev \
    python3-dev \
    libffi-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Cài đặt Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ source code
COPY . /app/

# Chạy server (mặc định)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
