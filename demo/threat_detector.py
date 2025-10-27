#!/usr/bin/env python3
"""
AI-Driven Threat Detection Service
Uses machine learning for anomaly detection and behavioral analysis
"""

import json
import time
import logging
from datetime import datetime
from elasticsearch import Elasticsearch
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
import numpy as np
import joblib
import os

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ThreatDetector:
    def __init__(self, es_host='elasticsearch', es_port=9200):
        self.es = Elasticsearch([f'http://{es_host}:{es_port}'])
        self.model = None
        self.scaler = StandardScaler()
        self.initialize_model()
        
    def initialize_model(self):
        """Initialize or load the anomaly detection model"""
        model_path = '/models/threat_model.pkl'
        if os.path.exists(model_path):
            logger.info("Loading existing model...")
            self.model = joblib.load(model_path)
        else:
            logger.info("Creating new Isolation Forest model...")
            self.model = IsolationForest(
                contamination=0.1,
                random_state=42,
                n_estimators=100
            )
            # Train on synthetic data initially
            self.train_initial_model()
            
    def train_initial_model(self):
        """Train model with synthetic baseline data"""
        # Generate synthetic normal behavior patterns
        np.random.seed(42)
        normal_data = np.random.normal(loc=50, scale=10, size=(1000, 5))
        
        # Fit the scaler and model
        scaled_data = self.scaler.fit_transform(normal_data)
        self.model.fit(scaled_data)
        
        # Save model
        os.makedirs('/models', exist_ok=True)
        joblib.dump(self.model, '/models/threat_model.pkl')
        joblib.dump(self.scaler, '/models/scaler.pkl')
        logger.info("Initial model trained and saved")
        
    def extract_features(self, event):
        """Extract numerical features from security events"""
        features = [
            event.get('failed_logins', 0),
            event.get('packet_count', 0),
            event.get('byte_count', 0),
            event.get('connection_duration', 0),
            event.get('port_scan_score', 0)
        ]
        return np.array(features).reshape(1, -1)
        
    def detect_anomaly(self, event):
        """Detect if an event is anomalous"""
        features = self.extract_features(event)
        scaled_features = self.scaler.transform(features)
        
        # Predict (-1 for anomaly, 1 for normal)
        prediction = self.model.predict(scaled_features)[0]
        anomaly_score = -self.model.score_samples(scaled_features)[0]
        
        return {
            'is_anomaly': prediction == -1,
            'anomaly_score': float(anomaly_score),
            'confidence': min(anomaly_score * 10, 100)
        }
        
    def analyze_behavioral_patterns(self, user_events):
        """UEBA - User and Entity Behavior Analytics"""
        if len(user_events) < 5:
            return {'risk_level': 'LOW', 'behavioral_score': 0}
            
        # Calculate behavioral metrics
        avg_failed_logins = np.mean([e.get('failed_logins', 0) for e in user_events])
        unusual_hours = sum(1 for e in user_events if e.get('hour', 12) > 22 or e.get('hour', 12) < 6)
        unusual_locations = len(set(e.get('source_ip', '') for e in user_events))
        
        behavioral_score = (avg_failed_logins * 10) + (unusual_hours * 5) + (unusual_locations * 3)
        
        if behavioral_score > 50:
            risk_level = 'CRITICAL'
        elif behavioral_score > 30:
            risk_level = 'HIGH'
        elif behavioral_score > 15:
            risk_level = 'MEDIUM'
        else:
            risk_level = 'LOW'
            
        return {
            'risk_level': risk_level,
            'behavioral_score': float(behavioral_score),
            'metrics': {
                'avg_failed_logins': float(avg_failed_logins),
                'unusual_hours_count': unusual_hours,
                'unique_locations': unusual_locations
            }
        }
        
    def process_events(self):
        """Main processing loop"""
        logger.info("Starting threat detection service...")
        
        while True:
            try:
                # Query recent events from Elasticsearch
                query = {
                    "query": {
                        "range": {
                            "@timestamp": {
                                "gte": "now-5m"
                            }
                        }
                    },
                    "sort": [{"@timestamp": "desc"}],
                    "size": 100
                }
                
                # Create index if it doesn't exist
                if not self.es.indices.exists(index='security-events'):
                    logger.info("Security events index doesn't exist yet, waiting...")
                    time.sleep(30)
                    continue
                    
                response = self.es.search(index='security-events', body=query)
                hits = response['hits']['hits']
                
                logger.info(f"Processing {len(hits)} events...")
                
                threats_detected = 0
                for hit in hits:
                    event = hit['_source']
                    
                    # Run anomaly detection
                    detection_result = self.detect_anomaly(event)
                    
                    if detection_result['is_anomaly']:
                        threats_detected += 1
                        # Store threat alert
                        threat_alert = {
                            '@timestamp': datetime.utcnow().isoformat(),
                            'original_event': event,
                            'detection': detection_result,
                            'alert_type': 'ML_ANOMALY_DETECTED',
                            'severity': self.calculate_severity(detection_result['anomaly_score'])
                        }
                        
                        self.es.index(index='threat-alerts', document=threat_alert)
                        logger.warning(f"Threat detected! Score: {detection_result['anomaly_score']:.2f}")
                
                # Group events by user for UEBA
                user_events = {}
                for hit in hits:
                    event = hit['_source']
                    username = event.get('username', 'unknown')
                    if username not in user_events:
                        user_events[username] = []
                    user_events[username].append(event)
                
                # Analyze user behavior
                for username, events in user_events.items():
                    if len(events) >= 3:  # Only analyze users with sufficient data
                        behavior_analysis = self.analyze_behavioral_patterns(events)
                        
                        if behavior_analysis['risk_level'] in ['HIGH', 'CRITICAL']:
                            alert = {
                                '@timestamp': datetime.utcnow().isoformat(),
                                'alert_type': 'UEBA_RISK',
                                'username': username,
                                'analysis': behavior_analysis,
                                'event_count': len(events)
                            }
                            self.es.index(index='ueba-alerts', document=alert)
                            logger.warning(f"UEBA Risk: {username} - {behavior_analysis['risk_level']}")
                
                logger.info(f"Analysis complete. Threats detected: {threats_detected}")
                
            except Exception as e:
                logger.error(f"Error processing events: {str(e)}")
                
            # Sleep before next iteration
            time.sleep(60)
            
    def calculate_severity(self, score):
        """Calculate severity level based on anomaly score"""
        if score > 0.7:
            return 'CRITICAL'
        elif score > 0.5:
            return 'HIGH'
        elif score > 0.3:
            return 'MEDIUM'
        else:
            return 'LOW'

if __name__ == '__main__':
    detector = ThreatDetector()
    detector.process_events()
