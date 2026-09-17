# Changing DNS Server Configuration on Windows Server (AWS EC2)

This document outlines the standard operating procedure for verifying security group rules, testing DNS reachability, and updating DNS server settings on Windows Server instances running on AWS EC2.

---

## 1. Prerequisites & Security Group Configuration

Before modifying network adapter settings inside the operating system, ensure that AWS Security Group outbound rules permit communication with the target DNS servers.

* **Port Required:** Port 53 (TCP and UDP)
* **AWS Security Group Action:** Add an **Outbound Rule** allowing outbound traffic on Port 53 to the destination DNS server IP addresses.

| Type | Protocol | Port Range | Destination | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Custom UDP** | UDP | `53` | `<DNS_IP_1>/32`, `<DNS_IP_2>/32` | Standard DNS queries |
| **Custom TCP** | TCP | `53` | `<DNS_IP_1>/32`, `<DNS_IP_2>/32` | Large DNS responses / TCP fallbacks |

---

## 2. Step-by-Step Commands

### Step 1: Inspect Current Network Settings

Check current network adapter settings, active DNS servers, and DHCP status:

```cmd
ipconfig /all

### Step 2: Test Security Group / TCP Connectivity

Verify that TCP Port 53 is reachable through the security group:
```PowerShell
Test-NetConnection -ComputerName <DNS_IP_1> -Port 53
Test-NetConnection -ComputerName <DNS_IP_2> -Port 53
```

### Step 3: Test DNS Resolution

Confirm that the target DNS servers actively resolve domain queries before applying changes system-wide:
```PowerShell
Resolve-DnsName -Name google.com -Server <DNS_IP_1>
Resolve-DnsName -Name google.com -Server <DNS_IP_2>
```
### Step 4: Identify Active Network Interface

Find the InterfaceIndex of the active network adapter (e.g., Ethernet 3):
```PowerShell
Get-NetAdapter | Select-Object Name, InterfaceIndex, Status
```

### Step 5: Apply New DNS Server Addresses

Assign the primary and secondary DNS servers to the target interface index (replace `<INDEX> `with your actual InterfaceIndex):
```PowerShell
Set-DnsClientServerAddress -InterfaceIndex <INDEX> -ServerAddresses ("10.5.66.140", "10.6.134.20}")
```

### Step 6: Flush Local Resolver Cache

Clear the local DNS cache to force immediate system-wide resolution through the new DNS servers
```PowerShell
Clear-DnsClientCache
```

Step 7: Verify Configuration & Resolution

Verify the updated interface settings and confirm default system-wide DNS resolution
```PowerShell
# Verify adapter settings
Get-DnsClientServerAddress -InterfaceIndex <INDEX>

# Test default system resolution
Resolve-DnsName -Name google.com
```

3. Rollback Procedure (If Required)

If you need to revert back to obtaining DNS dynamically via DHCP
```PowerShell
Reset-DnsClientServerAddress -InterfaceIndex <INDEX>
```