# Use Python base image
FROM python:3.10-slim

# Set work directory
WORKDIR /app

# Copy files
COPY . .

# Install dependencies (if requirements.txt exists)
RUN pip install -r requirements.txt || true

# Expose port
EXPOSE 6500

# Run the app
CMD ["python3", "app.py"]
