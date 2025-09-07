# IntelliGuard-AI DFIR-IRIS Configurations

Digital Forensics and Incident Response playbooks for IntelliGuard-AI.

## Playbooks

- `incident-response-playbook.json` - Comprehensive 6-phase incident response

## Features

### Investigation Phases
1. **Preparation & Initial Response** (15-30 min)
2. **Threat Identification & Scoping** (1-2 hours)
3. **Threat Containment** (30 min - 2 hours)
4. **Threat Eradication** (2-6 hours)
5. **System Recovery** (2-8 hours)
6. **Post-Incident Analysis** (2-4 hours)

### Supported Incident Types
- Malware infections
- Ransomware attacks
- Data breaches
- Insider threats
- APT campaigns

### Forensic Artifacts
- Windows artifacts (Event logs, Registry, Prefetch)
- Linux artifacts (System logs, Command history)
- Network artifacts (PCAP, Flow records, DNS logs)

### Integration Points
- Wazuh SIEM for automated alert forwarding
- TheHive for case creation and evidence linking
- Shuffle for automated forensic workflow triggers
- Threat intelligence for IOC correlation

## Usage

Import playbooks into DFIR-IRIS via the web interface or API.
Configure integration endpoints in the playbook settings.
