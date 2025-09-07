#!/usr/bin/env python3
"""
IntelliGuard-AI Custom Cortex Responders
Author: AL NAFI AI-Ops Diploma Project
Date: September 2025
Description: Custom responder implementations for automated threat response
"""

import json
import requests
import time
from cortexutils.responder import Responder

class IntelliGuardThreatHunter(Responder):
    """
    Custom responder for automated threat hunting across enterprise infrastructure
    """
    
    def __init__(self):
        Responder.__init__(self)
        self.wazuh_api = self.get_param('config.wazuh_api')
        self.api_key = self.get_param('config.api_key')
        self.hunt_timeframe = self.get_param('config.hunt_timeframe', '7d')
        self.auto_create_cases = self.get_param('config.auto_create_cases', True)
        
    def run(self):
        """
        Execute threat hunting based on observable
        """
        observable = self.get_data()
        observable_type = observable.get('dataType')
        observable_value = observable.get('data')
        
        hunt_results = {
            'hunting_queries': [],
            'matches_found': 0,
            'related_events': [],
            'recommendations': []
        }
        
        try:
            if observable_type == 'ip':
                hunt_results = self._hunt_ip_address(observable_value)
            elif observable_type == 'domain':
                hunt_results = self._hunt_domain(observable_value)
            elif observable_type == 'hash':
                hunt_results = self._hunt_file_hash(observable_value)
            elif observable_type == 'user-account':
                hunt_results = self._hunt_user_account(observable_value)
                
            # Create case if significant findings
            if hunt_results['matches_found'] > 5 and self.auto_create_cases:
                self._create_thehive_case(observable, hunt_results)
                
            self.report({
                'success': True,
                'message': f'Threat hunting completed for {observable_type}: {observable_value}',
                'hunting_results': hunt_results,
                'artifacts': self._extract_artifacts(hunt_results)
            })
            
        except Exception as e:
            self.error(f'Threat hunting failed: {str(e)}')
    
    def _hunt_ip_address(self, ip_address):
        """Hunt for IP address across logs and network data"""
        queries = [
            f'srcip:{ip_address} OR dstip:{ip_address}',
            f'data.srcip:{ip_address} OR data.dstip:{ip_address}',
            f'agent.ip:{ip_address}'
        ]
        
        results = {'hunting_queries': queries, 'matches_found': 0, 'related_events': []}
        
        for query in queries:
            events = self._execute_wazuh_search(query)
            results['related_events'].extend(events)
            results['matches_found'] += len(events)
            
        # Add recommendations based on findings
        if results['matches_found'] > 10:
            results['recommendations'].append('High activity detected - consider host isolation')
        if any('login' in event.get('rule', {}).get('description', '').lower() for event in results['related_events']):
            results['recommendations'].append('Authentication events found - verify user access')
            
        return results
    
    def _hunt_domain(self, domain):
        """Hunt for domain across DNS logs and web traffic"""
        queries = [
            f'url:*{domain}*',
            f'data.url:*{domain}*',
            f'hostname:{domain}'
        ]
        
        results = {'hunting_queries': queries, 'matches_found': 0, 'related_events': []}
        
        for query in queries:
            events = self._execute_wazuh_search(query)
            results['related_events'].extend(events)
            results['matches_found'] += len(events)
            
        # Check for suspicious patterns
        if any('download' in event.get('data', {}).get('url', '').lower() for event in results['related_events']):
            results['recommendations'].append('Download activity detected - analyze files')
            
        return results
    
    def _hunt_file_hash(self, file_hash):
        """Hunt for file hash across endpoint logs"""
        queries = [
            f'data.win.eventdata.hashes:*{file_hash}*',
            f'data.hash:{file_hash}',
            f'syscheck.hash_after:{file_hash}'
        ]
        
        results = {'hunting_queries': queries, 'matches_found': 0, 'related_events': []}
        
        for query in queries:
            events = self._execute_wazuh_search(query)
            results['related_events'].extend(events)
            results['matches_found'] += len(events)
            
        if results['matches_found'] > 0:
            results['recommendations'].append('File hash found in environment - investigate execution context')
            
        return results
    
    def _execute_wazuh_search(self, query):
        """Execute search query against Wazuh API"""
        try:
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            search_data = {
                'query': query,
                'timeframe': self.hunt_timeframe,
                'size': 100
            }
            
            response = requests.post(
                f'{self.wazuh_api}/security/search',
                headers=headers,
                json=search_data,
                timeout=30
            )
            
            if response.status_code == 200:
                return response.json().get('data', {}).get('hits', [])
            else:
                return []
                
        except Exception as e:
            self.error(f'Wazuh search failed: {str(e)}')
            return []
    
    def _create_thehive_case(self, observable, hunt_results):
        """Create case in TheHive for significant findings"""
        try:
            case_data = {
                'title': f'Threat Hunting: {observable["dataType"]} - {observable["data"]}',
                'description': f'Automated threat hunting found {hunt_results["matches_found"]} related events',
                'severity': 2 if hunt_results['matches_found'] > 20 else 1,
                'tags': ['threat-hunting', 'automated', 'intelliguard-ai'],
                'customFields': {
                    'huntingResults': json.dumps(hunt_results)
                }
            }
            # Implementation would call TheHive API here
            pass
        except Exception as e:
            self.error(f'Case creation failed: {str(e)}')
    
    def _extract_artifacts(self, hunt_results):
        """Extract artifacts from hunting results"""
        artifacts = []
        for event in hunt_results.get('related_events', []):
            # Extract IPs, domains, etc. from events
            if 'srcip' in event.get('data', {}):
                artifacts.append({
                    'type': 'ip',
                    'value': event['data']['srcip'],
                    'source': 'threat_hunting'
                })
        return artifacts


