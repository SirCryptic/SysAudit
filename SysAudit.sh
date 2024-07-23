#!/bin/bash
#!/bin/bash

##################################
# SysAudit version 0.1(BETA) #
##################################
## Developed on GitHub With <3  ##
##       By SirCryptic          ##
##################################
##################################
##        rjwdlu4eva            ##
##################################
##         Greetz To:           ## 
##################################
##     NullSecurityTeam         ##
##          M0bly {MIA}         ##
##          Double A {MIA}      ##
##################################
##          R1ff                ##
##          M0nde               ##
##          lucci               ##
##          Jack    {R.I.P}     ##
##          Kiera               ##
##################################
## THIS WAS DEVELOPED USING GITHUB NO TESTING USING BASIC KNOWLEDGE ,I'M NOT RESPONSIBLE FOR BUGGED CODE JUST MERELY TESTING & EXPRESSING MYSELF ;) MWAH
##################################
# Function Definitions

perform_network_scan() {
    read -p "Enter target IP or range (e.g., 192.168.1.0/24): " target
    echo "Performing Network Scan on $target..."
    
    if [[ -z "$target" ]]; then
        echo "Error: No target provided."
        return 1
    fi
    
    if ! command -v nmap &> /dev/null; then
        echo "Error: nmap is not installed."
        return 1
    fi

    nmap -sP $target > network_scan.txt
    echo "Network Scan Complete. Results saved to network_scan.txt."
}

perform_vulnerability_assessment() {
    read -p "Enter target IP or domain: " target
    echo "Performing Vulnerability Assessment on $target..."

    if [[ -z "$target" ]]; then
        echo "Error: No target provided."
        return 1
    fi

    if ! command -v nmap &> /dev/null; then
        echo "Error: nmap is not installed."
        return 1
    fi

    nmap --script vuln $target > vuln_assessment.txt
    echo "Vulnerability Assessment Complete. Results saved to vuln_assessment.txt."
}

run_compliance_check() {
    read -p "Enter target IP or range (e.g., 192.168.1.0/24): " target
    echo "Running Compliance Check on $target..."

    if [[ -z "$target" ]]; then
        echo "Error: No target provided."
        return 1
    fi

    if ! command -v nmap &> /dev/null; then
        echo "Error: nmap is not installed."
        return 1
    fi
    
    if ! command -v hydra &> /dev/null; then
        echo "Error: hydra is not installed."
        return 1
    fi

    echo "Checking for open SSH ports..."
    nmap -p 22 --open -sV $target > ssh_compliance.txt

    echo "Checking for weak passwords..."
    hydra -L usernames.txt -P passwords.txt ssh://$target > weak_passwords.txt

    echo "Compliance Check Complete. Results saved to ssh_compliance.txt and weak_passwords.txt."
}

collect_system_info() {
    echo "Gathering System Information..."
    {
        echo "Hostname: $(hostname)"
        echo "Operating System: $(uname -o)"
        echo "Kernel Version: $(uname -r)"
        echo "Uptime: $(uptime -p)"
        echo "Users Currently Logged In: $(who)"
    } > system_info.txt
    echo "System Information Collected. Results saved to system_info.txt."
}

check_password_policy() {
    echo "Checking Password Policy..."
    
    if ! sudo -n true 2>/dev/null; then
        echo "Error: You do not have sudo privileges."
        return 1
    fi

    {
        echo "Password Policy:"
        sudo grep PASS_MAX_DAYS /etc/login.defs
        sudo grep PASS_MIN_DAYS /etc/login.defs
        sudo grep PASS_WARN_AGE /etc/login.defs
    } > password_policy.txt
    echo "Password Policy Check Complete. Results saved to password_policy.txt."
}

check_firewall_status() {
    echo "Checking Firewall Status..."
    
    if ! command -v ufw &> /dev/null; then
        echo "Error: ufw is not installed."
        return 1
    fi

    sudo ufw status verbose > firewall_status.txt
    echo "Firewall Status Check Complete. Results saved to firewall_status.txt."
}

generate_audit_report() {
    echo "Generating Report..."
    
    local report_file="audit_report.txt"
    
    if [[ -e $report_file ]]; then
        echo "Warning: $report_file already exists. Overwriting..."
    fi

    {
        cat network_scan.txt
        cat vuln_assessment.txt
        cat ssh_compliance.txt
        cat weak_passwords.txt
        cat system_info.txt
        cat password_policy.txt
        cat firewall_status.txt
    } > $

generate_audit_report() {
    echo "Generating Report..."
    
    local report_file="audit_report.txt"
    
    if [[ -e $report_file ]]; then
        echo "Warning: $report_file already exists. Overwriting..."
    fi

    {
        cat network_scan.txt
        cat vuln_assessment.txt
        cat ssh_compliance.txt
        cat weak_passwords.txt
        cat system_info.txt
        cat password_policy.txt
        cat firewall_status.txt
    } > $report_file

    echo "Report Generated: $report_file"
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
    echo "8. Exit"

    read -p "Enter choice [1-8]: " choice

    case $choice in
        1)
            network_scan
            ;;
        2)
            vulnerability_assessment
            ;;
        3)
            compliance_check
            ;;
        4)
            system_info
            ;;
        5)
            password_policy_check
            ;;
        6)
            firewall_status
            ;;
        7)
            generate_audit_report
            ;;
        8)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
done
