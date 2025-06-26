#!/bin/bash

# Script to monitor both log files simultaneously in a split terminal view
# This script uses multitail if available, or falls back to tail

echo "📊 RobotTaxi Navigation Log Monitor"
echo "==================================="

# Check if logs directory exists
if [ ! -d "logs" ]; then
    echo "❌ No logs directory found. Run the navigation scripts first."
    exit 1
fi

# Check if latest log symlinks exist
DIAGNOSTIC_LOG="logs/diagnostic_plannerloglari_latest.log"
LOCALPLANNER_LOG="logs/localplannerloglari_latest.log"

if [ ! -f "$DIAGNOSTIC_LOG" ] || [ ! -f "$LOCALPLANNER_LOG" ]; then
    echo "❌ Latest log files not found. Available logs:"
    ls -la logs/
    echo ""
    echo "Run one of these scripts first:"
    echo "  ./run_navigation_with_logging.sh     (both nodes)"
    echo "  ./run_diagnostic_planner_with_logging.sh"
    echo "  ./run_localplanner_with_logging.sh"
    exit 1
fi

echo "📝 Monitoring logs:"
echo "   Diagnostic: $DIAGNOSTIC_LOG"
echo "   Local:      $LOCALPLANNER_LOG"
echo ""

# Check if multitail is available
if command -v multitail &> /dev/null; then
    echo "🔍 Using multitail for split view (press 'q' to quit)"
    echo "==================================="
    multitail -s 2 \
        -t "Diagnostic Planner" "$DIAGNOSTIC_LOG" \
        -t "Local Planner" "$LOCALPLANNER_LOG"
else
    echo "🔍 Multitail not available, using split terminal approach"
    echo "   Install multitail for better viewing: sudo apt install multitail"
    echo "==================================="
    echo "📊 DIAGNOSTIC PLANNER LOG:"
    echo "-------------------"
    tail -f "$DIAGNOSTIC_LOG" &
    TAIL1_PID=$!
    
    echo ""
    echo "📊 LOCAL PLANNER LOG:"
    echo "------------------"
    tail -f "$LOCALPLANNER_LOG" &
    TAIL2_PID=$!
    
    # Function to handle cleanup
    cleanup() {
        echo ""
        echo "🛑 Stopping log monitoring..."
        kill $TAIL1_PID $TAIL2_PID 2>/dev/null
        exit 0
    }
    
    # Set trap to handle Ctrl+C
    trap cleanup SIGINT SIGTERM
    
    echo ""
    echo "🛑 Press Ctrl+C to stop monitoring"
    wait
fi