class IntelliGuardIOCBlocker(Responder):
    """
    Custom responder for blocking malicious indicators at network level
    """
    
    def __init__(self):
        Responder.__init__(self)
        self.firewall_api = self.get_param('config.firewall_api')
        self.dns_server = self.get_param('config.dns_server')
        self.api_key = self.get_param('config.api_key')
        self.auto_block = self.get_param('config.auto_block', False)
        
    def run(self):
        """
        Block malicious indicator at network level
        """
        observable = self.get_data()
        observable_type = observable.get('dataType')
        observable_value = observable.get('data')
        
        block_results = {
            'blocked': False,
            'block_type': None,
            'block_location': [],
            'error_message': None
        }
        
        try:
            if observable_type == 'ip':
                block_results = self._block_ip_address(observable_value)
            elif observable_type == 'domain':
                block_results = self._block_domain(observable_value)
            elif observable_type == 'url':
                block_results = self._block_url(observable_value)
                
            self.report({
                'success': True,
                'message': f'IOC blocking completed for {observable_type}: {observable_value}',
                'block_results': block_results
            })
            
        except Exception as e:
            self.error(f'IOC blocking failed: {str(e)}')
    
    def _block_ip_address(self, ip_address):
        """Block IP address at firewall"""
        try:
            if self.auto_block:
                # Add firewall rule
                rule_data = {
                    'action': 'deny',
                    'source': ip_address,
                    'destination': 'any',
                    'description': f'IntelliGuard-AI auto-block: {ip_address}'
                }
                
                response = self._call_firewall_api('/rules', rule_data)
                
                return {
                    'blocked': response.get('success', False),
                    'block_type': 'firewall',
                    'block_location': ['perimeter_firewall'],
                    'rule_id': response.get('rule_id')
                }
            else:
                return {
                    'blocked': False,
                    'block_type': 'manual_approval_required',
                    'block_location': [],
                    'message': 'Auto-blocking disabled, manual approval required'
                }
        except Exception as e:
            return {
                'blocked': False,
                'error_message': str(e)
            }
    
    def _block_domain(self, domain):
        """Block domain at DNS level"""
        try:
            if self.auto_block:
                # Add DNS sinkhole
                dns_data = {
                    'domain': domain,
                    'action': 'sinkhole',
                    'redirect_ip': '127.0.0.1',
                    'description': f'IntelliGuard-AI auto-block: {domain}'
                }
                
                response = self._call_dns_api('/sinkhole', dns_data)
                
                return {
                    'blocked': response.get('success', False),
                    'block_type': 'dns_sinkhole',
                    'block_location': ['internal_dns'],
                    'sinkhole_id': response.get('sinkhole_id')
                }
            else:
                return {
                    'blocked': False,
                    'block_type': 'manual_approval_required',
                    'block_location': []
                }
        except Exception as e:
            return {
                'blocked': False,
                'error_message': str(e)
            }
    
    def _call_firewall_api(self, endpoint, data):
        """Call firewall API"""
        headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }
        
        response = requests.post(
            f'{self.firewall_api}{endpoint}',
            headers=headers,
            json=data,
            timeout=30
        )
        
        return response.json() if response.status_code == 200 else {}
    
    def _call_dns_api(self, endpoint, data):
        """Call DNS server API"""
        headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }
        
        response = requests.post(
            f'{self.dns_server}{endpoint}',
            headers=headers,
            json=data,
            timeout=30
        )
        
        return response.json() if response.status_code == 200 else {}


