#!/bin/bash

echo "Server Performance Stats for macOs"
echo "================================"

# 1. Total CPU Usage 
echo -e "\n5. Total CPU Usage:"
cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3+$5"%"}')
echo "   $cpu_usage"

# 2. Memory Usage (usar vm_stat en macOS)
echo -e "\n6. Memory Usage:"
pagesize=$(sysctl -n hw.pagesize)
vm_stat=$(vm_stat)
free_pages=$(echo "$vm_stat" | awk '/Pages free/ {print $3}' | sed 's/\.//')
active_pages=$(echo "$vm_stat" | awk '/Pages active/ {print $3}' | sed 's/\.//')
inactive_pages=$(echo "$vm_stat" | awk '/Pages inactive/ {print $3}' | sed 's/\.//')
speculative_pages=$(echo "$vm_stat" | awk '/Pages speculative/ {print $3}' | sed 's/\.//')
wired_pages=$(echo "$vm_stat" | awk '/Pages wired down/ {print $4}' | sed 's/\.//')

free_mem=$(( ($free_pages + $speculative_pages) * $pagesize / 1024 / 1024 ))
used_mem=$(( ($active_pages + $inactive_pages + $wired_pages) * $pagesize / 1024 / 1024 ))
total_mem=$(( $free_mem + $used_mem ))
usage=$(echo "scale=2; $used_mem*100/$total_mem" | bc)

echo "   Total: ${total_mem}Mi, Used: ${used_mem}Mi, Free: ${free_mem}Mi, Usage: ${usage}%"

# 3. Disk Usage
echo -e "\n7. Disk Usage:"
df -h / | awk '
    NR==2 {
        printf "   Total: %s, Used: %s, Free: %s, Usage: %s\n", $2, $3, $4, $5
    }'

# 4. Top 5 Processes by CPU Usage
echo -e "\n8. Top 5 Processes by CPU Usage:"
ps -arcwwwxo pid,comm,%cpu | head -n 6 | awk 'NR>1 {printf "   %s: %s%%\n", $2, $3}'

# 5. Top 5 Processes by Memory Usage
echo -e "\n9. Top 5 Processes by Memory Usage:"
ps -arcwwwxo pid,comm,%mem | head -n 6 | awk 'NR>1 {printf "   %s: %s%%\n", $2, $3}'
