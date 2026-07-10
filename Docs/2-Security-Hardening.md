# Security Hardening & Tiered Administration
## The Enterprise Security Framework

**Real-World Context:** We use Tiered Administration so that a compromised server account cannot be used to hijack the entire domain.

### 1. The Enterprise RBAC Hierarchy

| Group Name | Purpose | What to Delegate to this Group |
|---|---|---|
| **GG_Domain_Admins** | Full Domain Control | Nothing (It's already an admin). Use this only for Domain Controller work. |
| **GG_Server_Admins** | Server OS Management | Delegate to Company Servers OU (Install software, reboot, change settings). |
| **GG_Identity_Admins** | Helpdesk/Password Resets | Delegate to Employees OU (Reset passwords, move users, edit attributes). |
| **GG_File_Share_Admins** | Data Governance | Delegate to CompanyData (Manage NTFS permissions, not OS settings). |

### Step 1: Create the Security Groups (RBAC)
Create these in your Security Groups OU:
* Create the four groups listed in the table above.
* Add your appropriate admin accounts (e.g., `ossa-admin`) into the corresponding groups.

### Step 2: Production Delegation Table (The "How-To")
This table maps your groups to the specific checkboxes required in the "Delegate Control" wizard in Active Directory Users and Computers (ADUC).

| Group | Target OU | Wizard Selection | Specific Permissions to Check |
|---|---|---|---|
| **GG_Identity_Admins** | Employees | "Reset user passwords..." | Reset password, Read/Write account restrictions, Unlock account. |
| **GG_Server_Admins** | Company Servers | "Create custom task" | Create Computer objects, Delete Computer objects, Read all/Write all properties. |
| **GG_File_Share_Admins** | (No AD Delegation) | N/A | NTFS Only: Manage permissions directly on the folder (`D:\CompanyData`). |

> **Note:** To "Join a computer to the domain," granting "Create Computer Objects" on the OU effectively allows that permission.

### Step 3: The "Break-Glass" Strategy
* On **DC01**, create two accounts (`adm-break1`, `adm-break2`) in the Admin Accounts OU.
* Give them long, random, complex passwords.
* Add these users to the Domain Admins group.
* **Physical Security:** Write these passwords down, put them in separate envelopes, and store them in physical safes. Do not use these for daily tasks.

### Step 4: Secure the Built-in Administrator
* **Rename:** Right-click the built-in Administrator in ADUC and rename it to something non-obvious (e.g., `z_local_admin`).
* **Long Password:** Set a massive, random password.
* **Disable:** Once you have confirmed your Break-Glass accounts work, right-click the renamed account and select **Disable Account**.

### Step 5: Disable Local Administrator Accounts via GPO
1. On **DC01**, open Group Policy Management (`gpmc.msc`).
2. Edit your `Restrict-Server-Admins` GPO.
3. Navigate to: `Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options`.
4. Set **Accounts: Administrator account status** to **Disabled**.

### Step 6: GPO: Local Admin & RDP Rights
You need to link your `GG_Server_Admins` group to your servers so they have management rights AND RDP access.

**Local Admin Rights (Restricted Groups):**
1. Edit your `Restrict-Server-Admins` GPO.
2. Go to: `Computer Configuration > Policies > Windows Settings > Security Settings > Restricted Groups`.
3. Right-click **Restricted Groups** > **Add Group** > Browse for `GG_Server_Admins`.
4. In the bottom section ("This group is a member of"), click **Add** and type `Administrators`.

**RDP Access (User Rights Assignment):**
1. Still in the same GPO, go to: `Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment`.
2. Find: **"Allow log on through Remote Desktop Services"**.
3. Double-click it, check **"Define these policy settings"**, and Add your `GG_Server_Admins` group.
4. Run `gpupdate /force` on your servers to apply these changes.

### Step 7: Auditing your Delegations
To see exactly what permissions are applied to an OU:
1. Open Command Prompt (as Administrator).
2. Type the following command:
   ```cmd
   dsacls "OU=Company Servers,DC=homelab,DC=lan"
