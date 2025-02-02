# backend/Dockerfile

# Usamos una imagen base oficial de Python
FROM python:3.9-slim

# Establecemos variables de entorno para Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Variables para OpenShift (ejecutar como non-root)
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Creamos y establecemos el directorio de trabajo
WORKDIR /app

# Instalamos las dependencias del sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copiamos los archivos de requisitos e instalamos dependencias
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copiamos el código de la aplicación
COPY . .

# Creamos un usuario no privilegiado para OpenShift
RUN useradd -m -U appuser && \
    chown -R appuser:appuser /app

# Cambiamos al usuario no privilegiado
USER appuser

# Exponemos el puerto que usará Django
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "backend.wsgi:application"]