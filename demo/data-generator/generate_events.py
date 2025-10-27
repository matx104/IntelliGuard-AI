#!/usr/bin/env python3
"""
Sample Security Event Generator
Generates realistic security events for POC demonstration
"""

import json
import time
import random
import logging
from datetime import datetime, timedelta
from elasticsearch import Elasticsearch
from faker import Faker

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

fake = Faker()

class SecurityEventGenerator:
    def __init__(self, es_host='elasticsearch', es_port=9200):
        self.es = Elasticsearch([f'http://{es_host}:{es_port}'])
        self.users = self.generate_users()
        self.attack_scenarios = self.define_attack_scenarios()
        
    def generate_users(self):
        """Generate sample user accounts"""
        users = []
        for i in range(20):
            users.append({
                'username': fake.user_name(),
                'email': fake.email(),
                'department': random.choice(['IT', 'HR', 'Finance', 'Sales', 'Engineering']),
                'risk_level': random.choice(['LOW', 'LOW', 'LOW', 'MEDIUM', 'HIGH'])
            })
        return users
        
    def define_attack_scenarios(self):
        """Define different attack scenario patterns"""
        return {
            'normal_activity': 0.70,  # 70% normal
            'brute_force': 0.10,      # 10% brute force
            'port_scan': 0.08,        # 8% port scanning
            'malware': 0.05,          # 5% malware
            'data_exfiltration': 0.04, # 4% data exfil
            'privilege_escalation': 0.03  # 3% priv esc
        }
        
    def generate_normal_event(self):
        """Generate normal security event"""
        user = random.choice(self.users)
        return {
            '@timestamp': datetime.utcnow().isoformat(),
            'event_type': 'authentication',
            'action': 'login',
            'username': user['username'],
            'source_ip': fake.ipv4_private(),
            'destination_ip': fake.ipv4_private(),
            'status': 'success',
            'failed_logins': 0,
            'packet_count': random.randint(100, 500),
            'byte_count': random.randint(10000, 100000),
            'connection_duration': random.randint(5, 300),
            'port_scan_score': 0,
            'hour': datetime.utcnow().hour,
            'department': user['department'],
            'risk_score': 10
        }
        
    def generate_brute_force_event(self):
        """Generate brute force attack event"""
        user = random.choice(self.users)
        failed_attempts = random.randint(6, 50)
        
        return {
            '@timestamp': datetime.utcnow().isoformat(),
            'event_type': 'authentication',
            'action': 'login',
            'alert_type': 'brute_force_detected',
            'username': user['username'],
            'source_ip': fake.ipv4_public(),
            'destination_ip': fake.ipv4_private(),
            'status': 'failed',
            'failed_logins': failed_attempts,
            'packet_count': failed_attempts * 10,
            'byte_count': failed_attempts * 1000,
            'connection_duration': 1,
            'port_scan_score': 0,
            'hour': datetime.utcnow().hour,
            'unusual_time': datetime.utcnow().hour in [22, 23, 0, 1, 2, 3, 4, 5],
            'new_location': True,
            'soar_processed': False,
            'risk_score': 75
        }
        
    def generate_port_scan_event(self):
        """Generate port scanning event"""
        return {
            '@timestamp': datetime.utcnow().isoformat(),
            'event_type': 'network',
            'action': 'port_scan',
            'alert_type': 'port_scan_detected',
            'source_ip': fake.ipv4_public(),
            'destination_ip': fake.ipv4_private(),
            'unique_ports_accessed': random.randint(25, 100),
            'scan_detected': True,
            'packet_count': random.randint(1000, 5000),
            'byte_count': random.randint(50000, 200000),
            'connection_duration': random.randint(60, 600),
            'port_scan_score': random.randint(60, 100),
            'failed_logins': 0,
            'hour': datetime.utcnow().hour,
            'soar_processed': False,
            'risk_score': 65
        }
        
    def generate_malware_event(self):
        """Generate malware detection event"""
        user = random.choice(self.users)
        return {
            '@timestamp': datetime.utcnow().isoformat(),
            'event_type': 'endpoint',
            'action': 'malware_detection',
            'alert_type': 'malware_detected',
            'username': user['username'],
            'hostname': f'DESKTOP-{fake.random_number(digits=5)}',
            'malware_family': random.choice(['Emotet', 'TrickBot', 'Ransomware', 'Backdoor']),
            'file_hash': fake.sha256(),
            'file_path': f'C:\\Users\\{user["username"]}\\{fake.file_name()}',
            'process_name': random.choice(['explorer.exe', 'svchost.exe', 'rundll32.exe']),
            'severity': random.choice(['HIGH', 'CRITICAL']),
            'packet_count': random.randint(500, 2000),
            'byte_count': random.randint(100000, 1000000),
            'connection_duration': random.randint(10, 120),
            'port_scan_score': 0,
            'failed_logins': 0,
            'hour': datetime.utcnow().hour,
            'soar_processed': False,
            'risk_score': 90
        }
        
    def generate_data_exfiltration_event(self):
        """Generate data exfiltration event"""
        user = random.choice(self.users)
        return {
            '@timestamp': datetime.utcnow().isoformat(),
            'event_type': 'network',
            'action': 'data_transfer',
            'alert_type': 'unusual_data_transfer',
            'username': user['username'],
            'source_ip': fake.ipv4_private(),
            'destination_ip': fake.ipv4_public(),
            'external_destination': True,
            'bytes_transferred': random.randint(1000000000, 10000000000),
            'duration_minutes': random.randint(30, 180),
            'protocol': 'HTTPS',
            'destination_country': random.choice(['CN', 'RU', 'Unknown']),
            'packet_count': random.randint(10000, 50000),
            'byte_count': random.randint(10000000, 100000000),
            'connection_duration': random.randint(1800, 10800),
            'port_scan_score': 0,
            'failed_logins': 0,
            'hour': datetime.utcnow().hour,
            'unusual_time': datetime.utcnow().hour in [22, 23, 0, 1, 2, 3],
            'soar_processed': False,
            'risk_score': 85
        }
        
    def generate_privilege_escalation_event(self):
        """Generate privilege escalation event"""
        user = random.choice(self.users)
        return {
            '@timestamp': datetime.utcnow().isoformat(),
            'event_type': 'access_control',
            'action': 'privilege_escalation',
            'alert_type': 'unauthorized_privilege_elevation',
            'username': user['username'],
            'source_ip': fake.ipv4_private(),
            'target_account': 'Administrator',
            'privilege_requested': 'Domain Admin',
            'authorized': False,
            'method': random.choice(['token_manipulation', 'exploit', 'credential_theft']),
            'packet_count': random.randint(100, 500),
            'byte_count': random.randint(10000, 50000),
            'connection_duration': random.randint(5, 60),
            'port_scan_score': 0,
            'failed_logins': 0,
            'hour': datetime.utcnow().hour,
            'soar_processed': False,
            'risk_score': 95
        }
        
    def generate_event(self):
        """Generate a random event based on scenario probabilities"""
        rand = random.random()
        cumulative = 0
        
        for scenario, probability in self.attack_scenarios.items():
            cumulative += probability
            if rand < cumulative:
                if scenario == 'normal_activity':
                    return self.generate_normal_event()
                elif scenario == 'brute_force':
                    return self.generate_brute_force_event()
                elif scenario == 'port_scan':
                    return self.generate_port_scan_event()
                elif scenario == 'malware':
                    return self.generate_malware_event()
                elif scenario == 'data_exfiltration':
                    return self.generate_data_exfiltration_event()
                elif scenario == 'privilege_escalation':
                    return self.generate_privilege_escalation_event()
                    
        return self.generate_normal_event()
        
    def generate_continuous_events(self):
        """Generate events continuously"""
        logger.info("Starting security event generator...")
        
        event_count = 0
        threat_count = 0
        
        while True:
            try:
                # Wait for Elasticsearch to be ready
                if not self.es.ping():
                    logger.info("Waiting for Elasticsearch...")
                    time.sleep(10)
                    continue
                    
                # Generate batch of events
                batch_size = random.randint(5, 15)
                
                for _ in range(batch_size):
                    event = self.generate_event()
                    self.es.index(index='security-events', document=event)
                    
                    event_count += 1
                    if event.get('alert_type'):
                        threat_count += 1
                        
                if event_count % 50 == 0:
                    logger.info(f"Generated {event_count} events ({threat_count} threats)")
                    
                # Generate events every 10-30 seconds
                time.sleep(random.randint(10, 30))
                
            except Exception as e:
                logger.error(f"Error generating events: {str(e)}")
                time.sleep(10)

if __name__ == '__main__':
    generator = SecurityEventGenerator()
    generator.generate_continuous_events()
