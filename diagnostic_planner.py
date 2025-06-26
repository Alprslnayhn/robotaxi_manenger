#!/usr/bin/env python3
"""
Local Planner Diagnostic Script
Bu script local planner'ın hangi verilerle çalıştığını ve 
replanning logic'inin tetiklenip tetiklenmediğini test eder.
"""

import rclpy
import math
import numpy as np
from rclpy.node import Node
from rclpy.qos import QoSProfile, ReliabilityPolicy, HistoryPolicy
from std_msgs.msg import Float64
from sensor_msgs.msg import LaserScan
from nav_msgs.msg import Path, OccupancyGrid
from geometry_msgs.msg import Pose2D, PoseStamped
from robotaxi_msgs.msg import Path2D, State2D

class LocalPlannerDiagnostic(Node):
    def __init__(self):
        super().__init__('local_planner_diagnostic')
        
        # QoS profiles
        self.default_qos = QoSProfile(depth=10)
        self.map_qos = QoSProfile(
            reliability=ReliabilityPolicy.BEST_EFFORT,
            history=HistoryPolicy.KEEP_LAST,
            depth=1
        )
        
        # Subscribers - tüm local planner input'larını dinle
        self.laser_sub = self.create_subscription(
            LaserScan, '/scan', self.laser_cb, self.default_qos)
        self.goals_sub = self.create_subscription(
            Path2D, '/robotaxi/goals', self.goals_cb, self.default_qos)
        self.state_sub = self.create_subscription(
            State2D, '/robotaxi/state2D', self.state_cb, self.default_qos)
        self.costmap_sub = self.create_subscription(
            OccupancyGrid, '/map', self.costmap_cb, self.map_qos)
        
        # Local planner output'larını dinle
        self.path_sub = self.create_subscription(
            Path2D, '/robotaxi/path', self.path_output_cb, self.default_qos)
        self.vel_sub = self.create_subscription(
            Float64, '/robotaxi/target_velocity', self.velocity_cb, self.default_qos)
        
        # Data tracking
        self.laser_data = None
        self.goals_data = None
        self.state_data = None
        self.costmap_data = None
        self.path_output = None
        self.velocity_output = None
        
        # Statistics
        self.laser_count = 0
        self.goals_count = 0
        self.state_count = 0
        self.path_output_count = 0
        self.obstacle_detection_count = 0
        self.emergency_stop_count = 0
        self.path_change_count = 0
        
        # Obstacle detection parameters (same as local planner)
        self.obstacle_detection_range = 5.0
        self.emergency_brake_distance = 1.0
        self.safety_margin = 0.5
        self.car_width = 2.0
        
        # Previous path for comparison
        self.previous_path = None
        
        # Timer for periodic diagnostics
        self.timer = self.create_timer(1.0, self.diagnostic_report)
        
        self.get_logger().info('🔍 Local Planner Diagnostic Started')
        self.get_logger().info('📊 Monitoring all input/output topics...')

    def laser_cb(self, msg):
        """Laser scan callback - analyze obstacle detection"""
        self.laser_data = msg
        self.laser_count += 1
        
        # Analyze obstacles
        obstacles = self.analyze_obstacles(msg)
        if obstacles['detected']:
            self.obstacle_detection_count += 1
            
        if obstacles['emergency']:
            self.emergency_stop_count += 1
            self.get_logger().warn(f'🚨 Emergency obstacle detected at {obstacles["min_distance"]:.2f}m')
        
        # Log detailed obstacle info every 10 scans
        if self.laser_count % 10 == 0:
            self.log_obstacle_details(obstacles)

    def goals_cb(self, msg):
        """Goals callback - track global planner input"""
        self.goals_data = msg
        self.goals_count += 1
        
        if len(msg.poses) > 0:
            self.get_logger().info(f'📍 Goals received: {len(msg.poses)} waypoints')
            first_goal = msg.poses[0]
            last_goal = msg.poses[-1]
            self.get_logger().info(f'   First: ({first_goal.x:.2f}, {first_goal.y:.2f})')
            self.get_logger().info(f'   Last: ({last_goal.x:.2f}, {last_goal.y:.2f})')

    def state_cb(self, msg):
        """Vehicle state callback"""
        self.state_data = msg
        self.state_count += 1
        
        if self.state_count % 20 == 0:  # Every 2 seconds
            self.get_logger().info(f'🚗 Vehicle state: x={msg.pose.x:.2f}, y={msg.pose.y:.2f}, θ={math.degrees(msg.pose.theta):.1f}°')

    def costmap_cb(self, msg):
        """Costmap callback"""
        self.costmap_data = msg
        if hasattr(self, '_costmap_logged'):
            return
        self._costmap_logged = True
        self.get_logger().info(f'🗺️  Costmap received: {msg.info.width}x{msg.info.height}, resolution={msg.info.resolution}')

    def path_output_cb(self, msg):
        """Local planner path output callback"""
        self.path_output = msg
        self.path_output_count += 1
        
        # Check if path has changed significantly
        if self.has_path_changed(msg):
            self.path_change_count += 1
            self.get_logger().info(f'🛤️  NEW PATH Generated! Total path changes: {self.path_change_count}')
            if len(msg.poses) > 0:
                self.get_logger().info(f'   Path length: {len(msg.poses)} points')
                first_point = msg.poses[0]
                self.get_logger().info(f'   Starting point: ({first_point.x:.2f}, {first_point.y:.2f})')
        
        self.previous_path = msg

    def velocity_cb(self, msg):
        """Target velocity callback"""
        self.velocity_output = msg
        
        if hasattr(self, '_last_velocity') and abs(self._last_velocity - msg.data) > 0.5:
            self.get_logger().info(f'⚡ Velocity changed: {self._last_velocity:.1f} -> {msg.data:.1f} m/s')
        self._last_velocity = msg.data

    def analyze_obstacles(self, laser_msg):
        """Analyze laser scan for obstacles (same logic as local planner)"""
        obstacles = []
        min_distance = float('inf')
        emergency = False
        
        for i, range_val in enumerate(laser_msg.ranges):
            if range_val < laser_msg.range_min or range_val > laser_msg.range_max:
                continue
                
            if range_val > self.obstacle_detection_range:
                continue
                
            angle = laser_msg.angle_min + i * laser_msg.angle_increment
            x_obs = range_val * math.cos(angle)
            y_obs = range_val * math.sin(angle)
            
            # Only consider obstacles in front of vehicle
            if x_obs > 0 and abs(y_obs) < self.car_width / 2 + self.safety_margin:
                obstacles.append((x_obs, y_obs, range_val))
                min_distance = min(min_distance, range_val)
        
        if min_distance < self.emergency_brake_distance:
            emergency = True
            
        return {
            'detected': len(obstacles) > 0,
            'count': len(obstacles),
            'min_distance': min_distance if min_distance != float('inf') else None,
            'emergency': emergency,
            'obstacles': obstacles
        }

    def has_path_changed(self, new_path):
        """Check if path has changed significantly"""
        if self.previous_path is None:
            return True
            
        if len(new_path.poses) != len(self.previous_path.poses):
            return True
            
        # Check if any point has moved more than 0.1m
        for i in range(min(len(new_path.poses), len(self.previous_path.poses))):
            new_pose = new_path.poses[i]
            old_pose = self.previous_path.poses[i]
            
            distance = math.sqrt(
                (new_pose.x - old_pose.x)**2 + 
                (new_pose.y - old_pose.y)**2
            )
            
            if distance > 0.1:  # 10cm threshold
                return True
                
        return False

    def log_obstacle_details(self, obstacles):
        """Log detailed obstacle information"""
        if obstacles['detected']:
            self.get_logger().info(
                f'🚧 Obstacles: {obstacles["count"]} detected, '
                f'closest at {obstacles["min_distance"]:.2f}m'
            )
            
            # Log first few obstacles
            for i, (x, y, dist) in enumerate(obstacles['obstacles'][:3]):
                self.get_logger().info(f'   Obstacle {i+1}: x={x:.2f}, y={y:.2f}, dist={dist:.2f}')

    def diagnostic_report(self):
        """Periodic diagnostic report"""
        self.get_logger().info('=' * 60)
        self.get_logger().info('📊 LOCAL PLANNER DIAGNOSTIC REPORT')
        self.get_logger().info('=' * 60)
        
        # Input data status
        self.get_logger().info('📥 INPUT DATA STATUS:')
        self.get_logger().info(f'   Laser scans received: {self.laser_count}')
        self.get_logger().info(f'   Goals received: {self.goals_count}')
        self.get_logger().info(f'   State updates: {self.state_count}')
        self.get_logger().info(f'   Costmap available: {"✅" if self.costmap_data else "❌"}')
        
        # Current data availability
        missing_data = []
        if self.laser_data is None:
            missing_data.append('LaserScan')
        if self.goals_data is None:
            missing_data.append('Goals')
        if self.state_data is None:
            missing_data.append('VehicleState')
            
        if missing_data:
            self.get_logger().warn(f'⚠️  Missing data: {", ".join(missing_data)}')
        else:
            self.get_logger().info('✅ All required data available')
        
        # Obstacle detection status
        self.get_logger().info('🚧 OBSTACLE DETECTION:')
        self.get_logger().info(f'   Obstacles detected: {self.obstacle_detection_count} times')
        self.get_logger().info(f'   Emergency stops: {self.emergency_stop_count} times')
        
        # Output status
        self.get_logger().info('📤 OUTPUT STATUS:')
        self.get_logger().info(f'   Paths published: {self.path_output_count}')
        self.get_logger().info(f'   Path changes: {self.path_change_count}')
        
        current_velocity = self.velocity_output.data if self.velocity_output else "Unknown"
        self.get_logger().info(f'   Current target velocity: {current_velocity}')
        
        # Analysis
        self.get_logger().info('🔍 ANALYSIS:')
        
        if self.obstacle_detection_count > 0 and self.path_change_count == 0:
            self.get_logger().error('❌ PROBLEM: Obstacles detected but NO path changes!')
            self.get_logger().error('   -> Lateral path generation may not be working')
        
        if self.goals_count == 0:
            self.get_logger().error('❌ PROBLEM: No goals received from global planner')
        
        if self.laser_count == 0:
            self.get_logger().error('❌ PROBLEM: No laser scan data')
            
        if self.state_count == 0:
            self.get_logger().error('❌ PROBLEM: No vehicle state data')
            
        # Recommendations
        self.get_logger().info('💡 RECOMMENDATIONS:')
        
        if self.obstacle_detection_count > 0 and self.path_change_count == 0:
            self.get_logger().info('   1. Check if publish_path() is called in obstacle detection')
            self.get_logger().info('   2. Verify lateral path generation logic')
            self.get_logger().info('   3. Check if ax, ay arrays have data when obstacles detected')
        
        if missing_data:
            self.get_logger().info(f'   1. Start missing data sources: {", ".join(missing_data)}')
            
        self.get_logger().info('=' * 60)

    def test_path_generation_trigger(self):
        """Test if path generation should be triggered with current data"""
        if not all([self.laser_data, self.goals_data, self.state_data]):
            self.get_logger().warn('⚠️  Cannot test path generation - missing required data')
            return
            
        obstacles = self.analyze_obstacles(self.laser_data)
        
        self.get_logger().info('🧪 PATH GENERATION TEST:')
        self.get_logger().info(f'   Goals available: {len(self.goals_data.poses) if self.goals_data else 0} points')
        self.get_logger().info(f'   Vehicle state: Available')
        self.get_logger().info(f'   Obstacles detected: {obstacles["detected"]}')
        
        if obstacles['detected']:
            self.get_logger().info('   ✅ Conditions met for lateral path generation')
            if self.path_change_count == 0:
                self.get_logger().error('   ❌ But no path changes detected - check planner logic!')
        else:
            self.get_logger().info('   ℹ️  No obstacles - normal path should be used')

def main(args=None):
    rclpy.init(args=args)
    
    diagnostic = LocalPlannerDiagnostic()
    
    try:
        # Run diagnostic for a while, then do final test
        rclpy.spin(diagnostic)
    except KeyboardInterrupt:
        diagnostic.get_logger().info('🔍 Diagnostic completed')
        diagnostic.test_path_generation_trigger()
    finally:
        diagnostic.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()
