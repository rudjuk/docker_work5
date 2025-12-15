FROM python:3.12-slim

WORKDIR /app

# Copy requirements first for better caching
COPY apps/course-app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY apps/course-app/src/ ./src/

# Expose port
EXPOSE 8080

# Run the application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]

