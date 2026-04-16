# OSMINI-PROJECT — Automated Linux Auditing Solution

**Instructor:** DR. BENTRAD SASSI  
**Developed by:** OURAMDANE AMIRA RABEA & SEHILA SOUNDOUS  
**Group:** A4

---

## 📖 Project Overview

This project is an automated Linux-based auditing solution designed to collect hardware and software information, generate formatted reports, and support remote monitoring and scheduled execution. It is developed using modular shell scripting to assist system administrators and cybersecurity analysts in maintaining asset inventories and performing risk assessments.

---

## ✨ Features

- **Modular Audit Scripts:** Separate modules for Hardware and Software auditing with both "Short" (summary) and "Full" (detailed) reporting options.
- **Interactive Menus:** Two management interfaces — a CLI-based terminal menu (`main.sh`) and a graphical dialog-based menu (`gui.sh`).
- **Automated Monitoring:** Scheduled execution via cron jobs with integrated email reporting.
- **Professional Reporting:** Reports are generated with headers, timestamps, and colorized output, then saved automatically to local logs.
- **Security & Integrity:** Includes root privilege checks, error handling with traps, and log rotation for system persistence.

---

## 🛠️ Installation & Prerequisites

### 1. System Requirements
- **OS:** Linux (Ubuntu, Kali, or similar Debian-based distributions)
- **Privileges:** The scripts must be run with root/sudo privileges to access system hardware and log files.

### 2. Required Packages

Ensure the following standard tools are installed:

```bash
sudo apt update
sudo apt install mailutils msmtp dialog lshw dmidecode
```

### 3. Setup

Extract the project files and grant execution permissions to all scripts:

```bash
chmod +x *.sh
```

---

## ⚙️ Configuration

### Email Reporting

The scripts use `mailx` or `msmtp` to send reports.

- **Manual Export:** Upon completing a manual audit, the script will prompt if you wish to email the result.
- **Automated Export:** The `automation.sh` script is pre-configured to send reports to our email. You can modify the `RECIPIENT` variable in that file to change the target address.

### Log Files

Audit data and errors are stored in the following locations:

| Type | Path |
|------|------|
| Software Logs | `/var/log/software_audit.log` |
| Hardware Logs | `/var/log/system_report.log` |
| Report Outputs | `/tmp/` (e.g., `short_SOFTWARE_Format.txt`) |

---

## 🚀 How to Run

### Option 1: Interactive Master Control (Recommended)

Launch the main management menu to select specific audit tasks:

```bash
sudo ./main.sh
```

### Option 2: Graphical User Interface

For a more visual experience using the `dialog` tool:

```bash
sudo ./gui.sh
```

### Option 3: Individual Modules

You can run any audit module directly:

```bash
sudo ./softwareshort.sh   # Concise software audit
sudo ./softwarefull.sh    # Detailed software inventory
sudo ./hardshort.sh       # Concise hardware summary
sudo ./hardlong.sh        # Full technical hardware specs
```

---

## 🌐 Remote Monitoring Setup

### 1. Host and Guest Network Synchronization

To ensure both machines can communicate, VirtualBox network settings were adjusted:

- **Shutdown the VM** before changing network adapters.
- **Switch to Bridged Adapter:** Changed the network mode from NAT to Bridged Adapter.
- **Enable Connectivity:** Ensure "Virtual Cable Connected" is checked so the VM receives an IP from the local router.

### 2. Installing and Enabling SSH Server (On Guest VM)

Since `ssh.service` was missing, the OpenSSH server was installed to listen for incoming connections.

### 3. Identifying the Remote IP Address

To find the internal IP assigned to the VM:

```bash
ip a
```

### 4. Setting Up SSH Key-Based Authentication (Passwordless Login)

To allow scripts to run without manual password entry, an SSH key pair was established:

**Generate RSA Keys (On Host Machine):**

```bash
ssh-keygen -t rsa
```

**Transfer Public Key to Guest VM:**

```bash
ssh-copy-id user@<VM_IP>
```

---

## ⏰ Automation (Cron Configuration)

To automate the system audit (e.g., daily at 04:00 AM), add the `automation.sh` script to your crontab:

1. Open the crontab editor:
```bash
sudo crontab -e
```

2. Add the following line:
```
00 04 * * * /absolute/path/to/your/project/automation.sh
```

---

## 📂 Project Structure

| File | Description |
|------|-------------|
| `main.sh` | CLI-based Master Control menu |
| `gui.sh` | Graphical dialog menu interface |
| `automation.sh` | Automation script for cron and mass email reporting |
| `softwareshort.sh` | Concise OS and package auditing |
| `softwarefull.sh` | Detailed software inventory |
| `hardshort.sh` | Concise hardware summary |
| `hardlong.sh` | Full technical hardware specs |
| `sendremote.sh` | Sends report files to another machine via SSH and SCP |

---

> *Shell Scripting Project — VCC Workspace*
