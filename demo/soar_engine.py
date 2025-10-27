#!/usr/bin/env python3
"""
SOAR Automation Engine
Implements automated incident response playbooks and orchestration
"""

import json
import time
import logging
from datetime import datetime
from elasticsearch import Elasticsearch
import requests

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class SOAREngine:
    def __init__(self):
        self.es = Elasticsearch(['http://elasticsearch:9200'])
        self.playbooks = self.load_playbooks()
        self.action_history = []
        
    def load_playbooks(self):
        """Load automated incident response playbooks"""
        return {
            'brute_force_response': {
                'name': 'Brute Force Attack Response',
                'trigger': 'failed_login_threshold_exceeded',
                'actions': [
                    {'action': 'block_source_ip', 'priority': 1},
                    {'action': 'notify_soc_team', 'priority': 2},
                    {'action': 'reset_user_password', 'priority': 3},
                    {'action': 'enable_mfa', 'priority': 4},
                    {'action': 'create_incident_ticket', 'priority': 5}
                ],
                'severity': 'HIGH'
            },
            'malware_detection_response': {
                'name': 'Malware Detection Response',
                'trigger': 'malware_detected',
                'actions': [
                    {'action': 'isolate_endpoint', 'priority': 1},
                    {'action': 'kill_malicious_process', 'priority': 2},
                    {'action': 'collect_forensic_artifacts', 'priority': 3},
                    {'action': 'scan_network_for_spread', 'priority': 4},
                    {'action': 'notify_incident_response_team', 'priority': 5}
                ],
                'severity': 'CRITICAL'
            },
            'data_exfiltration_response': {
                'name': 'Data Exfiltration Response',
                'trigger': 'unusual_data_transfer',
                'actions': [
                    {'action': 'block_outbound_connection', 'priority': 1},
                    {'action': 'suspend_user_account', 'priority': 2},
                    {'action': 'analyze_transferred_data', 'priority': 3},
                    {'action': 'notify_security_leadership', 'priority': 4},
                    {'action': 'initiate_forensic_investigation', 'priority': 5}
                ],
                'severity': 'CRITICAL'
            },
            'port_scan_response': {
                'name': 'Port Scan Detection Response',
                'trigger': 'port_scan_detected',
                'actions': [
                    {'action': 'log_scanning_activity', 'priority': 1},
                    {'action': 'rate_limit_source', 'priority': 2},
                    {'action': 'add_to_watchlist', 'priority': 3},
                    {'action': 'alert_network_team', 'priority': 4}
                ],
                'severity': 'MEDIUM'
            },
            'privilege_escalation_response': {
                'name': 'Privilege Escalation Response',
                'trigger': 'unauthorized_privilege_elevation',
                'actions': [
                    {'action': 'revoke_elevated_privileges', 'priority': 1},
                    {'action': 'suspend_account', 'priority': 2},
                    {'action': 'audit_access_logs', 'priority': 3},
                    {'action': 'check_lateral_movement', 'priority': 4},
                    {'action': 'escalate_to_incident_response', 'priority': 5}
                ],
                'severity': 'HIGH'
            }
        }
        
    def execute_action(self, action, alert_context):
        """Execute a specific SOAR action"""
        action_name = action['action']
        
        logger.info(f"Executing action: {action_name}")
        
        # Simulate action execution
        action_result = {
            'action': action_name,
            'timestamp': datetime.utcnow().isoformat(),
            'status': 'SUCCESS',
            'context': alert_context
        }
        
        # Action implementations (simulated)
        if action_name == 'block_source_ip':
            result = self.block_source_ip(alert_context.get('source_ip'))
            action_result['details'] = result
            
        elif action_name == 'isolate_endpoint':
            result = self.isolate_endpoint(alert_context.get('hostname'))
            action_result['details'] = result
            
        elif action_name == 'suspend_user_account':
            result = self.suspend_user_account(alert_context.get('username'))
            action_result['details'] = result
            
        elif action_name == 'notify_soc_team':
            result = self.send_notification('SOC Team', alert_context)
            action_result['details'] = result
            
        elif action_name == 'collect_forensic_artifacts':
            result = self.collect_forensic_data(alert_context)
            action_result['details'] = result
            
        elif action_name == 'create_incident_ticket':
            result = self.create_incident_ticket(alert_context)
            action_result['details'] = result
            
        else:
            action_result['details'] = f"Action {action_name} simulated"
            
        # Store action in history
        self.action_history.append(action_result)
        self.es.index(index='soar-actions', document=action_result)
        
        return action_result
        
    def block_source_ip(self, ip_address):
        """Block a source IP address"""
        return {
            'blocked_ip': ip_address,
            'method': 'firewall_rule',
            'duration': 'permanent',
            'status': 'blocked'
        }
        
    def isolate_endpoint(self, hostname):
        """Isolate an endpoint from the network"""
        return {
            'hostname': hostname,
            'isolation_method': 'network_quarantine',
            'status': 'isolated',
            'allow_list': ['soc_management_network']
        }
        
    def suspend_user_account(self, username):
        """Suspend a user account"""
        return {
            'username': username,
            'action': 'account_suspended',
            'requires_review': True,
            'status': 'suspended'
        }
        
    def send_notification(self, recipient, context):
        """Send notification to team"""
        return {
            'recipient': recipient,
            'method': 'email_and_slack',
            'priority': context.get('severity', 'MEDIUM'),
            'sent': True
        }
        
    def collect_forensic_data(self, context):
        """Collect forensic artifacts"""
        return {
            'artifacts_collected': [
                'memory_dump',
                'disk_image',
                'network_pcap',
                'process_list',
                'registry_hives'
            ],
            'storage_location': f"/forensics/{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}",
            'hash_calculated': True
        }
        
    def create_incident_ticket(self, context):
        """Create incident ticket in TheHive"""
        return {
            'ticket_id': f"INC-{int(time.time())}",
            'title': context.get('alert_type', 'Security Incident'),
            'severity': context.get('severity', 'MEDIUM'),
            'assigned_to': 'SOC_L1',
            'status': 'open'
        }
        
    def execute_playbook(self, playbook_name, alert_context):
        """Execute a complete playbook"""
        if playbook_name not in self.playbooks:
            logger.error(f"Playbook '{playbook_name}' not found")
            return None
            
        playbook = self.playbooks[playbook_name]
        logger.info(f"Executing playbook: {playbook['name']}")
        
        execution_log = {
            'playbook_name': playbook['name'],
            'start_time': datetime.utcnow().isoformat(),
            'alert_context': alert_context,
            'actions_executed': []
        }
        
        # Execute actions in priority order
        sorted_actions = sorted(playbook['actions'], key=lambda x: x['priority'])
        
        for action in sorted_actions:
            try:
                result = self.execute_action(action, alert_context)
                execution_log['actions_executed'].append(result)
                time.sleep(1)  # Simulate action execution time
                
            except Exception as e:
                logger.error(f"Error executing action {action['action']}: {str(e)}")
                execution_log['actions_executed'].append({
                    'action': action['action'],
                    'status': 'FAILED',
                    'error': str(e)
                })
                
        execution_log['end_time'] = datetime.utcnow().isoformat()
        execution_log['status'] = 'COMPLETED'
        
        # Store playbook execution
        self.es.index(index='playbook-executions', document=execution_log)
        
        return execution_log
        
    def match_alert_to_playbook(self, alert):
        """Match an alert to appropriate playbook"""
        alert_type = alert.get('alert_type', '').lower()
        
        playbook_mappings = {
            'brute_force': 'brute_force_response',
            'failed_login': 'brute_force_response',
            'malware': 'malware_detection_response',
            'virus': 'malware_detection_response',
            'data_exfiltration': 'data_exfiltration_response',
            'unusual_transfer': 'data_exfiltration_response',
            'port_scan': 'port_scan_response',
            'network_scan': 'port_scan_response',
            'privilege_escalation': 'privilege_escalation_response',
            'unauthorized_access': 'privilege_escalation_response'
        }
        
        for keyword, playbook in playbook_mappings.items():
            if keyword in alert_type:
                return playbook
                
        return None
        
    def process_alerts(self):
        """Main alert processing loop"""
        logger.info("Starting SOAR automation engine...")
        
        while True:
            try:
                # Query for new alerts
                query = {
                    "query": {
                        "bool": {
                            "must": [
                                {"range": {"@timestamp": {"gte": "now-2m"}}},
                                {"term": {"soar_processed": False}}
                            ]
                        }
                    },
                    "size": 20
                }
                
                # Check multiple alert indices
                for index in ['threat-alerts', 'ueba-alerts', 'attack-chains']:
                    if not self.es.indices.exists(index=index):
                        continue
                        
                    try:
                        response = self.es.search(index=index, body=query)
                        hits = response['hits']['hits']
                        
                        logger.info(f"Processing {len(hits)} alerts from {index}")
                        
                        for hit in hits:
                            alert = hit['_source']
                            alert_id = hit['_id']
                            
                            # Match alert to playbook
                            playbook_name = self.match_alert_to_playbook(alert)
                            
                            if playbook_name:
                                logger.info(f"Matched alert to playbook: {playbook_name}")
                                
                                # Execute playbook
                                execution_result = self.execute_playbook(
                                    playbook_name,
                                    alert
                                )
                                
                                # Mark alert as processed
                                self.es.update(
                                    index=index,
                                    id=alert_id,
                                    body={
                                        "doc": {
                                            "soar_processed": True,
                                            "playbook_executed": playbook_name,
                                            "execution_time": datetime.utcnow().isoformat()
                                        }
                                    }
                                )
                                
                            else:
                                logger.info(f"No playbook match for alert type: {alert.get('alert_type')}")
                                
                    except Exception as e:
                        logger.error(f"Error processing alerts from {index}: {str(e)}")
                        
            except Exception as e:
                logger.error(f"Error in SOAR processing loop: {str(e)}")
                
            # Check for alerts every 30 seconds
            time.sleep(30)

if __name__ == '__main__':
    soar = SOAREngine()
    soar.process_alerts()
