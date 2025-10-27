FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    elasticsearch==8.11.0 \
    faker==20.1.0

COPY . /app/

CMD ["python", "generate_events.py"]
