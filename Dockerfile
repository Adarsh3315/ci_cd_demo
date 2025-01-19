# Use an official Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY src/ src/
COPY tests/ tests/
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Run tests when the container starts
CMD ["pytest"]