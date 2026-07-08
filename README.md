# Data Center Server Pulse Agent

A lightweight, production-ready Bash automation utility designed for enterprise Linux environments. This script monitors core server health metrics and safely audits system patch requirements across different Linux distributions.

## 🚀 Key Features
* **Cross-Distribution Aware:** Dynamically detects package managers to handle Debian/Ubuntu (`apt-get`) and RHEL-family systems (`dnf`/`yum`) seamlessly.
* **Telemetry Diagnostics:** Audits storage filesystems and active memory consumption against configurable critical thresholds.
* **Automated Audit Logging:** Appends standardized telemetry logs with execution timestamps for systems engineering reviews.

## 🛠️ Installation & Manual Execution

1. Clone or download the script to your local Linux server directory.
2. Grant execution permissions to the script:
	```bash
	chmod +x dc_server_pulse.sh
	```
3. Run manual diagnostics to verify local pathing and telemetry logging:
4. Verify the output log has been created successfully:
  ```bash
  cat dc_monitor.log
  ```

## ⏱️ Infrastructure Automation (System Cron)
In production data center environments, health telemetry shouldn't be run manually. To automate this script to execute silently in the background **every hour on the hour**, use the built-in Linux cron utility:

1. Open your user's crontab configuration editor:
   ```bash
   crontab -e
   ```
   
2. Scroll to the bottom of the file and append the following cron directive (ensure you replace `/absolute/path/to/` with your script's actual directory path):
   ```plaintext
   0 * * * * /absolute/path/to/dc_server_pulse.sh
   ```
3. Save and close the editor. The system daemon will automatically initialize the schedule and begin appending health reports hourly.
   
