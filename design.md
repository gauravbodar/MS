ok here are my questions i need answers to to create the design
Based on the sources and our conversation, the design document provides a comprehensive framework and architectural plan for the Azure landing zone. However, it explicitly identifies areas where specific departmental input is essential to move from the design phase to actual implementation and achieve completeness.
Here is a list of questions that are currently lacking specific answers in the document but are fundamental to enabling the completeness of this design and proceeding with the build:
General Planning & Strategy:
What is the specific list of server workloads, their functions, criticality, and dependencies that need to be migrated or integrated?
What are the detailed data classification requirements for the data that will reside in Azure?
What are the department's specific business continuity and disaster recovery needs and requirements (RTO/RPO)?
What are the specific workloads and their migration priorities?
What are the required downtime windows and migration schedules for specific applications?
 
Governance & Compliance:
What is the specific Management Group hierarchy structure that aligns with the department's organizational structure and desired policy/governance boundaries? (While an example is provided, the department must confirm or define their specific hierarchy).
What is the exact list of allowed Azure regions that resources can be deployed into?
What is the exact list of allowed SKUs (e.g., VM sizes, database tiers) for various resource types?
What is the required Information Security Manual (ISM) level and Essential Eight maturity level that the environment must adhere to?
What are the specific compliance requirements, policies, and audit requirements beyond the standard ISM/Essential Eight frameworks?
What are the department's specific governance policies and escalation paths for non-compliance or incidents?
What are the department's specific change management processes that must be integrated into the cloud operations?
What are the specific cost management requirements, including chargeback/showback models?...
What are the tagging standards that must be enforced for resource groups and resources?...
What is the policy definition ID for the official ISM/Essential Eight policy set to be assigned?
 
Identity & Access Management:
What are the specific user roles and group memberships that need to be configured in Azure AD and synchronized from on-premises?
What are the detailed requirements for privileged access needs and their corresponding PIM configurations?
How should Azure AD Conditional Access policies be specifically configured for government-grade authentication, including PIV card integration requirements?
 
Networking:
What is the department's complete and detailed IP addressing scheme to be used in Azure (VNet ranges, subnet ranges)?
What is the required number and purpose of subnets within the VNets (e.g., DMZ replacement, application tiers, management, migration)?
What are the detailed network requirements for the servers/workloads to be migrated (e.g., specific ports, protocols, dependencies)?
Which public endpoints need DDoS Protection Standard enabled?
 
Security:
What are the specific security operations contacts and their roles in monitoring and incident response?
What are the detailed backup and retention policies for different types of data and workloads
What are the specific details required for SIEM integration, including the SIEM endpoint details if it's not Azure Sentinel, and log access policies
What are the specific list of secrets, keys, and certificates that need to be secured in Azure Key Vault for workloads?
What are the specific requirements for Azure Key Vault HSM integration for FIPS 140-2 Level 3 compliance?
What are the specific requirements for Automated Response and Remediation playbooks and their integration with existing government service management systems?...
 
Operations & Management:
What is the required retention period for logs in Log Analytics?
What are the department's SLA expectations for different workloads and services
What are the required maintenance schedules for patching and system updates?
What are the specific details for monitoring and SIEM integration, including alerting?
What are the specific backup frequency requirements and the list of critical workloads requiring specific backup/DR configurations?
Providing detailed answers to these questions would translate the conceptual design into concrete configuration parameters needed to deploy the foundational architecture and prepare for workload migration using Infrastructure as Cod
