# RobotTaxi Navigation Logging System

This directory contains scripts for comprehensive logging and analysis of the RobotTaxi navigation system, specifically focusing on the local planner and diagnostic tools.

## 📁 Directory Structure

```
robotaxi_ws/
├── run_diagnostic_planner_with_logging.sh    # Run diagnostic planner with logging
├── run_localplanner_with_logging.sh          # Run local planner with logging  
├── run_navigation_with_logging.sh             # Run both nodes with logging
├── monitor_logs.sh                            # Monitor logs in real-time
├── analyze_logs.py                            # Analyze and extract metrics from logs
└── logs/                                      # Log output directory
    ├── diagnostic_plannerloglari_TIMESTAMP.log
    ├── localplannerloglari_TIMESTAMP.log
    ├── diagnostic_plannerloglari_latest.log   # Symlink to latest
    └── localplannerloglari_latest.log          # Symlink to latest
```

## 🚀 Quick Start

### 1. Run Both Navigation Nodes with Logging
```bash
# This starts both diagnostic planner and local planner with full logging
./run_navigation_with_logging.sh
```

### 2. Run Individual Nodes with Logging
```bash
# Run only diagnostic planner with logging
./run_diagnostic_planner_with_logging.sh

# Run only local planner with logging  
./run_localplanner_with_logging.sh
```

### 3. Monitor Logs in Real-Time
```bash
# Monitor both log files simultaneously
./monitor_logs.sh

# Or monitor individual logs
tail -f logs/diagnostic_plannerloglari_latest.log
tail -f logs/localplannerloglari_latest.log
```

### 4. Analyze Log Files
```bash
# Analyze latest logs automatically
python3 analyze_logs.py --latest

# Analyze specific log files
python3 analyze_logs.py -d logs/diagnostic_plannerloglari_2025-01-15_10-30-45.log -l logs/localplannerloglari_2025-01-15_10-30-45.log

# Analyze single log file
python3 analyze_logs.py --diagnostic logs/diagnostic_plannerloglari_latest.log
```

## 📊 What Gets Logged

### Diagnostic Planner Log (`diagnostic_plannerloglari`)
- 🔍 **Input Data Monitoring**: Laser scans, goals, robot state, costmap
- 📊 **Statistics**: Message counts, frequencies, data quality
- 🚨 **Obstacle Detection**: Detected obstacles, distances, emergency situations
- 📈 **Performance Metrics**: Processing times, replanning events
- 🔄 **Path Analysis**: Path changes, replanning triggers, path quality

### Local Planner Log (`localplannerloglari`)  
- 🚗 **Path Planning**: Generated paths, waypoint counts, planning algorithms
- 🚨 **Obstacle Avoidance**: Real-time obstacle detection and response
- 🔄 **Replanning Events**: When and why paths are replanned
- ⚡ **Velocity Commands**: Target velocities, speed adjustments
- 🛑 **Emergency Stops**: Emergency brake activations and reasons
- 📍 **Navigation State**: Current position, goals, path following status

## 🔧 Log Analysis Features

The `analyze_logs.py` script provides:

### 📈 Metrics Extraction
- **Event Counts**: Obstacles detected, emergency stops, path replanning
- **Performance Stats**: Average processing times, success rates
- **Distance Analysis**: Obstacle distances, safety margins
- **Velocity Profiles**: Speed commands, acceleration patterns

### 📊 Comparative Analysis
- **Cross-Node Comparison**: Compare diagnostic vs. local planner data
- **Temporal Analysis**: Event timing and sequences
- **Efficiency Metrics**: Replanning ratios, response times

### 🚨 Issue Detection
- **Emergency Stop Patterns**: Frequency and triggers
- **Path Planning Issues**: Failed replanning attempts
- **Performance Bottlenecks**: Slow processing indicators

## 💡 Usage Tips

### For Development & Debugging
1. **Start with combined logging**: Use `run_navigation_with_logging.sh`
2. **Monitor in real-time**: Use `monitor_logs.sh` during testing
3. **Analyze after testing**: Use `analyze_logs.py --latest` for insights

### For Performance Analysis
1. **Run specific scenarios**: Test obstacle avoidance, path following
2. **Collect metrics**: Use the analysis script to extract performance data
3. **Compare runs**: Analyze different log files to compare performance

### For Issue Investigation
1. **Look for patterns**: Search log files for specific error messages
2. **Check timing**: Verify that replanning happens when expected
3. **Validate responses**: Ensure obstacle detection triggers proper responses

## 🔍 Log File Format

### Header Information
```
=== Starting Local Planner at 2025-01-15 10:30:45 ===
Log file: logs/localplannerloglari_2025-01-15_10-30-45.log
=========================================
```

### Typical Log Entries
```
[INFO] [localplanner]: 🚗 Local Planner Node Started
[DEBUG] [localplanner]: 📊 Processing laser scan with 360 points
[WARN] [localplanner]: 🚨 Obstacle detected at 2.3m, replanning path
[INFO] [localplanner]: 🔄 Generated new path with 15 waypoints
[DEBUG] [localplanner]: 🚗 Publishing velocity: 1.5 m/s
```

## 🛠 Troubleshooting

### Log Files Not Created
1. **Check permissions**: Ensure scripts are executable (`chmod +x *.sh`)
2. **Verify environment**: Source ROS2 setup properly
3. **Check paths**: Ensure you're running from the correct directory

### No Output in Logs
1. **Verify nodes are running**: Check `ros2 node list`
2. **Check topics**: Verify `ros2 topic list` shows expected topics
3. **Review parameters**: Ensure navigation_params.yaml is correct

### Analysis Script Issues
1. **Install dependencies**: Ensure Python3 is available
2. **Check log format**: Verify log files contain expected patterns
3. **File permissions**: Ensure log files are readable

## 📝 Log Retention

- **Automatic timestamping**: Each run creates timestamped log files
- **Latest symlinks**: Always points to most recent logs
- **Manual cleanup**: Periodically clean old logs to save space

```bash
# Clean logs older than 7 days
find logs/ -name "*.log" -mtime +7 -delete
```

## 🔗 Integration with ROS2

The logging system integrates seamlessly with:
- **ROS2 logging**: Captures all ROS log levels (DEBUG, INFO, WARN, ERROR)
- **Node lifecycle**: Logs node startup, shutdown, and state changes
- **Topic monitoring**: Captures all published and subscribed data
- **Parameter changes**: Logs parameter updates and reconfigurations

## 📚 Related Documentation

- `OBSTACLE_AVOIDANCE_README.md`: Details on obstacle avoidance implementation
- `USAGE_GUIDE.md`: General usage instructions for the navigation system
- `src/robotaxi_nav/config/navigation_params.yaml`: Navigation parameters
