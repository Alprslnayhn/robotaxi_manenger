#!/usr/bin/env python3
"""
Log Analysis Script for RobotTaxi Navigation
Analyzes the log files to extract key metrics and insights
"""

import os
import re
import sys
import argparse
from datetime import datetime
from collections import defaultdict, Counter

class NavigationLogAnalyzer:
    def __init__(self):
        self.log_patterns = {
            'obstacle_detected': r'🚨.*obstacle.*detected.*(\d+\.?\d*)m',
            'emergency_stop': r'🛑.*emergency.*stop',
            'path_generated': r'📍.*path.*generated.*(\d+).*points',
            'path_replanned': r'🔄.*replanning.*path',
            'velocity_command': r'🚗.*velocity.*(\d+\.?\d*)',
            'info_log': r'\[INFO\]',
            'warn_log': r'\[WARN\]',
            'error_log': r'\[ERROR\]',
            'debug_log': r'\[DEBUG\]'
        }
        
    def analyze_log_file(self, log_file):
        """Analyze a single log file and extract metrics"""
        if not os.path.exists(log_file):
            print(f"❌ Log file not found: {log_file}")
            return None
            
        print(f"📊 Analyzing: {log_file}")
        print("=" * 50)
        
        metrics = defaultdict(int)
        obstacle_distances = []
        velocity_commands = []
        timestamps = []
        
        with open(log_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                # Extract timestamp if available
                timestamp_match = re.search(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}', line)
                if timestamp_match:
                    timestamps.append(timestamp_match.group())
                
                # Check each pattern
                for pattern_name, pattern in self.log_patterns.items():
                    if re.search(pattern, line, re.IGNORECASE):
                        metrics[pattern_name] += 1
                        
                        # Extract specific values
                        if pattern_name == 'obstacle_detected':
                            distance_match = re.search(r'(\d+\.?\d*)m', line)
                            if distance_match:
                                obstacle_distances.append(float(distance_match.group(1)))
                                
                        elif pattern_name == 'velocity_command':
                            vel_match = re.search(r'(\d+\.?\d*)', line)
                            if vel_match:
                                velocity_commands.append(float(vel_match.group(1)))
        
        # Print analysis results
        print(f"📈 Log Analysis Results:")
        print(f"   Total lines processed: {line_num}")
        print(f"   Time span: {len(timestamps)} timestamped entries")
        print()
        
        print("🔍 Event Counts:")
        for event, count in sorted(metrics.items()):
            print(f"   {event.replace('_', ' ').title()}: {count}")
        print()
        
        if obstacle_distances:
            print("🚨 Obstacle Detection Analysis:")
            print(f"   Total obstacles detected: {len(obstacle_distances)}")
            print(f"   Average distance: {sum(obstacle_distances)/len(obstacle_distances):.2f}m")
            print(f"   Minimum distance: {min(obstacle_distances):.2f}m")
            print(f"   Maximum distance: {max(obstacle_distances):.2f}m")
            print()
            
        if velocity_commands:
            print("🚗 Velocity Command Analysis:")
            print(f"   Total velocity commands: {len(velocity_commands)}")
            print(f"   Average velocity: {sum(velocity_commands)/len(velocity_commands):.2f}")
            print(f"   Velocity range: {min(velocity_commands):.2f} - {max(velocity_commands):.2f}")
            print()
        
        # Calculate some ratios
        if metrics['obstacle_detected'] > 0:
            emergency_ratio = metrics['emergency_stop'] / metrics['obstacle_detected'] * 100
            print(f"📊 Emergency Stop Ratio: {emergency_ratio:.1f}% of obstacles")
            
        if metrics['obstacle_detected'] > 0 and metrics['path_replanned'] > 0:
            replan_ratio = metrics['path_replanned'] / metrics['obstacle_detected'] * 100
            print(f"🔄 Path Replanning Ratio: {replan_ratio:.1f}% of obstacles")
        
        print("=" * 50)
        return metrics

    def analyze_both_logs(self, diagnostic_log, localplanner_log):
        """Analyze both log files and provide comparative insights"""
        print("🔍 COMPREHENSIVE LOG ANALYSIS")
        print("=" * 60)
        
        print("\n📊 DIAGNOSTIC PLANNER LOG:")
        diagnostic_metrics = self.analyze_log_file(diagnostic_log)
        
        print("\n📊 LOCAL PLANNER LOG:")
        localplanner_metrics = self.analyze_log_file(localplanner_log)
        
        if diagnostic_metrics and localplanner_metrics:
            print("\n🔗 COMPARATIVE ANALYSIS:")
            print("=" * 30)
            
            # Compare key metrics
            diagnostic_obstacles = diagnostic_metrics.get('obstacle_detected', 0)
            localplanner_obstacles = localplanner_metrics.get('obstacle_detected', 0)
            
            if diagnostic_obstacles > 0 or localplanner_obstacles > 0:
                print(f"Obstacles - Diagnostic: {diagnostic_obstacles}, Local Planner: {localplanner_obstacles}")
                
            diagnostic_replans = diagnostic_metrics.get('path_replanned', 0)
            localplanner_replans = localplanner_metrics.get('path_replanned', 0)
            
            if diagnostic_replans > 0 or localplanner_replans > 0:
                print(f"Replanning - Diagnostic: {diagnostic_replans}, Local Planner: {localplanner_replans}")

def main():
    parser = argparse.ArgumentParser(description='Analyze RobotTaxi Navigation Log Files')
    parser.add_argument('--diagnostic', '-d', help='Diagnostic planner log file')
    parser.add_argument('--localplanner', '-l', help='Local planner log file')
    parser.add_argument('--latest', action='store_true', help='Use latest log files')
    parser.add_argument('--logs-dir', default='logs', help='Logs directory (default: logs)')
    
    args = parser.parse_args()
    
    analyzer = NavigationLogAnalyzer()
    
    if args.latest:
        # Use latest log files
        diagnostic_log = os.path.join(args.logs_dir, 'diagnostic_plannerloglari_latest.log')
        localplanner_log = os.path.join(args.logs_dir, 'localplannerloglari_latest.log')
        
        if os.path.exists(diagnostic_log) and os.path.exists(localplanner_log):
            analyzer.analyze_both_logs(diagnostic_log, localplanner_log)
        else:
            print("❌ Latest log files not found. Available logs:")
            if os.path.exists(args.logs_dir):
                for f in os.listdir(args.logs_dir):
                    if f.endswith('.log'):
                        print(f"   {f}")
            else:
                print("   No logs directory found")
                
    elif args.diagnostic and args.localplanner:
        analyzer.analyze_both_logs(args.diagnostic, args.localplanner)
        
    elif args.diagnostic:
        analyzer.analyze_log_file(args.diagnostic)
        
    elif args.localplanner:
        analyzer.analyze_log_file(args.localplanner)
        
    else:
        print("📊 RobotTaxi Navigation Log Analyzer")
        print("Usage examples:")
        print("  python3 analyze_logs.py --latest")
        print("  python3 analyze_logs.py -d diagnostic.log -l localplanner.log")
        print("  python3 analyze_logs.py --diagnostic diagnostic.log")
        print()
        
        # Try to find and analyze latest logs automatically
        logs_dir = args.logs_dir
        if os.path.exists(logs_dir):
            log_files = [f for f in os.listdir(logs_dir) if f.endswith('.log')]
            if log_files:
                print("📂 Available log files:")
                for f in sorted(log_files):
                    print(f"   {f}")
                print()
                print("💡 Use --latest to analyze the most recent logs")

if __name__ == '__main__':
    main()
