FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    requests==2.31.0 \
    pyyaml==6.0.1 \
    elasticsearch==8.11.0

COPY . /app/

CMD ["python", "soar_engine.py"]
