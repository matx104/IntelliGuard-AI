FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir elasticsearch==8.11.0 requests==2.31.0 pandas==2.1.4 pyyaml==6.0.1
COPY . /app/
CMD ["python", "automated_hunter.py"]
