#!/bin/bash

# --- Color Definitions (For Terminal) ---
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m' # Bold Yellow
RESET='\033[0m'

# --- Setup Output Folder ---
REPORT_DIR="PrivEsc_Master_Report"
mkdir -p "$REPORT_DIR/ssh_keys"

echo -e "${YELLOW}Starting Master Enumeration... Folder: ./$REPORT_DIR${RESET}"

# --- Helper to write colored headers to files ---
# Usage: write_header "Section Title" "filename"
write_header() {
    echo -e "${YELLOW}====================================================${RESET}" >> "$REPORT_DIR/$2"
    echo -e "${YELLOW}COMMAND: $1${RESET}" >> "$REPORT_DIR/$2"
    echo -e "${YELLOW}====================================================${RESET}" >> "$REPORT_DIR/$2"
}

# --- 1. System Info ---
echo -e "${BLUE}[#] Section: System Info${RESET}"
FILE="01_system.txt"
write_header "cat /etc/*-release" "$FILE"; cat /etc/*-release >> "$REPORT_DIR/$FILE" 2>&1
write_header "cat /etc/issue" "$FILE"; cat /etc/issue >> "$REPORT_DIR/$FILE" 2>&1
write_header "uname -a" "$FILE"; uname -a >> "$REPORT_DIR/$FILE" 2>&1

# --- 2. User & Group Info ---
echo -e "${BLUE}[#] Section: User and Group Info${RESET}"
FILE="02_users.txt"
write_header "ls -al /root" "$FILE"; ls -al /root >> "$REPORT_DIR/$FILE" 2>&1
write_header "sudo -l" "$FILE"; sudo -l >> "$REPORT_DIR/$FILE" 2>&1
write_header "ls -al /home/*" "$FILE"; ls -al /home/* >> "$REPORT_DIR/$FILE" 2>&1
write_header "last" "$FILE"; last >> "$REPORT_DIR/$FILE" 2>&1
write_header "cat /etc/passwd" "$FILE"; cat /etc/passwd >> "$REPORT_DIR/$FILE" 2>&1
write_header "cat /etc/group" "$FILE"; cat /etc/group >> "$REPORT_DIR/$FILE" 2>&1
write_header "id" "$FILE"; id >> "$REPORT_DIR/$FILE" 2>&1
write_header "whoami" "$FILE"; whoami >> "$REPORT_DIR/$FILE" 2>&1

# --- 3. Passwords & Shadow ---
echo -e "${BLUE}[#] Section: Passwords & Shadow File${RESET}"
FILE="03_passwords.txt"
write_header "cat /etc/passwd" "$FILE"; cat /etc/passwd >> "$REPORT_DIR/$FILE" 2>&1
write_header "sudo cat /etc/shadow" "$FILE"; sudo cat /etc/shadow >> "$REPORT_DIR/$FILE" 2>&1

# --- 4. Network Info ---
echo -e "${BLUE}[#] Section: Network Info${RESET}"
FILE="04_network.txt"
write_header "netstat -antup" "$FILE"; netstat -antup >> "$REPORT_DIR/$FILE" 2>&1
write_header "hostname -i" "$FILE"; hostname -i >> "$REPORT_DIR/$FILE" 2>&1
write_header "netstat -ie" "$FILE"; netstat -ie >> "$REPORT_DIR/$FILE" 2>&1

# --- 5. Services & Sudoers ---
echo -e "${BLUE}[#] Section: Services and Sudoers${RESET}"
FILE="05_services.txt"
write_header "ps aux | grep root" "$FILE"; ps aux | grep root >> "$REPORT_DIR/$FILE" 2>&1
write_header "ls -la /etc/sudoers.d/" "$FILE"; ls -la /etc/sudoers.d/ >> "$REPORT_DIR/$FILE" 2>&1

# --- 6. SUID / GUID & Writable ---
echo -e "${BLUE}[#] Section: SUID and GUID${RESET}"
FILE="06_suid_guid.txt"
write_header "GUID (World Writable)" "$FILE"; find / -perm -2 -type f 2>/dev/null | grep -v /proc/ >> "$REPORT_DIR/$FILE" 2>&1
write_header "SGID" "$FILE"; find / -perm -g=s -type f 2>/dev/null >> "$REPORT_DIR/$FILE" 2>&1
write_header "SUID" "$FILE"; find / -perm -u=s -type f 2>/dev/null >> "$REPORT_DIR/$FILE" 2>&1

# --- 7. Capabilities ---
echo -e "${BLUE}[#] Section: Capabilities${RESET}"
FILE="07_capabilities.txt"
write_header "getcap -r / 2>/dev/null" "$FILE"; getcap -r / 2>/dev/null >> "$REPORT_DIR/$FILE" 2>&1

# --- 8. MySQL ---
echo -e "${BLUE}[#] Section: MySQL${RESET}"
FILE="08_mysql.txt"
write_header "mysql --version" "$FILE"; mysql --version >> "$REPORT_DIR/$FILE" 2>/dev/null
write_header "mysql -u root" "$FILE"; mysql -u root -e "status" >> "$REPORT_DIR/$FILE" 2>&1

# --- 9. Crontab ---
echo -e "${BLUE}[#] Section: Crontab${RESET}"
FILE="09_cron.txt"
write_header "cat /etc/crontab" "$FILE"; cat /etc/crontab >> "$REPORT_DIR/$FILE" 2>&1
write_header "Cron Directories" "$FILE"; ls -la /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly /var/spool/cron/crontabs 2>/dev/null >> "$REPORT_DIR/$FILE" 2>&1

# --- 10. Path & Env ---
echo -e "${BLUE}[#] Section: Path${RESET}"
FILE="10_path.txt"
write_header "echo \$PATH" "$FILE"; echo $PATH >> "$REPORT_DIR/$FILE" 2>&1
write_header "env" "$FILE"; env >> "$REPORT_DIR/$FILE" 2>&1

# --- 11. SSH Key Scraper ---
echo -e "${BLUE}[#] Section: SSH Key Scraper${RESET}"
FILE="11_ssh_keys.txt"
ssh_found=0
keys=$(find /home /root /var/www -name "id_rsa" -o -name "id_dsa" -o -name "authorized_keys" 2>/dev/null)
for key in $keys; do
    safe_name=$(echo $key | tr '/' '_')
    cp "$key" "$REPORT_DIR/ssh_keys/$safe_name" 2>/dev/null
    write_header "Found: $key" "$FILE"
    ssh_found=1
done

if [ $ssh_found -eq 1 ]; then
    echo -e "${RED}[!] SSH Keys copied to $REPORT_DIR/ssh_keys/${RESET}"
else
    echo "No SSH keys found." >> "$REPORT_DIR/$FILE"
    echo -e "${GREEN}[+] No SSH keys found.${RESET}"
fi

echo -e "\n${YELLOW}--- Enumeration Complete! Commands are Bold Yellow in reports. ---${RESET}"
