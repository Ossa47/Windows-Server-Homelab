# Enterprise File Shares & Data Governance

## 📌 Overview
In an enterprise environment, file shares are never built using default settings. To ensure strict data security, this lab implements the "Double Whammy" Rule: utilizing highly permissive SMB Share permissions acting as a "doorway," backed by extremely strict, non-inherited NTFS permissions acting as the "locks."
This document details the configuration of the centralized Data volume (`D:\`) on **FS01**.

## Phase 1: Folder Structure & The "Clean Slate"
**Real-World Context:** We follow the "Least Privilege" rule for data. We never give "Everyone" permission to the root drive, and we prevent standard users from traversing into departments they don't belong to.

### 1. Create the Hierarchy
On the FS01 Data volume (`D:\`), create the root corporate folder and department sub-folders:
* `D:\CompanyData`
  * `\Finance`
  * `\Engineering`
  * `\IT`

### 2. Disable Inheritance (The Clean Slate)
By default, Windows inherits permissions from the parent drive. We must break this inheritance at the root folder to establish strict control.
1. Right-click `CompanyData` > **Properties** > **Security** > **Advanced**.
2. Click **Disable inheritance** and select "Remove all inherited permissions from this object."
3. Manually add `SYSTEM`, `Administrators`, and our RBAC group `GG_File_Share_Admins` back with **Full Control**.

**Result:** Standard users currently have absolutely zero access to this folder.

## Phase 2: SMB Share Permissions (The "Doorway")
**Real-World Context:** A "Share" is just the network doorway. Best practice dictates opening the doorway wide and letting NTFS handle the actual security validations.
1. Open **Server Manager** > **File and Storage Services** > **Shares**.
2. Create an SMB Share pointing to `D:\CompanyData`.
3. In the **Share Permissions** tab, remove the default `Everyone: Read`.
4. Add the `Domain Users` group and grant **Change** and **Read** permissions.
*(Note: We do not grant Full Control at the share level to prevent users from accidentally changing ownership of files).*

## Phase 3: NTFS Permissions (The "Locks")
**Real-World Context:** While Share permissions control access to the door, NTFS permissions control what users can do once they are inside the room. Instead of assigning individual users to folders, we assign specific Department Security Groups (e.g., `GG_Finance_Users`).
1. Right-click the **Finance** folder > **Properties** > **Security** > **Edit**.
2. Click **Add**, type `GG_Finance_Users`, and grant them **Modify** permissions.
3. Repeat this process for the **Engineering** and **IT** folders, assigning only their respective groups.

*(The `GG_File_Share_Admins` group manages these permissions on a day-to-day basis, freeing up Domain Admins from basic file ticketing).*

## Phase 4: Access-Based Enumeration (ABE)
To further secure the environment and prevent "directory snooping," ABE is enabled on the `CompanyData` share.
* **How to enable:** Server Manager > File and Storage Services > Shares > Right-click `CompanyData` > **Properties** > **Settings** > Check **Enable access-based enumeration**.
* **The Result:** If a standard user (`ossa`) is not a member of the Finance or Engineering groups, they will not even see those folders when they browse to `\\FS01\CompanyData`. The folders are completely hidden from unauthorized users.

## Phase 5: Verification & Testing
To prove the architecture works as intended:
1. Log into a domain-joined workstation as a standard user (e.g., `ossa`).
2. Navigate to `\\FS01\CompanyData`.
3. Verify that only authorized departmental folders are visible (thanks to ABE).
4. Attempt to write a file into an authorized folder (**Success**).
5. Attempt to browse to `\\FS01\d$` (Administrative share) to verify standard users are blocked from bypassing the share path (**Access Denied**).
