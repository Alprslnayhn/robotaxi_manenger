# robotaxi_manenger
# RobotTaxi Navigation Manager # Comprehensive script to launch, log, and monitor navigation nodes


***

```markdown
# Robotaxi Navigation Orchestrator & Telemetry Monitor

A robust CLI-based orchestration and real-time telemetry monitoring suite designed for ROS 2 autonomous navigation stacks. This project streamlines node management, enhances system observability, and provides instant diagnostic feedback during simulation and real-world deployment.

## 🔄 System Refactoring: Legacy vs. Current Architecture

* **Legacy State:** Fragmented node initialization via disparate launch files. Debugging relied on unstructured `stdout` logs, making real-time spatial awareness and state tracking highly inefficient.
* **Enhanced Architecture:** * **Centralized CLI Orchestrator (Manager):** Unified terminal interface providing granular control (Options 1-12) over the navigation stack lifecycle (launching, halting, and log wiping).
    * **TUI Telemetry Dashboard (Monitor UI):** A synchronized console user interface (CUI/TUI) delivering real-time metrics on Lidar health, directional obstacle proximity, and dynamic threat levels (LOW/MEDIUM/HIGH).
    * **Automated Diagnostics & Recovery:** Integrated diagnostic node that detects path planning failures (e.g., "Stuck" states) in real-time, generating isolated logs and triggering autonomous recovery maneuvers.

## 🎥 System Demonstrations

*(Note: Drag and drop your `.webm` files directly into the GitHub editor, then paste the generated URLs into the `src` attributes below.)*

**Demo 1: Stack Initialization & TUI Dashboard**
<video src="PASTE_1ST_VIDEO_GITHUB_LINK_HERE.webm" controls autoplay loop muted></video>

**Demo 2: Autonomous Navigation & Dynamic Obstacle Avoidance**
<video src="PASTE_2ND_VIDEO_GITHUB_LINK_HERE.webm" controls autoplay loop muted></video>

## 📸 Interface Overview

| Component | Description |
| :--- | :--- |
| ![Orchestrator CLI](PASTE_PHOTO_LINK_HERE) | **Manager CLI:** The central control hub for managing ROS 2 navigation nodes. |
| ![Diagnostic Stream](PASTE_PHOTO_LINK_HERE) | **Diagnostic Planner:** Filtered, synchronized stream for error tracking and recovery state analysis. |
| ![Telemetry & RViz2](PASTE_PHOTO_LINK_HERE) | **Monitor UI & RViz2:** Real-time spatial danger analysis alongside visual path tracking. |

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

```
