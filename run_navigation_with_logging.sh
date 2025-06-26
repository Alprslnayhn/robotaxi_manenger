#!/bin/bash

# Combined script to run both diagnostic planner and local planner with logging
# This script runs both nodes simultaneously with their outputs redirected to separate log files

echo "🚀 Starting RobotTaxi Navigation with Comprehensive Logging"
echo "========================================================="

# Create log directory if it doesn't exist
mkdir -p logs

# Source the ROS2 environment
source /opt/ros/humble/setup.bash
source install/setup.bash

# Get current timestamp for log file naming
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")

# Log file paths
DIAGNOSTIC_LOG="logs/diagnostic_plannerloglari_${TIMESTAMP}.log"
LOCALPLANNER_LOG="logs/localplannerloglari_${TIMESTAMP}.log"

echo "📝 Log files:"
echo "   Diagnostic Planner: $DIAGNOSTIC_LOG"
echo "   Local Planner:      $LOCALPLANNER_LOG"
echo "========================================================="

# Function to run diagnostic planner in background
run_diagnostic() {
    echo "=== Starting Local Planner Diagnostic at $(date) ===" > "$DIAGNOSTIC_LOG"
    echo "Log file: $DIAGNOSTIC_LOG" >> "$DIAGNOSTIC_LOG"
    echo "=========================================" >> "$DIAGNOSTIC_LOG"
    
    ros2 run robotaxi_nav diagnostic_planner.py 2>&1 | tee -a "$DIAGNOSTIC_LOG" &
    DIAGNOSTIC_PID=$!
    echo "🔍 Diagnostic Planner started (PID: $DIAGNOSTIC_PID)"
}

# Function to run local planner in background
run_localplanner() {
    echo "=== Starting Local Planner at $(date) ===" > "$LOCALPLANNER_LOG"
    echo "Log file: $LOCALPLANNER_LOG" >> "$LOCALPLANNER_LOG"
    echo "=========================================" >> "$LOCALPLANNER_LOG"
    
    ros2 run robotaxi_nav localplanner.py 2>&1 | tee -a "$LOCALPLANNER_LOG" &
    LOCALPLANNER_PID=$!
    echo "🚗 Local Planner started (PID: $LOCALPLANNER_PID)"
}

# Start both processes
run_diagnostic
run_localplanner

# Create symlinks to latest logs
ln -sf "diagnostic_plannerloglari_${TIMESTAMP}.log" logs/diagnostic_plannerloglari_latest.log
ln -sf "localplannerloglari_${TIMESTAMP}.log" logs/localplannerloglari_latest.log

echo "========================================================="
echo "✅ Both nodes started successfully!"
echo "📊 Monitor logs in real-time with:"
echo "   tail -f $DIAGNOSTIC_LOG"
echo "   tail -f $LOCALPLANNER_LOG"
echo ""
echo "🔗 Or use the latest log symlinks:"
echo "   tail -f logs/diagnostic_plannerloglari_latest.log"
echo "   tail -f logs/localplannerloglari_latest.log"
echo ""
echo "🛑 Press Ctrl+C to stop both processes"
echo "========================================================="

# Function to handle cleanup
cleanup() {
    echo ""
    echo "🛑 Stopping all processes..."
    if [ ! -z "$DIAGNOSTIC_PID" ]; then
        kill $DIAGNOSTIC_PID 2>/dev/null
        echo "   Stopped Diagnostic Planner (PID: $DIAGNOSTIC_PID)"
    fi
    if [ ! -z "$LOCALPLANNER_PID" ]; then
        kill $LOCALPLANNER_PID 2>/dev/null
        echo "   Stopped Local Planner (PID: $LOCALPLANNER_PID)"
    fi
    echo "📝 Log files saved:"
    echo "   Diagnostic: $DIAGNOSTIC_LOG"
    echo "   Local:      $LOCALPLANNER_LOG"
    exit 0
}

# Set trap to handle Ctrl+C
trap cleanup SIGINT SIGTERM

# Wait for both processes to finish (or until Ctrl+C)
wait
