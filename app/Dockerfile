# Use the official Python image from the Docker Hub
FROM python:3.9-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY app/requirements.txt .

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install Flask and other dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
CMD ["python3", "app/app.py"]