class IntelliGuardHostIsolator(Responder):
    """
    Custom responder for isolating compromised hosts
    """
    
    def __init__(self):
        Responder.__init__(self)
        self.edr_api = self.get_param('config.isolation_api')
        self.api_key = self.get_param('config.api_key')
        self.isolation_type = self.get_param('config.isolation_type', 'quarantine')
        self.auto_isolate = self.get_param('config.auto_isolate', False)
        
    def run(self):
        """
        Isolate compromised host from network
        """
        observable = self.get_data()
        
        if observable.get('dataType') != 'ip':
            self.error('Host isolation requires IP address observable')
            return
            
        ip_address = observable.get('data')
        
        isolation_results = {
            'isolated': False,
            'isolation_type': self.isolation_type,
            'host_info': {},
            'isolation_id': None
        }
        
        try:
            # Get host information
            host_info = self._get_host_info(ip_address)
            isolation_results['host_info'] = host_info
            
            if self.auto_isolate and host_info:
                # Perform isolation
                isolation_response = self._isolate_host(host_info.get('host_id'))
                isolation_results.update(isolation_response)
                
            self.report({
                'success': True,
                'message': f'Host isolation completed for {ip_address}',
                'isolation_results': isolation_results
            })
            
        except Exception as e:
            self.error(f'Host isolation failed: {str(e)}')
    
    def _get_host_info(self, ip_address):
        """Get host information from EDR system"""
        try:
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            response = requests.get(
                f'{self.edr_api}/hosts?ip={ip_address}',
                headers=headers,
                timeout=30
            )
            
            if response.status_code == 200:
                hosts = response.json().get('data', [])
                return hosts[0] if hosts else {}
            else:
                return {}
                
        except Exception as e:
            self.error(f'Failed to get host info: {str(e)}')
            return {}
    
    def _isolate_host(self, host_id):
        """Isolate host using EDR API"""
        try:
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            isolation_data = {
                'host_id': host_id,
                'isolation_type': self.isolation_type,
                'reason': 'IntelliGuard-AI automated isolation',
                'duration': 3600  # 1 hour default
            }
            
            response = requests.post(
                f'{self.edr_api}/hosts/{host_id}/isolate',
                headers=headers,
                json=isolation_data,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                return {
                    'isolated': True,
                    'isolation_id': result.get('isolation_id'),
                    'estimated_duration': isolation_data['duration']
                }
            else:
                return {
                    'isolated': False,
                    'error_message': f'EDR API error: {response.status_code}'
                }
                
        except Exception as e:
            return {
                'isolated': False,
                'error_message': str(e)
            }


class IntelliGuardAccountDisabler(Responder):
    """
    Custom responder for disabling compromised user accounts
    """
    
    def __init__(self):
        Responder.__init__(self)
        self.ad_server = self.get_param('config.ad_server')
        self.service_account = self.get_param('config.service_account')
        self.password = self.get_param('config.password')
        self.auto_disable = self.get_param('config.auto_disable', False)
        self.backup_groups = self.get_param('config.backup_groups', True)
        
    def run(self):
        """
        Disable compromised user account
        """
        observable = self.get_data()
        
        if observable.get('dataType') != 'user-account':
            self.error('Account disabling requires user-account observable')
            return
            
        username = observable.get('data')
        
        disable_results = {
            'disabled': False,
            'account_info': {},
            'groups_backed_up': False,
            'disable_timestamp': None
        }
        
        try:
            # Get account information
            account_info = self._get_account_info(username)
            disable_results['account_info'] = account_info
            
            if self.auto_disable and account_info:
                # Backup group memberships
                if self.backup_groups:
                    self._backup_group_memberships(username, account_info)
                    disable_results['groups_backed_up'] = True
                
                # Disable account
                disable_response = self._disable_account(username)
                disable_results.update(disable_response)
                
            self.report({
                'success': True,
                'message': f'Account disabling completed for {username}',
                'disable_results': disable_results
            })
            
        except Exception as e:
            self.error(f'Account disabling failed: {str(e)}')
    
    def _get_account_info(self, username):
        """Get account information from Active Directory"""
        try:
            import ldap3
            from ldap3 import Server, Connection, ALL
            
            server = Server(self.ad_server, get_info=ALL)
            conn = Connection(server, user=self.service_account, password=self.password, auto_bind=True)
            
            search_base = 'DC=company,DC=local'  # Adjust for your domain
            search_filter = f'(sAMAccountName={username})'
            
            conn.search(search_base, search_filter, attributes=['*'])
            
            if conn.entries:
                entry = conn.entries[0]
                return {
                    'dn': str(entry.entry_dn),
                    'display_name': str(entry.displayName) if hasattr(entry, 'displayName') else '',
                    'email': str(entry.mail) if hasattr(entry, 'mail') else '',
                    'groups': [str(group) for group in entry.memberOf] if hasattr(entry, 'memberOf') else [],
                    'account_status': 'enabled' if not (entry.userAccountControl.value & 2) else 'disabled'
                }
            else:
                return {}
                
        except Exception as e:
            self.error(f'Failed to get account info: {str(e)}')
            return {}
    
    def _backup_group_memberships(self, username, account_info):
        """Backup user's group memberships"""
        try:
            backup_data = {
                'username': username,
                'timestamp': time.time(),
                'groups': account_info.get('groups', []),
                'backup_reason': 'IntelliGuard-AI security incident'
            }
            
            # Store backup (implementation depends on your backup system)
            # This could be a database, file system, or API call
            with open(f'/opt/intelliguard/backups/user_groups_{username}_{int(time.time())}.json', 'w') as f:
                json.dump(backup_data, f, indent=2)
                
        except Exception as e:
            self.error(f'Failed to backup group memberships: {str(e)}')
    
    def _disable_account(self, username):
        """Disable user account in Active Directory"""
        try:
            import ldap3
            from ldap3 import Server, Connection, ALL, MODIFY_REPLACE
            
            server = Server(self.ad_server, get_info=ALL)
            conn = Connection(server, user=self.service_account, password=self.password, auto_bind=True)
            
            # Find user DN
            search_base = 'DC=company,DC=local'
            search_filter = f'(sAMAccountName={username})'
            conn.search(search_base, search_filter, attributes=['distinguishedName'])
            
            if conn.entries:
                user_dn = str(conn.entries[0].entry_dn)
                
                # Disable account (set userAccountControl bit 2)
                changes = {
                    'userAccountControl': [(MODIFY_REPLACE, [514])]  # 512 + 2 = 514 (normal account + disabled)
                }
                
                if conn.modify(user_dn, changes):
                    return {
                        'disabled': True,
                        'disable_timestamp': time.time(),
                        'user_dn': user_dn
                    }
                else:
                    return {
                        'disabled': False,
                        'error_message': 'Failed to modify account'
                    }
            else:
                return {
                    'disabled': False,
                    'error_message': 'User not found'
                }
                
        except Exception as e:
            return {
                'disabled': False,
                'error_message': str(e)
            }


class IntelliGuardMITREMapper(Responder):
    """
    Custom responder for mapping observables to MITRE ATT&CK techniques
    """
    
    def __init__(self):
        Responder.__init__(self)
        self.mitre_db = self.get_param('config.mitre_db')
        
    def run(self):
        """
        Map observable to MITRE ATT&CK techniques
        """
        observable = self.get_data()
        
        mapping_results = {
            'techniques': [],
            'tactics': [],
            'confidence_score': 0.0,
            'mapping_source': 'IntelliGuard-AI'
        }
        
        try:
            # Perform MITRE mapping based on observable type and context
            if observable.get('dataType') == 'file':
                mapping_results = self._map_file_to_mitre(observable)
            elif observable.get('dataType') == 'ip':
                mapping_results = self._map_ip_to_mitre(observable)
            elif observable.get('dataType') == 'domain':
                mapping_results = self._map_domain_to_mitre(observable)
            
            self.report({
                'success': True,
                'message': f'MITRE mapping completed',
                'mitre_mapping': mapping_results
            })
            
        except Exception as e:
            self.error(f'MITRE mapping failed: {str(e)}')
    
    def _map_file_to_mitre(self, observable):
        """Map file observable to MITRE techniques"""
        # Simplified mapping logic - in practice, this would use ML or rule-based mapping
        techniques = []
        tactics = []
        
        file_data = observable.get('data', '')
        
        # Example mappings based on file characteristics
        if any(ext in file_data.lower() for ext in ['.exe', '.dll', '.scr']):
            techniques.append('T1204.002')  # Malicious File Execution
            tactics.append('Execution')
            
        if 'temp' in file_data.lower() or 'appdata' in file_data.lower():
            techniques.append('T1036')  # Masquerading
            tactics.append('Defense Evasion')
            
        return {
            'techniques': techniques,
            'tactics': list(set(tactics)),
            'confidence_score': 0.7 if techniques else 0.0,
            'mapping_source': 'pattern_matching'
        }
    
    def _map_ip_to_mitre(self, observable):
        """Map IP observable to MITRE techniques"""
        techniques = []
        tactics = []
        
        # External IPs might indicate C2 communication
        ip_data = observable.get('data', '')
        
        # Simple classification - in practice, use threat intel and context
        techniques.append('T1071')  # Application Layer Protocol
        tactics.append('Command and Control')
        
        return {
            'techniques': techniques,
            'tactics': tactics,
            'confidence_score': 0.6,
            'mapping_source': 'behavioral_analysis'
        }
    
    def _map_domain_to_mitre(self, observable):
        """Map domain observable to MITRE techniques"""
        techniques = []
        tactics = []
        
        domain_data = observable.get('data', '')
        
        # DGA-like domains
        if len(domain_data) > 15 and any(c.isdigit() for c in domain_data):
            techniques.append('T1568.002')  # Domain Generation Algorithms
            tactics.append('Command and Control')
            
        return {
            'techniques': techniques,
            'tactics': tactics,
            'confidence_score': 0.5,
            'mapping_source': 'heuristic_analysis'
        }


if __name__ == '__main__':
    # Example usage and testing
    print("IntelliGuard-AI Custom Cortex Responders")
    print("Available responders:")
    print("- IntelliGuardThreatHunter: Automated threat hunting")
    print("- IntelliGuardIOCBlocker: Network-level IOC blocking")
    print("- IntelliGuardHostIsolator: Host isolation")
    print("- IntelliGuardAccountDisabler: Account disabling")
    print("- IntelliGuardMITREMapper: MITRE ATT&CK mapping")