#!/usr/bin/env python3
"""
Automated Threat Hunting Service
Implements automated threat hunting workflows with MITRE ATT&CK mapping
"""

import json
import time
import logging
from datetime import datetime, timedelta
from elasticsearch import Elasticsearch
import requests

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class AutomatedThreatHunter:
    def __init__(self, es_host='elasticsearch', es_port=9200):
        self.es = Elasticsearch([f'http://{es_host}:{es_port}'])
        self.mitre_techniques = self.load_mitre_techniques()
        self.hunting_queries = self.define_hunting_queries()
        
    def load_mitre_techniques(self):
        """Load MITRE ATT&CK technique mappings"""
        return {
            'T1110': {
                'name': 'Brute Force',
                'tactic': 'Credential Access',
                'detection_query': 'failed_logins > 5'
            },
            'T1078': {
                'name': 'Valid Accounts',
                'tactic': 'Defense Evasion',
                'detection_query': 'unusual_login_time OR unusual_location'
            },
            'T1046': {
                'name': 'Network Service Scanning',
                'tactic': 'Discovery',
                'detection_query': 'port_scan_detected'
            },
            'T1071': {
                'name': 'Application Layer Protocol',
                'tactic': 'Command and Control',
                'detection_query': 'suspicious_c2_traffic'
            },
            'T1486': {
                'name': 'Data Encrypted for Impact',
                'tactic': 'Impact',
                'detection_query': 'ransomware_indicators'
            }
        }
        
    def define_hunting_queries(self):
        """Define automated hunting queries"""
        return [
            {
                'name': 'Suspicious Login Patterns',
                'description': 'Hunt for unusual login activities',
                'query': {
                    "bool": {
                        "should": [
                            {"range": {"failed_logins": {"gte": 5}}},
                            {"term": {"unusual_time": True}},
                            {"term": {"new_location": True}}
                        ],
                        "minimum_should_match": 1
                    }
                },
                'mitre_technique': 'T1110'
            },
            {
                'name': 'Network Reconnaissance',
                'description': 'Hunt for port scanning and network discovery',
                'query': {
                    "bool": {
                        "should": [
                            {"range": {"unique_ports_accessed": {"gte": 20}}},
                            {"term": {"scan_detected": True}}
                        ]
                    }
                },
                'mitre_technique': 'T1046'
            },
            {
                'name': 'Privilege Escalation Attempts',
                'description': 'Hunt for unauthorized privilege elevation',
                'query': {
                    "bool": {
                        "must": [
                            {"term": {"action": "privilege_escalation"}},
                            {"term": {"authorized": False}}
                        ]
                    }
                },
                'mitre_technique': 'T1078'
            },
            {
                'name': 'Data Exfiltration Indicators',
                'description': 'Hunt for unusual data transfer patterns',
                'query': {
                    "bool": {
                        "should": [
                            {"range": {"bytes_transferred": {"gte": 1000000000}}},
                            {"term": {"external_destination": True}}
                        ]
                    }
                },
                'mitre_technique': 'T1071'
            }
        ]
        
    def hunt_threats(self, hunting_query):
        """Execute a hunting query and return findings"""
        try:
            query_body = {
                "query": hunting_query['query'],
                "size": 50,
                "sort": [{"@timestamp": "desc"}]
            }
            
            response = self.es.search(index='security-events', body=query_body)
            hits = response['hits']['hits']
            
            findings = []
            for hit in hits:
                event = hit['_source']
                finding = {
                    'timestamp': event.get('@timestamp'),
                    'event_data': event,
                    'hunt_name': hunting_query['name'],
                    'mitre_technique': hunting_query['mitre_technique'],
                    'technique_details': self.mitre_techniques.get(
                        hunting_query['mitre_technique'], {}
                    )
                }
                findings.append(finding)
                
            return findings
            
        except Exception as e:
            logger.error(f"Error executing hunt '{hunting_query['name']}': {str(e)}")
            return []
            
    def create_hunting_case(self, findings, query_name):
        """Create a case in TheHive for hunting findings"""
        if not findings:
            return None
            
        case_data = {
            'title': f'Threat Hunt: {query_name}',
            'description': f'Automated threat hunt found {len(findings)} suspicious events',
            'severity': self.calculate_case_severity(findings),
            'tags': ['threat-hunting', 'automated'],
            'tlp': 2,  # TLP:AMBER
            'pap': 2,  # PAP:AMBER
            'customFields': {
                'mitre-techniques': list(set(f['mitre_technique'] for f in findings)),
                'finding-count': len(findings)
            }
        }
        
        return case_data
        
    def calculate_case_severity(self, findings):
        """Calculate case severity based on findings"""
        high_risk_techniques = ['T1486', 'T1071']
        
        for finding in findings:
            if finding['mitre_technique'] in high_risk_techniques:
                return 3  # Critical
                
        if len(findings) > 10:
            return 2  # High
        elif len(findings) > 5:
            return 1  # Medium
        else:
            return 0  # Low
            
    def analyze_iocs(self, event):
        """Extract and analyze Indicators of Compromise"""
        iocs = {
            'ip_addresses': [],
            'domains': [],
            'file_hashes': [],
            'urls': []
        }
        
        # Extract IOCs from event
        if 'source_ip' in event:
            iocs['ip_addresses'].append(event['source_ip'])
        if 'destination_ip' in event:
            iocs['ip_addresses'].append(event['destination_ip'])
        if 'domain' in event:
            iocs['domains'].append(event['domain'])
        if 'file_hash' in event:
            iocs['file_hashes'].append(event['file_hash'])
            
        return iocs
        
    def correlate_events(self, findings):
        """Correlate multiple findings to identify attack patterns"""
        correlations = {}
        
        for finding in findings:
            key = f"{finding['event_data'].get('source_ip', 'unknown')}"
            if key not in correlations:
                correlations[key] = []
            correlations[key].append(finding)
            
        # Identify multi-stage attacks
        attack_chains = []
        for source, events in correlations.items():
            if len(events) >= 3:
                techniques = [e['mitre_technique'] for e in events]
                attack_chains.append({
                    'source': source,
                    'technique_count': len(set(techniques)),
                    'techniques': list(set(techniques)),
                    'event_count': len(events),
                    'severity': 'HIGH' if len(set(techniques)) >= 3 else 'MEDIUM'
                })
                
        return attack_chains
        
    def run_hunting_cycle(self):
        """Execute complete hunting cycle"""
        logger.info("Starting automated threat hunting cycle...")
        
        all_findings = []
        
        for hunting_query in self.hunting_queries:
            logger.info(f"Executing hunt: {hunting_query['name']}")
            
            findings = self.hunt_threats(hunting_query)
            
            if findings:
                logger.info(f"Hunt '{hunting_query['name']}' found {len(findings)} suspicious events")
                all_findings.extend(findings)
                
                # Store findings in Elasticsearch
                for finding in findings:
                    finding['hunt_cycle_id'] = datetime.utcnow().isoformat()
                    self.es.index(index='threat-hunting-findings', document=finding)
                    
        # Correlate findings across hunts
        if all_findings:
            attack_chains = self.correlate_events(all_findings)
            
            for chain in attack_chains:
                logger.warning(f"Attack chain detected from {chain['source']}: "
                             f"{chain['technique_count']} techniques, "
                             f"{chain['event_count']} events")
                             
                # Store attack chain
                chain['@timestamp'] = datetime.utcnow().isoformat()
                chain['type'] = 'attack_chain'
                self.es.index(index='attack-chains', document=chain)
                
        logger.info(f"Hunting cycle complete. Total findings: {len(all_findings)}")
        return all_findings
        
    def continuous_hunting(self):
        """Main hunting loop"""
        logger.info("Starting continuous threat hunting service...")
        
        while True:
            try:
                # Check if indices exist
                if not self.es.indices.exists(index='security-events'):
                    logger.info("Waiting for security events...")
                    time.sleep(30)
                    continue
                    
                findings = self.run_hunting_cycle()
                
                # Generate hunting report
                report = {
                    '@timestamp': datetime.utcnow().isoformat(),
                    'cycle_duration_minutes': 5,
                    'total_findings': len(findings),
                    'hunts_executed': len(self.hunting_queries),
                    'mitre_techniques_detected': list(set(
                        f['mitre_technique'] for f in findings
                    ))
                }
                
                self.es.index(index='hunting-reports', document=report)
                
            except Exception as e:
                logger.error(f"Error in hunting cycle: {str(e)}")
                
            # Run hunting every 5 minutes
            time.sleep(300)

if __name__ == '__main__':
    hunter = AutomatedThreatHunter()
    hunter.continuous_hunting()
