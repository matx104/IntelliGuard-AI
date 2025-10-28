#!/usr/bin/env python3
"""
Bulk Security Event Generator
Generates 500 events of each type for testing and demo purposes
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

class BulkSecurityEventGenerator:
    def __init__(self, es_host='elasticsearch', es_port=9200):
        self.es = Elasticsearch([f'http://{es_host}:{es_port}'])
        self.users = self.generate_users()
        
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
    
    def get_random_timestamp(self, hours_back=24):
        """Generate a random timestamp within the last N hours"""
        now = datetime.utcnow()
        random_hours = random.uniform(0, hours_back)
        return (now - timedelta(hours=random_hours)).isoformat()
        
    def generate_normal_event(self, timestamp=None):
        """Generate normal security event"""
        user = random.choice(self.users)
        return {
            '@timestamp': timestamp or datetime.utcnow().isoformat(),
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
            'hour': datetime.fromisoformat(timestamp or datetime.utcnow().isoformat()).hour,
            'department': user['department'],
            'risk_score': 10
        }
        
    def generate_brute_force_event(self, timestamp=None):
        """Generate brute force attack event"""
        user = random.choice(self.users)
        failed_attempts = random.randint(6, 50)
        ts = timestamp or datetime.utcnow().isoformat()
        
        return {
            '@timestamp': ts,
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
            'hour': datetime.fromisoformat(ts).hour,
            'unusual_time': datetime.fromisoformat(ts).hour in [22, 23, 0, 1, 2, 3, 4, 5],
            'new_location': True,
            'soar_processed': False,
            'risk_score': 75
        }
        
    def generate_port_scan_event(self, timestamp=None):
        """Generate port scanning event"""
        ts = timestamp or datetime.utcnow().isoformat()
        
        return {
            '@timestamp': ts,
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
            'hour': datetime.fromisoformat(ts).hour,
            'soar_processed': False,
            'risk_score': 65
        }
        
    def generate_malware_event(self, timestamp=None):
        """Generate malware detection event"""
        user = random.choice(self.users)
        ts = timestamp or datetime.utcnow().isoformat()
        
        return {
            '@timestamp': ts,
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
            'hour': datetime.fromisoformat(ts).hour,
            'soar_processed': False,
            'risk_score': 90
        }
        
    def generate_data_exfiltration_event(self, timestamp=None):
        """Generate data exfiltration event"""
        user = random.choice(self.users)
        ts = timestamp or datetime.utcnow().isoformat()
        
        return {
            '@timestamp': ts,
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
            'hour': datetime.fromisoformat(ts).hour,
            'unusual_time': datetime.fromisoformat(ts).hour in [22, 23, 0, 1, 2, 3],
            'soar_processed': False,
            'risk_score': 85
        }
        
    def generate_privilege_escalation_event(self, timestamp=None):
        """Generate privilege escalation event"""
        user = random.choice(self.users)
        ts = timestamp or datetime.utcnow().isoformat()
        
        return {
            '@timestamp': ts,
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
            'hour': datetime.fromisoformat(ts).hour,
            'soar_processed': False,
            'risk_score': 95
        }
    
    def generate_bulk_events(self, event_type, count=500, hours_back=24):
        """Generate bulk events of a specific type"""
        events = []
        
        for i in range(count):
            timestamp = self.get_random_timestamp(hours_back)
            
            if event_type == 'normal':
                event = self.generate_normal_event(timestamp)
            elif event_type == 'brute_force':
                event = self.generate_brute_force_event(timestamp)
            elif event_type == 'port_scan':
                event = self.generate_port_scan_event(timestamp)
            elif event_type == 'malware':
                event = self.generate_malware_event(timestamp)
            elif event_type == 'data_exfiltration':
                event = self.generate_data_exfiltration_event(timestamp)
            elif event_type == 'privilege_escalation':
                event = self.generate_privilege_escalation_event(timestamp)
            else:
                continue
                
            # Format for bulk API
            events.append({
                '_index': 'security-events',
                '_source': event
            })
            
        return events
    
    def wait_for_elasticsearch(self):
        """Wait for Elasticsearch to be ready"""
        max_retries = 30
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                if self.es.ping():
                    logger.info("Connected to Elasticsearch successfully")
                    return True
            except Exception as e:
                pass
                
            retry_count += 1
            logger.info(f"Waiting for Elasticsearch... ({retry_count}/{max_retries})")
            time.sleep(5)
            
        logger.error("Failed to connect to Elasticsearch")
        return False
    
    def generate_all_bulk_events(self, events_per_type=500, hours_back=24):
        """Generate 500 events of each type in bulk"""
        
        if not self.wait_for_elasticsearch():
            logger.error("Cannot proceed without Elasticsearch connection")
            return
        
        event_types = {
            'normal': 'Normal Activity',
            'brute_force': 'Brute Force Attacks',
            'port_scan': 'Port Scans',
            'malware': 'Malware Detections',
            'data_exfiltration': 'Data Exfiltration',
            'privilege_escalation': 'Privilege Escalation'
        }
        
        total_events = 0
        
        for event_type, description in event_types.items():
            logger.info(f"\n{'='*60}")
            logger.info(f"Generating {events_per_type} {description} events...")
            logger.info(f"{'='*60}")
            
            try:
                # Generate events
                events = self.generate_bulk_events(event_type, events_per_type, hours_back)
                
                # Insert in batches of 100 for better performance
                batch_size = 100
                for i in range(0, len(events), batch_size):
                    batch = events[i:i+batch_size]
                    success, failed = bulk(self.es, batch, stats_only=True, raise_on_error=False)
                    
                    if failed > 0:
                        logger.warning(f"Failed to insert {failed} events in batch")
                    
                    logger.info(f"Inserted batch {i//batch_size + 1}/{(len(events)-1)//batch_size + 1} - {success} events")
                
                total_events += len(events)
                logger.info(f"✓ Successfully generated {len(events)} {description} events")
                
                # Small delay between event types
                time.sleep(1)
                
            except Exception as e:
                logger.error(f"Error generating {description}: {str(e)}")
        
        logger.info(f"\n{'='*60}")
        logger.info(f"BULK GENERATION COMPLETE!")
        logger.info(f"{'='*60}")
        logger.info(f"Total events generated: {total_events}")
        logger.info(f"Events spread over last {hours_back} hours")
        logger.info(f"Index: security-events")
        
        # Show summary
        self.show_summary()
    
    def show_summary(self):
        """Show summary of generated events"""
        try:
            time.sleep(2)  # Wait for indexing to complete
            
            # Get total count
            total = self.es.count(index='security-events')['count']
            
            # Get threat count
            threats = self.es.count(
                index='security-events',
                body={"query": {"exists": {"field": "alert_type"}}}
            )['count']
            
            logger.info(f"\n{'='*60}")
            logger.info(f"ELASTICSEARCH SUMMARY")
            logger.info(f"{'='*60}")
            logger.info(f"Total events in index: {total}")
            logger.info(f"Total threat events: {threats}")
            logger.info(f"Normal events: {total - threats}")
            logger.info(f"{'='*60}\n")
            
        except Exception as e:
            logger.error(f"Error getting summary: {str(e)}")

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Bulk Security Event Generator')
    parser.add_argument('--count', type=int, default=500, help='Number of events per type (default: 500)')
    parser.add_argument('--hours', type=int, default=24, help='Spread events over N hours (default: 24)')
    parser.add_argument('--host', type=str, default='elasticsearch', help='Elasticsearch host (default: elasticsearch)')
    parser.add_argument('--port', type=int, default=9200, help='Elasticsearch port (default: 9200)')
    
    args = parser.parse_args()
    
    logger.info("="*60)
    logger.info("BULK SECURITY EVENT GENERATOR")
    logger.info("="*60)
    logger.info(f"Events per type: {args.count}")
    logger.info(f"Time spread: {args.hours} hours")
    logger.info(f"Elasticsearch: {args.host}:{args.port}")
    logger.info("="*60)
    
    generator = BulkSecurityEventGenerator(es_host=args.host, es_port=args.port)
    generator.generate_all_bulk_events(events_per_type=args.count, hours_back=args.hours)
