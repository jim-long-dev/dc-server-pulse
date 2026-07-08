#!/bin/bash
# ==============================================================================
# Script Name : dc_server_pulse.sh
# Description : Data Center Server Health Monitor and Patch Auditor
# Features    : Cross-distro package management detection, automated logging,
#               and resource threshold auditing.
# ==============================================================================

# Configurations (Using local files so you don't need root/sudo to test)
LOG_FILE="./dc_monitor.log"

# Set resource thresholds here
DISK_THRESHOLD=80
MEM_THRESHOLD=85

# Ensure log file exists
touch "$LOG_FILE"

echo "=== System Pulse Report: $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"

# 1. Check disk usage
check_disk_usage() {
    local disk_usage
    disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        echo "[CRITICAL] Disk usage is at ${disk_usage}% (Threshold: ${DISK_THRESHOLD}%)" | tee -a "$LOG_FILE"
    else
        echo "[OK] Disk usage is optimal: ${disk_usage}%" | tee -a "$LOG_FILE"
    fi
}

# 2. Check memory usage
check_memory_usage() {
    local mem_telemetry
    # Calculates used memory percentage using clean integer arithmetic
    mem_telemetry=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
    
    if [ "$mem_telemetry" -gt "$MEM_THRESHOLD" ]; then
        echo "[CRITICAL] Memory usage is high: ${mem_telemetry}% (Threshold: ${MEM_THRESHOLD}%)" | tee -a "$LOG_FILE"
    else
        echo "[OK] Memory usage is stable: ${mem_telemetry}%" | tee -a "$LOG_FILE"
    fi
}

# 3. Check pending patches safely
check_security_patches() {
    local pending_updates=0

    if command -v apt-get &> /dev/null; then
        # Debian / Ubuntu Systems (Using apt-get for script stability)
        pending_updates=$(apt-get -s upgrade | grep -c "^Inst")
        echo "[INFO] Debian/Ubuntu (APT-based) system detected." | tee -a "$LOG_FILE"
        echo "[INFO] Pending package updates available: ${pending_updates}" | tee -a "$LOG_FILE"

    elif command -v dnf &> /dev/null; then
        # Modern Enterprise RHEL / Rocky Linux / AlmaLinux Systems
        # 'dnf check-update' returns exit code 100 if updates are available
        pending_updates=$(dnf check-update -q | grep -c '^\S')
        echo "[INFO] RHEL-family (DNF-based) system detected." | tee -a "$LOG_FILE"
        echo "[INFO] Pending package updates available: ${pending_updates}" | tee -a "$LOG_FILE"

    elif command -v yum &> /dev/null; then
        # Legacy RHEL / CentOS Systems
        pending_updates=$(yum check-update -q | grep -c '^\S')
        echo "[INFO] Legacy RHEL-family (YUM-based) system detected." | tee -a "$LOG_FILE"
        echo "[INFO] Pending package updates available: ${pending_updates}" | tee -a "$LOG_FILE"

    else
        echo "[WARNING] Unknown package manager. Skipping patch audit." | tee -a "$LOG_FILE"
    fi
}

# Execute all diagnostics
check_disk_usage
check_memory_usage
check_security_patches
echo "==================================================" | tee -a "$LOG_FILE"
echo ""

# To automate as a cron job:
# 0 * * * * /absolute/path/to/your/dc_server_pulse.sh
