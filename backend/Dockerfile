# Use the official Python image as the base image
FROM python:3.11.4

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY --chown=appuser:appuser requirements.txt /app/
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy the Django project into the container
COPY --chown=appuser:appuser . /app/

# Run Django migrations
RUN python manage.py migrate

# Run the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
