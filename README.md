# robotaxi_manenger
# RobotTaxi Navigation Manager # Comprehensive script to launch, log, and monitor navigation nodes


***

https://github.com/user-attachments/assets/30aeb2ea-bf5d-4337-82a4-4b6a051c362a



# Robotaxi Navigation Orchestrator & Telemetry Monitor

A robust CLI-based orchestration and real-time telemetry monitoring suite designed for ROS 2 autonomous navigation stacks. This project streamlines node management, enhances system observability, and provides instant diagnostic feedback during simulation and real-world deployment.

## 🔄 System Refactoring: Legacy vs. Current Architecture

* **Legacy State:** Fragmented node initialization via disparate launch files. Debugging relied on unstructured `stdout` logs, making real-time spatial awareness and state tracking highly inefficient.
* **Enhanced Architecture:** * **Centralized CLI Orchestrator (Manager):** Unified terminal interface providing granular control (Options 1-12) over the navigation stack lifecycle (launching, halting, and log wiping).
    * **TUI Telemetry Dashboard (Monitor UI):** A synchronized console user interface (CUI/TUI) delivering real-time metrics on Lidar health, directional obstacle proximity, and dynamic threat levels (LOW/MEDIUM/HIGH).
    * **Automated Diagnostics & Recovery:** Integrated diagnostic node that detects path planning failures (e.g., "Stuck" states) in real-time, generating isolated logs and triggering autonomous recovery maneuvers.

## 🎥 System Demonstrations



**Demo 1: Stack Initialization & TUI Dashboard**

https://github.com/user-attachments/assets/30aeb2ea-bf5d-4337-82a4-4b6a051c362a



## 📸 Interface Overview

| Component | Description |
| :--- | :--- |
| ![Orchestrator CLI](https://github.com/Alprslnayhn/robotaxi_manenger/blob/main/doc/Screenshots/Screenshot%20from%202026-04-06%2012-29-10.png) | **Manager CLI:** The central control hub for managing ROS 2 navigation nodes. |
| ![Diagnostic Stream](https://github.com/Alprslnayhn/robotaxi_manenger/blob/main/doc/Screenshots/Screenshot%20from%202026-04-06%2012-32-34.png) | **Diagnostic Planner:** Filtered, synchronized stream for error tracking and recovery state analysis. |
| ![Telemetry & RViz2](https://github.com/Alprslnayhn/robotaxi_manenger/blob/main/doc/Screenshots/Screenshot%20from%202026-04-06%2014-35-11.png) | **Monitor UI & RViz2:** Real-time spatial danger analysis alongside visual path tracking. |

## 🛠️ Build & Deployment

### Prerequisites
* Ubuntu 22.04 / 24.04
* ROS 2 (Humble / Iron / Jazzy)
* Gazebo & RViz2

### Compilation
```bash
cd ~/robotaxi_ws
colcon build --symlink-install
source install/setup.bash
```

### Execution
```bash
# Launch the orchestration menu
./start_manager.sh  
# OR
ros2 run robotaxi_manager menu_node
```

**Demo 2: Autonomous Navigation & Dynamic Obstacle Avoidance**


[Screencast from 06-27-2025 08:58:30 PM.webm](https://github.com/user-attachments/assets/f18c6fba-76b2-4a13-9c3c-190362f9f674)
