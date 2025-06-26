#!/bin/bash

# Script to run localplanner.py with all outputs redirected to localplannerloglari
# This captures both stdout and stderr

echo "🚗 Starting Local Planner with logging..."
echo "📝 All outputs will be saved to: localplannerloglari"

# Create log directory if it doesn't exist
mkdir -p logs

# Source the ROS2 environment
source /opt/ros/humble/setup.bash
source install/setup.bash

# Get current timestamp for log file naming
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
LOG_FILE="logs/localplannerloglari_${TIMESTAMP}.log"

# Run the local planner with output redirection
echo "=== Starting Local Planner at $(date) ===" > "$LOG_FILE"
echo "Log file: $LOG_FILE" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# Run the node and redirect all output (stdout and stderr) to log file
# Also display output in terminal with tee
ros2 run robotaxi_nav localplanner.py 2>&1 | tee -a "$LOG_FILE"

# Also create a symlink to the latest log
ln -sf "localplannerloglari_${TIMESTAMP}.log" logs/localplannerloglari_latest.log

echo "📝 Local planner stopped. Log saved to: $LOG_FILE"
