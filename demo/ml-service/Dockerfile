FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir scikit-learn==1.3.2 pandas==2.1.4 numpy==1.26.2 elasticsearch==8.11.0 requests==2.31.0 joblib==1.3.2
COPY . /app/
CMD ["python", "threat_detector.py"]
