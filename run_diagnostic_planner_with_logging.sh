#!/bin/bash

# Script to run diagnostic_planner.py with all outputs redirected to diagnostic_plannerloglari
# This captures both stdout and stderr

echo "🔍 Starting Local Planner Diagnostic with logging..."
echo "📝 All outputs will be saved to: diagnostic_plannerloglari"

# Create log directory if it doesn't exist
mkdir -p logs

# Source the ROS2 environment
source /opt/ros/humble/setup.bash
source install/setup.bash

# Get current timestamp for log file naming
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
LOG_FILE="logs/diagnostic_plannerloglari_${TIMESTAMP}.log"

# Run the diagnostic planner with output redirection
echo "=== Starting Local Planner Diagnostic at $(date) ===" > "$LOG_FILE"
echo "Log file: $LOG_FILE" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# Run the node and redirect all output (stdout and stderr) to log file
# Also display output in terminal with tee
ros2 run robotaxi_nav diagnostic_planner.py 2>&1 | tee -a "$LOG_FILE"

# Also create a symlink to the latest log
ln -sf "diagnostic_plannerloglari_${TIMESTAMP}.log" logs/diagnostic_plannerloglari_latest.log

echo "📝 Diagnostic planner stopped. Log saved to: $LOG_FILE"
