#!/usr/bin/env python3
"""
Bulk Threat Intelligence Generator
Generates UEBA alerts and Threat Hunting findings in bulk for testing
"""

import json
import time
import random
import logging
from datetime import datetime, timedelta
from elasticsearch import Elasticsearch
from elasticsearch.helpers import bulk
from faker import Faker

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

fake = Faker()

class BulkThreatIntelGenerator:
    def __init__(self, es_host='elasticsearch', es_port=9200):
        self.es = Elasticsearch([f'http://{es_host}:{es_port}'])
        self.users = self.generate_users()
        self.mitre_techniques = self.load_mitre_techniques()
        
    def generate_users(self):
        """Generate sample user accounts"""
        users = []
        for i in range(20):
            users.append({
                'username': fake.user_name(),
                'email': fake.email(),
                'department': random.choice(['IT', 'HR', 'Finance', 'Sales', 'Engineering']),
                'risk_level': random.choice(['LOW', 'MEDIUM', 'HIGH'])
            })
        return users
    
    def load_mitre_techniques(self):
        """Load MITRE ATT&CK technique mappings"""
        return {
            'T1110': {'name': 'Brute Force', 'tactic': 'Credential Access'},
            'T1078': {'name': 'Valid Accounts', 'tactic': 'Defense Evasion'},
            'T1046': {'name': 'Network Service Scanning', 'tactic': 'Discovery'},
            'T1071': {'name': 'Application Layer Protocol', 'tactic': 'Command and Control'},
            'T1486': {'name': 'Data Encrypted for Impact', 'tactic': 'Impact'},
            'T1087': {'name': 'Account Discovery', 'tactic': 'Discovery'},
            'T1003': {'name': 'Credential Dumping', 'tactic': 'Credential Access'}
        }
    
    def get_random_timestamp(self, hours_back=24):
        """Generate a random timestamp within the last N hours"""
        now = datetime.utcnow()
        random_hours = random.uniform(0, hours_back)
        return (now - timedelta(hours=random_hours)).isoformat()
        
    def generate_ueba_alert(self, timestamp=None):
        """Generate UEBA (User and Entity Behavior Analytics) alert"""
        user = random.choice(self.users)
        ts = timestamp or datetime.utcnow().isoformat()
        
        risk_levels = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
        risk_level = random.choice(risk_levels)
        
        behavioral_score = {
            'LOW': random.uniform(10, 30),
            'MEDIUM': random.uniform(30, 50),
            'HIGH': random.uniform(50, 75),
            'CRITICAL': random.uniform(75, 100)
        }[risk_level]
        
        return {
            '@timestamp': ts,
            'alert_type': 'UEBA_RISK',
            'username': user['username'],
            'department': user['department'],
            'analysis': {
                'risk_level': risk_level,
                'behavioral_score': behavioral_score,
                'metrics': {
                    'avg_failed_logins': random.uniform(0, 5),
                    'unusual_hours_count': random.randint(0, 10),
                    'unique_locations': random.randint(1, 15),
                    'access_anomalies': random.randint(0, 20)
                },
                'anomaly_types': random.sample([
                    'unusual_login_time',
                    'new_location',
                    'excessive_failed_logins',
                    'privilege_escalation_attempt',
                    'unusual_data_access',
                    'abnormal_file_access'
                ], k=random.randint(1, 3))
            },
            'event_count': random.randint(5, 50),
            'time_window': '1h',
            'severity': risk_level
        }
        
    def generate_threat_hunting_finding(self, timestamp=None):
        """Generate threat hunting finding with MITRE ATT&CK mapping"""
        user = random.choice(self.users)
        ts = timestamp or datetime.utcnow().isoformat()
        technique = random.choice(list(self.mitre_techniques.keys()))
        
        # Generate realistic event data based on technique
        event_data = self.generate_event_for_technique(technique, user, ts)
        
        hunt_types = [
            'Suspicious Login Patterns',
            'Network Reconnaissance',
            'Privilege Escalation Attempts',
            'Data Exfiltration Indicators',
            'Lateral Movement Detection',
            'Persistence Mechanisms'
        ]
        
        return {
            '@timestamp': ts,
            'timestamp': ts,  # Include both for compatibility
            'hunt_name': random.choice(hunt_types),
            'mitre_technique': technique,
            'technique_details': self.mitre_techniques[technique],
            'event_data': event_data,
            'severity': random.choice(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']),
            'confidence_score': random.uniform(60, 95),
            'hunt_cycle_id': datetime.utcnow().strftime('%Y%m%d%H'),
            'status': random.choice(['NEW', 'INVESTIGATING', 'CONFIRMED', 'FALSE_POSITIVE'])
        }
        
    def generate_event_for_technique(self, technique, user, timestamp):
        """Generate realistic event data based on MITRE technique"""
        base_event = {
            '@timestamp': timestamp,
            'username': user['username'],
            'department': user['department'],
            'source_ip': fake.ipv4_private() if random.random() > 0.3 else fake.ipv4_public(),
            'destination_ip': fake.ipv4_private()
        }
        
        if technique == 'T1110':  # Brute Force
            base_event.update({
                'event_type': 'authentication',
                'action': 'login',
                'alert_type': 'brute_force_detected',
                'failed_logins': random.randint(6, 50),
                'status': 'failed',
                'new_location': random.choice([True, False]),
                'risk_score': random.randint(60, 90)
            })
        elif technique == 'T1046':  # Network Scanning
            base_event.update({
                'event_type': 'network',
                'action': 'port_scan',
                'alert_type': 'port_scan_detected',
                'unique_ports_accessed': random.randint(25, 100),
                'scan_detected': True,
                'risk_score': random.randint(50, 80)
            })
        elif technique == 'T1078':  # Valid Accounts
            base_event.update({
                'event_type': 'access_control',
                'action': 'privilege_escalation',
                'alert_type': 'unauthorized_privilege_elevation',
                'target_account': 'Administrator',
                'authorized': False,
                'risk_score': random.randint(70, 95)
            })
        elif technique == 'T1071':  # Application Layer Protocol
            base_event.update({
                'event_type': 'network',
                'action': 'data_transfer',
                'alert_type': 'unusual_data_transfer',
                'bytes_transferred': random.randint(1000000000, 10000000000),
                'external_destination': True,
                'destination_country': random.choice(['CN', 'RU', 'Unknown']),
                'risk_score': random.randint(65, 90)
            })
        else:
            base_event.update({
                'event_type': 'security',
                'action': 'suspicious_activity',
                'risk_score': random.randint(50, 85)
            })
            
        return base_event
        
    def wait_for_elasticsearch(self):
        """Wait for Elasticsearch to be ready"""
        max_retries = 30
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                if self.es.ping():
                    logger.info("Connected to Elasticsearch successfully")
                    return True
            except Exception:
                pass
                
            retry_count += 1
            logger.info(f"Waiting for Elasticsearch... ({retry_count}/{max_retries})")
            time.sleep(5)
            
        logger.error("Failed to connect to Elasticsearch")
        return False
    
    def generate_bulk_ueba_alerts(self, count=100, hours_back=24):
        """Generate bulk UEBA alerts"""
        alerts = []
        
        for i in range(count):
            timestamp = self.get_random_timestamp(hours_back)
            alert = self.generate_ueba_alert(timestamp)
            
            alerts.append({
                '_index': 'ueba-alerts',
                '_source': alert
            })
            
        return alerts
    
    def generate_bulk_threat_hunting_findings(self, count=500, hours_back=24):
        """Generate bulk threat hunting findings"""
        findings = []
        
        for i in range(count):
            timestamp = self.get_random_timestamp(hours_back)
            finding = self.generate_threat_hunting_finding(timestamp)
            
            findings.append({
                '_index': 'threat-hunting-findings',
                '_source': finding
            })
            
        return findings
        
    def generate_all_bulk_data(self, ueba_count=100, hunting_count=500, hours_back=24):
        """Generate all threat intelligence data in bulk"""
        
        if not self.wait_for_elasticsearch():
            logger.error("Cannot proceed without Elasticsearch connection")
            return
        
        total_generated = 0
        
        # Generate UEBA Alerts
        logger.info(f"\n{'='*60}")
        logger.info(f"Generating {ueba_count} UEBA Alerts...")
        logger.info(f"{'='*60}")
        
        try:
            alerts = self.generate_bulk_ueba_alerts(ueba_count, hours_back)
            
            batch_size = 100
            for i in range(0, len(alerts), batch_size):
                batch = alerts[i:i+batch_size]
                success, failed = bulk(self.es, batch, stats_only=True, raise_on_error=False)
                
                if failed > 0:
                    logger.warning(f"Failed to insert {failed} UEBA alerts in batch")
                
                logger.info(f"Inserted batch {i//batch_size + 1}/{(len(alerts)-1)//batch_size + 1} - {success} alerts")
            
            total_generated += len(alerts)
            logger.info(f"✓ Successfully generated {len(alerts)} UEBA alerts")
            
        except Exception as e:
            logger.error(f"Error generating UEBA alerts: {str(e)}")
        
        # Generate Threat Hunting Findings
        logger.info(f"\n{'='*60}")
        logger.info(f"Generating {hunting_count} Threat Hunting Findings...")
        logger.info(f"{'='*60}")
        
        try:
            findings = self.generate_bulk_threat_hunting_findings(hunting_count, hours_back)
            
            batch_size = 100
            for i in range(0, len(findings), batch_size):
                batch = findings[i:i+batch_size]
                success, failed = bulk(self.es, batch, stats_only=True, raise_on_error=False)
                
                if failed > 0:
                    logger.warning(f"Failed to insert {failed} findings in batch")
                
                logger.info(f"Inserted batch {i//batch_size + 1}/{(len(findings)-1)//batch_size + 1} - {success} findings")
            
            total_generated += len(findings)
            logger.info(f"✓ Successfully generated {len(findings)} threat hunting findings")
            
        except Exception as e:
            logger.error(f"Error generating threat hunting findings: {str(e)}")
        
        logger.info(f"\n{'='*60}")
        logger.info(f"BULK GENERATION COMPLETE!")
        logger.info(f"{'='*60}")
        logger.info(f"Total threat intelligence items generated: {total_generated}")
        logger.info(f"UEBA Alerts: {ueba_count}")
        logger.info(f"Threat Hunting Findings: {hunting_count}")
        logger.info(f"Time spread: {hours_back} hours")
        logger.info(f"{'='*60}\n")
        
        # Show summary
        self.show_summary()
    
    def show_summary(self):
        """Show summary of generated data"""
        try:
            time.sleep(2)  # Wait for indexing
            
            ueba_count = self.es.count(index='ueba-alerts')['count']
            hunting_count = self.es.count(index='threat-hunting-findings')['count']
            
            logger.info(f"\n{'='*60}")
            logger.info(f"ELASTICSEARCH SUMMARY")
            logger.info(f"{'='*60}")
            logger.info(f"Total UEBA alerts: {ueba_count}")
            logger.info(f"Total Threat Hunting findings: {hunting_count}")
            logger.info(f"{'='*60}\n")
            
        except Exception as e:
            logger.error(f"Error getting summary: {str(e)}")

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Bulk Threat Intelligence Generator')
    parser.add_argument('--ueba', type=int, default=100, help='Number of UEBA alerts (default: 100)')
    parser.add_argument('--hunting', type=int, default=500, help='Number of threat hunting findings (default: 500)')
    parser.add_argument('--hours', type=int, default=24, help='Spread data over N hours (default: 24)')
    parser.add_argument('--host', type=str, default='elasticsearch', help='Elasticsearch host (default: elasticsearch)')
    parser.add_argument('--port', type=int, default=9200, help='Elasticsearch port (default: 9200)')
    
    args = parser.parse_args()
    
    logger.info("="*60)
    logger.info("BULK THREAT INTELLIGENCE GENERATOR")
    logger.info("="*60)
    logger.info(f"UEBA Alerts: {args.ueba}")
    logger.info(f"Threat Hunting Findings: {args.hunting}")
    logger.info(f"Time spread: {args.hours} hours")
    logger.info(f"Elasticsearch: {args.host}:{args.port}")
    logger.info("="*60)
    
    generator = BulkThreatIntelGenerator(es_host=args.host, es_port=args.port)
    generator.generate_all_bulk_data(ueba_count=args.ueba, hunting_count=args.hunting, hours_back=args.hours)
