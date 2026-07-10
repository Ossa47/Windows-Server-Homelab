**Enterprise Active Directory Homelab**

**Project Overview**

This project is a fully functional, enterprise-grade Windows Server homelab environment. Unlike standard default setups, this lab is designed following strict Tiered Administration, Role-Based Access Control (RBAC), and Least Privilege principles used in real-world medium-to-large enterprise environments.

The goal of this project is to simulate a secure corporate infrastructure, focusing on identity management, secure domain joins, localized administration via GPO, and enterprise file share governance.

**Architecture & Topology**

The environment consists of a virtualized network utilizing Windows Server 2022 Generation 2 VMs.

DC01 (Domain Controller & Infrastructure Server)

OS: Windows Server 2022

Roles: Active Directory Domain Services (AD DS), DNS, DHCP

Purpose: The central identity and authentication authority. Locked down from day-to-day access.

FS01 (Enterprise File Server)

OS: Windows Server 2022

Roles: File and Storage Services

Purpose: Hosts corporate data on a dedicated D:\ volume, utilizing strict NTFS and SMB Share permissions.

**Key Security Implementations**

**1. Tiered Administration & Break-Glass Strategy**

Strict Separation of Accounts: Daily standard accounts (e.g., ossa) are separated from server administration accounts (e.g., ossa-admin), which are separated from Domain Admins (ossa-da).

Break-Glass Accounts: Implementation of emergency recovery accounts (adm-break1, adm-break2) with complex credentials stored securely, ensuring domain recovery if primary admins are compromised.

Built-in Admin Lockdown: The default -500 Administrator account is renamed, secured with a massive password, and disabled to prevent standard brute-force attacks.

**2. Role-Based Access Control (RBAC)**

Delegation is handled exclusively via Security Groups, never assigned to individual users.

GG_Domain_Admins: Full AD control (DC01 access only).

GG_Server_Admins: Server OS Management (FS01 access).

GG_Identity_Admins: Helpdesk role for password resets and user attribute management.

GG_File_Share_Admins: Data governance and NTFS permission management.

**3. Group Policy (GPO) Hardening**

Restricted Groups: Automated deployment of the GG_Server_Admins group to the Local Administrators group of all member servers via GPO.

RDP Access: Explicitly granting Remote Desktop rights only to authorized server admin groups via User Rights Assignment.

Local Admin Disabled: The local Administrator account on all member servers is actively disabled via domain policy.

**4. Vulnerability Mitigation**

MachineAccountQuota: Lowered the default limit of 10 down to 0, preventing standard users from joining unmanaged/rogue devices to the corporate domain.

Delegated Domain Joins: Created a specific custom task delegation allowing Helpdesk accounts to join computers exclusively to the Company Computers OU.

**Enterprise File Shares**

Implementation of the "Double Whammy" Rule: SMB Share permissions set to Everyone: Read/Change while relying on strict NTFS permissions for security.

Data hierarchy isolating departments (e.g., Finance, Engineering, IT) with inheritance disabled at the root level to prevent unauthorized traversal.

**How to Use This Lab**

This documentation serves as a blueprint. The project is broken down into modular phases:

Virtual Machine Provisioning & Storage Initialization

Static IP & DNS Configuration

Active Directory & DHCP Setup

Real-World Domain Join Practices

Enterprise User Accounts & Permissions

Security Hardening & Tiered Administration

File Share Architecture

**Disclaimer**: This is an educational lab environment built to demonstrate systems administration and cybersecurity defense principles.
